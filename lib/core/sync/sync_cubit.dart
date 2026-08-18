import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/cloud_sync_service.dart';
import '../services/local_storage_service.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final CloudSyncService _syncService;
  final LocalStorageService _storageService;
  StreamSubscription<CloudSyncStatus>? _statusSubscription;

  SyncCubit({
    required CloudSyncService syncService,
    required LocalStorageService storageService,
  })  : _syncService = syncService,
        _storageService = storageService,
        super(SyncState(
          status: CloudSyncStatus.synced,
          isOnline: syncService.isOnline,
          lastSyncTime: storageService.getLastSyncTime(),
          pendingChangesCount: storageService.getSyncQueue().length,
          userEmail: storageService.getCurrentUser()?.email,
          autoSyncEnabled: storageService.getCurrentUser()?.autoSyncEnabled ?? true,
        )) {
    _init();
  }

  void _init() {
    _statusSubscription = _syncService.statusStream.listen((status) {
      final queue = _storageService.getSyncQueue();
      final user = _storageService.getCurrentUser();
      emit(state.copyWith(
        status: status,
        isOnline: _syncService.isOnline,
        lastSyncTime: _storageService.getLastSyncTime(),
        pendingChangesCount: queue.length,
        userEmail: user?.email,
        autoSyncEnabled: user?.autoSyncEnabled ?? true,
      ));
    });
  }

  Future<SyncResult> triggerSync({bool force = false}) async {
    emit(state.copyWith(status: CloudSyncStatus.syncing));
    final result = await _syncService.syncNow(force: force);
    final queue = _storageService.getSyncQueue();
    final user = _storageService.getCurrentUser();

    emit(state.copyWith(
      status: result.isOnline ? CloudSyncStatus.synced : CloudSyncStatus.offline,
      isOnline: result.isOnline,
      lastSyncTime: result.lastSyncTime ?? _storageService.getLastSyncTime(),
      pendingChangesCount: queue.length,
      userEmail: user?.email,
      autoSyncEnabled: user?.autoSyncEnabled ?? true,
      message: result.message,
    ));

    return result;
  }

  void toggleAutoSync(bool enabled) {
    final user = _storageService.getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(autoSyncEnabled: enabled);
      _storageService.setCurrentUser(updatedUser);
      emit(state.copyWith(userEmail: updatedUser.email, autoSyncEnabled: enabled));
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
