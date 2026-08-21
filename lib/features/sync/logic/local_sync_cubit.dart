import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/sync/discovery/service_discovery_manager.dart';
import '../../../core/network/sync/server/local_sync_server.dart';
import '../../../core/network/sync/client/local_sync_client.dart';
import '../../../core/network/sync/repository/local_sync_repository.dart';
import '../../../core/network/sync/models/sync_payload_model.dart';
import '../../../core/network/sync/enums/sync_enums.dart';
import '../../../core/shared/models/sync_entry_model.dart';
import '../../../core/services/local_storage_service.dart';
import 'local_sync_state.dart';

class LocalSyncCubit extends Cubit<LocalSyncState> {
  final ServiceDiscoveryManager discoveryManager;
  final LocalSyncServer server;
  final LocalSyncClient client;
  final LocalSyncRepository repository;
  final LocalStorageService storage;

  StreamSubscription<dynamic>? _serverPayloadSub;
  StreamSubscription<dynamic>? _serverBatchSub;
  StreamSubscription<int>? _serverClientsCountSub;

  StreamSubscription<LocalSyncConnectionState>? _clientStateSub;
  StreamSubscription<dynamic>? _clientPayloadSub;
  StreamSubscription<dynamic>? _clientBatchSub;
  StreamSubscription<List<DiscoveredServerInfo>>? _discoverySub;
  StreamSubscription<SyncQueueEntry>? _storageMutationSub;

  LocalSyncCubit({
    required this.discoveryManager,
    required this.server,
    required this.client,
    required this.repository,
    required this.storage,
  }) : super(LocalSyncState(
          lastSyncTime: storage.getLastSyncTime(),
          pendingQueueCount: storage.getSyncQueue().length,
          autoSyncEnabled: storage.getCurrentUser()?.autoSyncEnabled ?? true,
        )) {
    _storageMutationSub = storage.mutationEvents.listen((entry) {
      _broadcastLocalMutation(entry);
    });
  }

  /// Auto-initializes platform-appropriate sync mode (Server on Windows, Client on Android)
  Future<void> initPlatformSync() async {
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    if (isDesktop) {
      await startServerIfDesktop();
    } else {
      await autoDiscoverAndConnect();
    }
  }

