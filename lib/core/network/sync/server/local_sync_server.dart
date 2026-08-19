import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../enums/sync_enums.dart';
import '../models/sync_payload_model.dart';
import '../models/sync_message_model.dart';

typedef FullSyncDataProvider = Future<List<SyncPayloadModel>> Function();

class ConnectedClient {
  final String id;
  final WebSocketChannel channel;
  final DateTime connectedAt;
  DateTime lastSeen;
  String platform;

  ConnectedClient({
    required this.id,
    required this.channel,
    required this.connectedAt,
    required this.lastSeen,
    this.platform = 'unknown',
  });
}

class LocalSyncServer {
  static const int defaultPort = 8080;
  static const Duration pingInterval = Duration(seconds: 15);

  HttpServer? _server;
  final Map<String, ConnectedClient> _clients = {};
  Timer? _heartbeatTimer;

  final _incomingPayloadsController = StreamController<SyncPayloadModel>.broadcast();
  final _incomingBatchesController = StreamController<List<SyncPayloadModel>>.broadcast();
  final _incomingMessagesController = StreamController<SyncMessageModel>.broadcast();
  final _clientsCountController = StreamController<int>.broadcast();

  FullSyncDataProvider? fullSyncDataProvider;

  Stream<SyncPayloadModel> get incomingPayloads => _incomingPayloadsController.stream;
  Stream<List<SyncPayloadModel>> get incomingBatches => _incomingBatchesController.stream;
  Stream<SyncMessageModel> get incomingMessages => _incomingMessagesController.stream;
  Stream<int> get clientsCountStream => _clientsCountController.stream;

  bool get isRunning => _server != null;
  int get connectedClientsCount => _clients.length;
  int? get serverPort => _server?.port;

  /// Ensures Windows Defender Firewall allows incoming connections on port 8080 for Private networks
  static Future<void> ensureWindowsFirewallRule({int port = defaultPort, String ruleName = 'SadatTaxiSync'}) async {
    if (kIsWeb || !Platform.isWindows) return;
    try {
      final exePath = Platform.resolvedExecutable;
      final checkResult = await Process.run('netsh', [
        'advfirewall',
        'firewall',
        'show',
        'rule',
        'name=$ruleName',
      ]);

      if (checkResult.exitCode != 0 || !(checkResult.stdout as String).contains(ruleName)) {
        debugPrint('[LocalSyncServer] Registering Windows Defender Firewall rule for port $port (Private networks)...');
        await Process.run('netsh', [
          'advfirewall',
          'firewall',
          'add',
          'rule',
          'name=$ruleName',
          'dir=in',
          'action=allow',
          'protocol=TCP',
          'localport=$port',
          'profile=private',
          'program=$exePath',
        ]);
      }
    } catch (e) {
      debugPrint('[LocalSyncServer] Windows Firewall rule notice: $e');
    }
  }

  /// Starts the embedded HTTP / WebSocket server on 0.0.0.0:port
  Future<bool> startServer({
    int port = defaultPort,
    FullSyncDataProvider? dataProvider,
  }) async {
    if (_server != null) {
      debugPrint('[LocalSyncServer] Server already running on port ${_server!.port}');
      return true;
    }

    if (dataProvider != null) {
      fullSyncDataProvider = dataProvider;
    }

    // Attempt to register firewall rule on Windows for private network sync
    if (!kIsWeb && Platform.isWindows) {
      await ensureWindowsFirewallRule(port: port);
    }

    try {
      debugPrint('[LocalSyncServer] Binding server on 0.0.0.0:$port...');

      final wsHandler = webSocketHandler((WebSocketChannel channel) {
        _handleClientConnection(channel);
      });

      final cascade = Cascade()
          .add((Request request) {
            if (request.url.path == 'ws' || request.url.path == '') {
              return wsHandler(request);
            }
            if (request.url.path == 'health') {
              return Response.ok(
                jsonEncode({
                  'status': 'ok',
                  'service': 'SadatTaxiSync',
                  'timestamp': DateTime.now().toUtc().toIso8601String(),
                  'clients': _clients.length,
                }),
                headers: {'content-type': 'application/json'},
              );
            }
            return Response.notFound('Sadat Taxi Sync Server');
          })
          .handler;

      final pipeline = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(cascade);

      _server = await shelf_io.serve(
        pipeline,
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );

      debugPrint('[LocalSyncServer] Server listening on http://${_server!.address.address}:${_server!.port}');

      _startHeartbeatTimer();
      _clientsCountController.add(0);
      return true;
    } catch (e, stack) {
      debugPrint('[LocalSyncServer] Failed to start server: $e\n$stack');
      _server = null;
      return false;
    }
  }

