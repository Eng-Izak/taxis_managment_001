import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../enums/sync_enums.dart';
import '../models/sync_payload_model.dart';
import '../models/sync_message_model.dart';
import '../discovery/service_discovery_manager.dart';

class LocalSyncClient {
  static const int defaultPort = 8080;

  final ServiceDiscoveryManager discoveryManager;
  final Connectivity _connectivity;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<List<DiscoveredServerInfo>>? _discoverySubscription;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  String? _currentTargetHost;
  int _currentTargetPort = defaultPort;
  bool _isAutoConnectEnabled = true;

  final _connectionStateController = StreamController<LocalSyncConnectionState>.broadcast();
  final _incomingPayloadsController = StreamController<SyncPayloadModel>.broadcast();
  final _incomingBatchesController = StreamController<List<SyncPayloadModel>>.broadcast();
  final _incomingMessagesController = StreamController<SyncMessageModel>.broadcast();
  final _connectedServerHostController = StreamController<String?>.broadcast();

  LocalSyncConnectionState _currentState = LocalSyncConnectionState.disconnected;
  String? _connectedServerHost;

  final String clientId = 'client_android_${const Uuid().v4().substring(0, 8)}';

  LocalSyncClient({
    required this.discoveryManager,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity() {
    _initConnectivityListener();
  }

  LocalSyncConnectionState get connectionState => _currentState;
  String? get connectedServerHost => _connectedServerHost;
  bool get isConnected => _currentState == LocalSyncConnectionState.connected || _currentState == LocalSyncConnectionState.syncing;

  Stream<LocalSyncConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<SyncPayloadModel> get incomingPayloads => _incomingPayloadsController.stream;
  Stream<List<SyncPayloadModel>> get incomingBatches => _incomingBatchesController.stream;
  Stream<SyncMessageModel> get incomingMessages => _incomingMessagesController.stream;
  Stream<String?> get connectedServerHostStream => _connectedServerHostController.stream;

  void _updateState(LocalSyncConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
  }

  /// Initializes connectivity listener to auto-discover when Wi-Fi is active
  void _initConnectivityListener() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          final isWifi = results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.ethernet);
          debugPrint('[LocalSyncClient] Connectivity changed: $results (isWifi: $isWifi)');

          if (isWifi && _isAutoConnectEnabled && !isConnected) {
            autoDiscoverAndConnect();
          } else if (!isWifi && isConnected) {
            disconnect(reason: 'Lost Wi-Fi connectivity');
          }
        },
        onError: (error) {
          debugPrint('[LocalSyncClient] Connectivity listener warning (will retry on full restart): $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[LocalSyncClient] Connectivity init exception: $e');
    }
  }

  /// Triggers mDNS discovery and auto-connects to the first available Windows server
  Future<void> autoDiscoverAndConnect() async {
    if (isConnected || _currentState == LocalSyncConnectionState.connecting) return;

    _updateState(LocalSyncConnectionState.searching);
    debugPrint('[LocalSyncClient] Starting auto-discovery for local sync servers...');

    await _discoverySubscription?.cancel();
    _discoverySubscription = discoveryManager.discoveredServersStream.listen((servers) {
      if (servers.isNotEmpty && !isConnected && _currentState != LocalSyncConnectionState.connecting) {
        final target = servers.first;
        final host = target.primaryIp ?? target.host;
        debugPrint('[LocalSyncClient] Auto-discovered target server: ${target.name} ($host:${target.port})');
        if (host.isNotEmpty) {
          connectTo(host, port: target.port);
        }
      }
    });

    await discoveryManager.startDiscovery();
  }

  /// Connects to a specific server host & port via WebSocket
  Future<bool> connectTo(String host, {int port = defaultPort}) async {
    _reconnectTimer?.cancel();
    _currentTargetHost = host;
    _currentTargetPort = port;

    await _cleanupChannel();
    _updateState(LocalSyncConnectionState.connecting);
    debugPrint('[LocalSyncClient] Connecting to ws://$host:$port/ws...');

    try {
      final uri = Uri.parse('ws://$host:$port/ws');
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _connectedServerHost = '$host:$port';
      _connectedServerHostController.add(_connectedServerHost);
      _reconnectAttempts = 0;

      // Start listening to incoming server messages
      _channelSubscription = _channel!.stream.listen(
        _handleServerData,
        onDone: () {
          debugPrint('[LocalSyncClient] WebSocket connection closed by server');
          _handleDisconnection();
        },
        onError: (error) {
          debugPrint('[LocalSyncClient] WebSocket error: $error');
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      // Perform Handshake
      final handshake = SyncMessageModel.handshake(
        senderId: clientId,
        platform: Platform.operatingSystem,
      );
      sendEnvelope(handshake);

      _updateState(LocalSyncConnectionState.connected);
      debugPrint('[LocalSyncClient] Successfully connected to ws://$host:$port/ws');
      return true;
    } catch (e, stack) {
      debugPrint('[LocalSyncClient] Failed to connect to $host:$port: $e\n$stack');
      _handleDisconnection();
      return false;
    }
  }

  /// Processes raw incoming messages from the server
  void _handleServerData(dynamic rawData) {
    try {
      final str = rawData.toString();
      final message = SyncMessageModel.fromRawJson(str);
      _incomingMessagesController.add(message);

      switch (message.type) {
        case SyncMessageType.handshakeAck:
          debugPrint('[LocalSyncClient] Handshake acknowledged by server');
          _updateState(LocalSyncConnectionState.connected);
          // Automatically request full sync to ensure local database is up to date
          requestFullSync();
          break;

        case SyncMessageType.heartbeatPing:
          // Immediately respond with pong
          final pong = SyncMessageModel.pong(
            senderId: clientId,
            platform: Platform.operatingSystem,
          );
          sendEnvelope(pong);
          break;

        case SyncMessageType.heartbeatPong:
          // Ping-pong confirmed
          break;

        case SyncMessageType.mutation:
          if (message.payload != null) {
            debugPrint('[LocalSyncClient] Incoming mutation: ${message.payload!.tableName} [${message.payload!.action.name}]');
            _incomingPayloadsController.add(message.payload!);
          } else if (message.batchPayloads != null && message.batchPayloads!.isNotEmpty) {
            debugPrint('[LocalSyncClient] Incoming batch mutation: ${message.batchPayloads!.length} items');
            _incomingBatchesController.add(message.batchPayloads!);
          }
          break;

        case SyncMessageType.fullSyncResponse:
          if (message.batchPayloads != null) {
            debugPrint('[LocalSyncClient] Incoming full sync snapshot: ${message.batchPayloads!.length} records');
            _updateState(LocalSyncConnectionState.syncing);
            _incomingBatchesController.add(message.batchPayloads!);
            _updateState(LocalSyncConnectionState.connected);
          }
          break;

        default:
          debugPrint('[LocalSyncClient] Unhandled message: ${message.type}');
      }
    } catch (e, stack) {
      debugPrint('[LocalSyncClient] Error processing server message: $e\n$stack');
    }
  }

  /// Sends a single mutation payload to the server
  bool sendPayload(SyncPayloadModel payload) {
    if (!isConnected) {
      debugPrint('[LocalSyncClient] Cannot send payload - not connected');
      return false;
    }
    final message = SyncMessageModel.mutation(
      senderId: clientId,
      platform: Platform.operatingSystem,
      payload: payload,
    );
    return sendEnvelope(message);
  }

  /// Sends a batch of mutations to the server
  bool sendBatch(List<SyncPayloadModel> payloads) {
    if (!isConnected || payloads.isEmpty) return false;
    final message = SyncMessageModel.batchSync(
      senderId: clientId,
      platform: Platform.operatingSystem,
      payloads: payloads,
    );
    return sendEnvelope(message);
  }

  /// Requests a full state snapshot from the server
  bool requestFullSync() {
    if (!isConnected) return false;
    final message = SyncMessageModel.fullSyncRequest(
      senderId: clientId,
      platform: Platform.operatingSystem,
    );
    return sendEnvelope(message);
  }

  /// Low-level envelope dispatch
  bool sendEnvelope(SyncMessageModel message) {
    try {
      if (_channel != null) {
        _channel!.sink.add(message.toRawJson());
        return true;
      }
    } catch (e) {
      debugPrint('[LocalSyncClient] Error sending envelope: $e');
    }
    return false;
  }

  /// Handles disconnection and initiates exponential backoff reconnect
  void _handleDisconnection() {
    _cleanupChannel();
    _connectedServerHost = null;
    _connectedServerHostController.add(null);
    _updateState(LocalSyncConnectionState.disconnected);

    if (_isAutoConnectEnabled && _currentTargetHost != null) {
      _scheduleReconnect();
    }
  }

  /// Exponential backoff reconnect strategy: 2s -> 4s -> 8s -> 16s -> max 30s
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    final delaySeconds = (_reconnectAttempts <= 4) ? (1 << _reconnectAttempts) : 30;

    debugPrint('[LocalSyncClient] Scheduling reconnect attempt #$_reconnectAttempts in $delaySeconds seconds...');
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_currentTargetHost != null && !isConnected) {
        connectTo(_currentTargetHost!, port: _currentTargetPort);
      }
    });
  }

  /// Cleans up WebSocket and subscription resources
  Future<void> _cleanupChannel() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  /// Disconnects manually and cancels auto-reconnect
  Future<void> disconnect({String? reason}) async {
    debugPrint('[LocalSyncClient] Disconnecting: ${reason ?? "manual"}');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    await _cleanupChannel();
    _connectedServerHost = null;
    _connectedServerHostController.add(null);
    _updateState(LocalSyncConnectionState.disconnected);
  }

  /// Disposes all resources
  Future<void> dispose() async {
    _isAutoConnectEnabled = false;
    await disconnect();
    await _connectivitySubscription?.cancel();
    await _discoverySubscription?.cancel();
    await _connectionStateController.close();
    await _incomingPayloadsController.close();
    await _incomingBatchesController.close();
    await _incomingMessagesController.close();
    await _connectedServerHostController.close();
  }
}