  /// Starts the embedded sync server (Windows / Desktop)
  Future<bool> startServerIfDesktop({int port = LocalSyncServer.defaultPort}) async {
    emit(state.copyWith(
      status: LocalSyncConnectionState.connecting,
      isServer: true,
      message: 'جاري تشغيل خادم المزامنة المحلي على الويندوز...',
    ));

    // Bind server with full snapshot provider
    final success = await server.startServer(
      port: port,
      dataProvider: () async => repository.generateFullSnapshot(),
    );

    if (!success) {
      emit(state.copyWith(
        status: LocalSyncConnectionState.error,
        message: 'فشل في تشغيل الخادم المحلي على المنفذ $port',
      ));
      return false;
    }

    // Register mDNS service for zero-config discovery by Android devices
    await discoveryManager.registerServer(port: port);

    // Listen to incoming mutations from Android clients
    await _serverPayloadSub?.cancel();
    _serverPayloadSub = server.incomingPayloads.listen((payload) {
      repository.applyIncomingPayload(payload);
      emit(state.copyWith(
        lastSyncTime: DateTime.now().toUtc(),
        pendingQueueCount: storage.getSyncQueue().length,
        message: 'تم استقبال وتطبيق تحديث جديد من الهاتف المتصل',
      ));
    });

    await _serverBatchSub?.cancel();
    _serverBatchSub = server.incomingBatches.listen((batch) {
      repository.applyBatchSync(batch);
      emit(state.copyWith(
        lastSyncTime: DateTime.now().toUtc(),
        pendingQueueCount: storage.getSyncQueue().length,
        message: 'تمت مزامنة وتطبيق حزمة بيانات كاملة من هاتف الأندرويد',
      ));
    });

    await _serverClientsCountSub?.cancel();
    _serverClientsCountSub = server.clientsCountStream.listen((count) {
      emit(state.copyWith(
        connectedClientsCount: count,
        message: count > 0 ? 'متصل حالياً مع $count أجهزة أندرويد' : 'في انتظار اتصال هواتف الأندرويد...',
      ));
    });

    // Detect primary local IP address
    String? localIp;
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254')) {
            localIp = addr.address;
            break;
          }
        }
        if (localIp != null) break;
      }
    } catch (_) {}

    emit(state.copyWith(
      status: LocalSyncConnectionState.serverRunning,
      isServer: true,
      serverAddress: localIp != null ? '$localIp:$port' : '0.0.0.0:$port',
      connectedClientsCount: server.connectedClientsCount,
      lastSyncTime: storage.getLastSyncTime(),
      message: 'خادم المزامنة قيد التشغيل على $localIp:$port',
    ));

    return true;
  }

  /// Triggers mDNS discovery and auto-connects to Windows server (Android Client)
  Future<void> autoDiscoverAndConnect() async {
    emit(state.copyWith(
      status: LocalSyncConnectionState.searching,
      isServer: false,
      message: 'جاري البحث عن خادم الويندوز على الشبكة المحلية...',
    ));

    // Listen to discovered servers
    await _discoverySub?.cancel();
    _discoverySub = discoveryManager.discoveredServersStream.listen((servers) {
      emit(state.copyWith(discoveredServers: servers));
    });

    // Listen to client connection status
    await _clientStateSub?.cancel();
    _clientStateSub = client.connectionStateStream.listen((connState) {
      emit(state.copyWith(
        status: connState,
        serverAddress: client.connectedServerHost,
        lastSyncTime: storage.getLastSyncTime(),
        pendingQueueCount: storage.getSyncQueue().length,
        message: _getLocalizedClientStatus(connState),
      ));

      if (connState == LocalSyncConnectionState.connected) {
        _onClientConnected();
      }
    });

    // Listen to incoming mutations from server
    await _clientPayloadSub?.cancel();
    _clientPayloadSub = client.incomingPayloads.listen((payload) {
      repository.applyIncomingPayload(payload);
      emit(state.copyWith(
        lastSyncTime: DateTime.now().toUtc(),
        pendingQueueCount: storage.getSyncQueue().length,
        message: 'تم استلام وتطبيق تحديث لحظي من الخادم',
      ));
    });

    await _clientBatchSub?.cancel();
    _clientBatchSub = client.incomingBatches.listen((batch) {
      repository.applyBatchSync(batch);
      storage.clearSyncQueue();
      emit(state.copyWith(
        lastSyncTime: DateTime.now().toUtc(),
        pendingQueueCount: 0,
        message: 'تمت مزامنة قاعدة البيانات بالكامل مع خادم الويندوز بنجاح',
      ));
    });

    await client.autoDiscoverAndConnect();
  }

  /// Called whenever the Android client successfully establishes connection with Windows server
  void _onClientConnected() {
    final queue = storage.getSyncQueue();
    if (queue.isNotEmpty) {
      final payloads = queue.map((e) => SyncPayloadModel(
        uuid: e.entityId,
        tableName: _mapEntityTypeToTableName(e.entityType),
        action: _mapOpTypeToSyncAction(e.operation),
        data: e.payload ?? {},
        timestamp: e.timestamp,
        isDeleted: e.operation == SyncOperationType.delete,
      )).toList();
      debugPrint('[LocalSyncCubit] Pushing ${payloads.length} queued offline mutations to Windows server');
      client.sendBatch(payloads);
    }
    client.requestFullSync();
  }

  /// Broadcasts a local mutation to connected peer(s)
  void _broadcastLocalMutation(SyncQueueEntry entry) {
    final tableName = _mapEntityTypeToTableName(entry.entityType);
    final action = _mapOpTypeToSyncAction(entry.operation);
    final payload = SyncPayloadModel(
      uuid: entry.entityId,
      tableName: tableName,
      action: action,
      data: entry.payload ?? {},
      timestamp: entry.timestamp,
      isDeleted: entry.operation == SyncOperationType.delete,
    );

    if (state.isServer && server.isRunning) {
      server.broadcastPayload(payload);
    } else if (!state.isServer && client.isConnected) {
      client.sendPayload(payload);
    }

    emit(state.copyWith(
      lastSyncTime: DateTime.now().toUtc(),
      pendingQueueCount: storage.getSyncQueue().length,
    ));
  }

  /// Connects to a specific IP address entered manually by user
  Future<bool> connectToManualIp(String host, {int port = LocalSyncServer.defaultPort}) async {
    emit(state.copyWith(
      status: LocalSyncConnectionState.connecting,
      message: 'جاري الاتصال بـ $host:$port...',
    ));
    final success = await client.connectTo(host, port: port);
    if (!success) {
      emit(state.copyWith(
        status: LocalSyncConnectionState.disconnected,
        message: 'تعذر الاتصال بالخادم على $host:$port. تأكد من تشغيل نسخة الويندوز على نفس الشبكة.',
      ));
    }
    return success;
  }

  /// Sends a local database mutation to connected peer(s) or queues it offline
  void sendRecord({
    required String tableName,
    required SyncAction action,
    required Map<String, dynamic> data,
    String? recordId,
    bool isDeleted = false,
  }) {
    final payload = SyncPayloadModel.create(
      tableName: tableName,
      action: action,
      data: data,
      recordId: recordId,
      isDeleted: isDeleted,
    );

    if (state.isServer && server.isRunning) {
      server.broadcastPayload(payload);
    } else if (!state.isServer && client.isConnected) {
      client.sendPayload(payload);
    }

    emit(state.copyWith(
      lastSyncTime: DateTime.now().toUtc(),
      pendingQueueCount: storage.getSyncQueue().length,
    ));
  }

  /// Triggers a full bidirectional sync refresh
  Future<void> triggerManualSync() async {
    if (state.isServer && server.isRunning) {
      emit(state.copyWith(status: LocalSyncConnectionState.syncing, message: 'جاري بث أحدث البيانات للعملاء...'));
      final snapshot = repository.generateFullSnapshot();
      server.broadcastBatch(snapshot);
      emit(state.copyWith(
        status: LocalSyncConnectionState.serverRunning,
        lastSyncTime: DateTime.now().toUtc(),
        message: 'تم إرسال حزمة المزامنة الكاملة (${snapshot.length} سجل)',
      ));
    } else if (!state.isServer) {
      if (client.isConnected) {
        emit(state.copyWith(status: LocalSyncConnectionState.syncing, message: 'جاري إرسال التعديلات وطلب التحديث الشامل...'));
        
        // 1. Send all pending offline queue entries
        final queue = storage.getSyncQueue();
        if (queue.isNotEmpty) {
          final payloads = queue.map((e) => SyncPayloadModel(
            uuid: e.entityId,
            tableName: _mapEntityTypeToTableName(e.entityType),
            action: _mapOpTypeToSyncAction(e.operation),
            data: e.payload ?? {},
            timestamp: e.timestamp,
            isDeleted: e.operation == SyncOperationType.delete,
          )).toList();
          client.sendBatch(payloads);
        } else {
          // Send full local snapshot to ensure server has any local additions
          final localSnapshot = repository.generateFullSnapshot();
          if (localSnapshot.isNotEmpty) {
            client.sendBatch(localSnapshot);
          }
        }

        // 2. Request full sync from server
        client.requestFullSync();
      } else {
        await autoDiscoverAndConnect();
      }
    }
  }

  /// Toggles automatic local synchronization
  void toggleAutoSync(bool enabled) {
    final user = storage.getCurrentUser();
    if (user != null) {
      final updated = user.copyWith(autoSyncEnabled: enabled);
      storage.setCurrentUser(updated);
    }
    emit(state.copyWith(autoSyncEnabled: enabled));
  }

  String _mapEntityTypeToTableName(SyncEntityType type) {
    switch (type) {
      case SyncEntityType.asset:
        return 'assets';
      case SyncEntityType.shareholder:
        return 'shareholders';
      case SyncEntityType.transaction:
        return 'transactions';
      case SyncEntityType.archivedItem:
        return 'archived';
      case SyncEntityType.settings:
        return 'settings';
    }
  }

  SyncAction _mapOpTypeToSyncAction(SyncOperationType op) {
    switch (op) {
      case SyncOperationType.create:
        return SyncAction.insert;
      case SyncOperationType.update:
        return SyncAction.update;
      case SyncOperationType.delete:
        return SyncAction.delete;
    }
  }

  String _getLocalizedClientStatus(LocalSyncConnectionState status) {
    switch (status) {
      case LocalSyncConnectionState.searching:
        return 'جاري البحث عن خادم الويندوز...';
      case LocalSyncConnectionState.connecting:
        return 'جاري إنشاء اتصال آمن بالخادم...';
      case LocalSyncConnectionState.connected:
        return 'متصل ومزامن بالكامل مع خادم الويندوز';
      case LocalSyncConnectionState.syncing:
        return 'جاري تبادل ومزامنة البيانات...';
      case LocalSyncConnectionState.serverRunning:
        return 'خادم المزامنة المحلي قيد التشغيل';
      case LocalSyncConnectionState.disconnected:
      case LocalSyncConnectionState.error:
        return 'غير متصل بالخادم المحلي';
    }
  }

  @override
  Future<void> close() {
    _storageMutationSub?.cancel();
    _serverPayloadSub?.cancel();
    _serverBatchSub?.cancel();
    _serverClientsCountSub?.cancel();
    _clientStateSub?.cancel();
    _clientPayloadSub?.cancel();
    _clientBatchSub?.cancel();
    _discoverySub?.cancel();
    return super.close();
  }
}