  /// Handles incoming WebSocket client connections
  void _handleClientConnection(WebSocketChannel channel) {
    final clientId = 'client_${DateTime.now().millisecondsSinceEpoch}_${_clients.length + 1}';
    final client = ConnectedClient(
      id: clientId,
      channel: channel,
      connectedAt: DateTime.now().toUtc(),
      lastSeen: DateTime.now().toUtc(),
    );

    _clients[clientId] = client;
    _clientsCountController.add(_clients.length);
    debugPrint('[LocalSyncServer] Client connected: $clientId (Total: ${_clients.length})');

    channel.stream.listen(
      (dynamic data) {
        _handleClientMessage(client, data);
      },
      onDone: () {
        debugPrint('[LocalSyncServer] Client disconnected: $clientId');
        _clients.remove(clientId);
        _clientsCountController.add(_clients.length);
      },
      onError: (error) {
        debugPrint('[LocalSyncServer] Client error on $clientId: $error');
        _clients.remove(clientId);
        _clientsCountController.add(_clients.length);
      },
      cancelOnError: true,
    );
  }

  /// Parses and processes messages received from a client
  void _handleClientMessage(ConnectedClient client, dynamic rawData) async {
    try {
      client.lastSeen = DateTime.now().toUtc();
      final str = rawData.toString();
      final message = SyncMessageModel.fromRawJson(str);
      _incomingMessagesController.add(message);

      switch (message.type) {
        case SyncMessageType.handshake:
          client.platform = message.senderPlatform;
          debugPrint('[LocalSyncServer] Received handshake from ${client.id} (${client.platform})');
          // Respond with handshakeAck
          final ack = SyncMessageModel.handshakeAck(
            senderId: 'windows_server',
            platform: Platform.operatingSystem,
            connectedClientsCount: _clients.length,
          );
          _sendToClient(client, ack);
          break;

        case SyncMessageType.heartbeatPing:
          final pong = SyncMessageModel.pong(
            senderId: 'windows_server',
            platform: Platform.operatingSystem,
          );
          _sendToClient(client, pong);
          break;

        case SyncMessageType.heartbeatPong:
          // Keepalive acknowledged
          break;

        case SyncMessageType.mutation:
          if (message.payload != null) {
            debugPrint('[LocalSyncServer] Received mutation from ${client.id}: ${message.payload!.tableName} [${message.payload!.action.name}]');
            _incomingPayloadsController.add(message.payload!);
            // Broadcast mutation to all other connected clients
            _broadcastExcept(client.id, message);
          } else if (message.batchPayloads != null && message.batchPayloads!.isNotEmpty) {
            debugPrint('[LocalSyncServer] Received batch mutation from ${client.id} (${message.batchPayloads!.length} items)');
            _incomingBatchesController.add(message.batchPayloads!);
            _broadcastExcept(client.id, message);
          }
          break;

        case SyncMessageType.fullSyncRequest:
          debugPrint('[LocalSyncServer] Client ${client.id} requested full sync snapshot');
          if (fullSyncDataProvider != null) {
            final snapshot = await fullSyncDataProvider!();
            final response = SyncMessageModel.batchSync(
              senderId: 'windows_server',
              platform: Platform.operatingSystem,
              payloads: snapshot,
              isFullSyncResponse: true,
            );
            _sendToClient(client, response);
            debugPrint('[LocalSyncServer] Sent full sync snapshot (${snapshot.length} items) to ${client.id}');
          }
          break;

        case SyncMessageType.fullSyncResponse:
          if (message.batchPayloads != null) {
            _incomingBatchesController.add(message.batchPayloads!);
          }
          break;

        default:
          debugPrint('[LocalSyncServer] Unhandled message type: ${message.type}');
      }
    } catch (e, stack) {
      debugPrint('[LocalSyncServer] Error parsing client message: $e\n$stack');
    }
  }

