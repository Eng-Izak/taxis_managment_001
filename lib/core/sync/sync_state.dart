import '../services/cloud_sync_service.dart';

class SyncState {
  final CloudSyncStatus status;
  final bool isOnline;
  final DateTime? lastSyncTime;
  final int pendingChangesCount;
  final String? userEmail;
  final String? message;

  const SyncState({
    this.status = CloudSyncStatus.synced,
    this.isOnline = true,
    this.lastSyncTime,
    this.pendingChangesCount = 0,
    this.userEmail,
    this.message,
  });

  SyncState copyWith({
    CloudSyncStatus? status,
    bool? isOnline,
    DateTime? lastSyncTime,
    int? pendingChangesCount,
    String? userEmail,
    String? message,
  }) {
    return SyncState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingChangesCount: pendingChangesCount ?? this.pendingChangesCount,
      userEmail: userEmail ?? this.userEmail,
      message: message ?? this.message,
    );
  }
}