  /// Sends a message envelope to a specific client
  void _sendToClient(ConnectedClient client, SyncMessageModel message) {
    try {
      client.channel.sink.add(message.toRawJson());
    } catch (e) {
      debugPrint('[LocalSyncServer] Error sending to client ${client.id}: $e');
    }
  }

  /// Broadcasts a mutation to all connected clients
  void broadcastPayload(SyncPayloadModel payload) {
    if (_clients.isEmpty) return;
    final message = SyncMessageModel.mutation(
      senderId: 'windows_server',
      platform: Platform.operatingSystem,
      payload: payload,
    );
    broadcastMessage(message);
  }

  /// Broadcasts a batch of mutations to all connected clients
  void broadcastBatch(List<SyncPayloadModel> payloads) {
    if (_clients.isEmpty || payloads.isEmpty) return;
    final message = SyncMessageModel.batchSync(
      senderId: 'windows_server',
      platform: Platform.operatingSystem,
      payloads: payloads,
    );
    broadcastMessage(message);
  }

  /// Broadcasts a generic message envelope to all connected clients
  void broadcastMessage(SyncMessageModel message) {
    final raw = message.toRawJson();
    for (final client in _clients.values) {
      try {
        client.channel.sink.add(raw);
      } catch (e) {
        debugPrint('[LocalSyncServer] Error broadcasting to client ${client.id}: $e');
      }
    }
  }

  /// Broadcasts to all clients except the sender
  void _broadcastExcept(String excludeClientId, SyncMessageModel message) {
    final raw = message.toRawJson();
    for (final entry in _clients.entries) {
      if (entry.key != excludeClientId) {
        try {
          entry.value.channel.sink.add(raw);
        } catch (e) {
          debugPrint('[LocalSyncServer] Error broadcasting to ${entry.key}: $e');
        }
      }
    }
  }

  /// Periodic heartbeat timer to ping clients and purge dead sockets
  void _startHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(pingInterval, (_) {
      final now = DateTime.now().toUtc();
      final deadClientIds = <String>[];

      for (final entry in _clients.entries) {
        final client = entry.value;
        // If client hasn't sent anything in over 45s, mark as dead
        if (now.difference(client.lastSeen) > const Duration(seconds: 45)) {
          deadClientIds.add(entry.key);
        } else {
          // Send ping
          final ping = SyncMessageModel.ping(
            senderId: 'windows_server',
            platform: Platform.operatingSystem,
          );
          _sendToClient(client, ping);
        }
      }

      for (final id in deadClientIds) {
        debugPrint('[LocalSyncServer] Purging unresponsive client: $id');
        try {
          _clients[id]?.channel.sink.close();
        } catch (_) {}
        _clients.remove(id);
      }

      if (deadClientIds.isNotEmpty) {
        _clientsCountController.add(_clients.length);
      }
    });
  }

  /// Stops the server and closes all sockets
  Future<void> stopServer() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    for (final client in _clients.values) {
      try {
        await client.channel.sink.close();
      } catch (_) {}
    }
    _clients.clear();
    _clientsCountController.add(0);

    if (_server != null) {
      debugPrint('[LocalSyncServer] Stopping HTTP/WebSocket server...');
      await _server!.close(force: true);
      _server = null;
      debugPrint('[LocalSyncServer] Server stopped successfully');
    }
  }

  /// Disposes all streams
  Future<void> dispose() async {
    await stopServer();
    await _incomingPayloadsController.close();
    await _incomingBatchesController.close();
    await _incomingMessagesController.close();
    await _clientsCountController.close();
  }
}
