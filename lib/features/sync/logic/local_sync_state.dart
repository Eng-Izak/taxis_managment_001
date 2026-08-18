import '../../../core/network/sync/enums/sync_enums.dart';
import '../../../core/network/sync/discovery/service_discovery_manager.dart';

class LocalSyncState {
  final LocalSyncConnectionState status;
  final bool isServer;
  final String? serverAddress;
  final int connectedClientsCount;
  final DateTime? lastSyncTime;
  final int pendingQueueCount;
  final String? message;
  final List<DiscoveredServerInfo> discoveredServers;
  final bool autoSyncEnabled;

  const LocalSyncState({
    this.status = LocalSyncConnectionState.disconnected,
    this.isServer = false,
    this.serverAddress,
    this.connectedClientsCount = 0,
    this.lastSyncTime,
    this.pendingQueueCount = 0,
    this.message,
    this.discoveredServers = const [],
    this.autoSyncEnabled = true,
  });

  bool get isConnected => status.isConnected;
  bool get isSearching => status == LocalSyncConnectionState.searching;
  bool get isSyncing => status == LocalSyncConnectionState.syncing;

  LocalSyncState copyWith({
    LocalSyncConnectionState? status,
    bool? isServer,
    String? serverAddress,
    int? connectedClientsCount,
    DateTime? lastSyncTime,
    int? pendingQueueCount,
    String? message,
    List<DiscoveredServerInfo>? discoveredServers,
    bool? autoSyncEnabled,
  }) {
    return LocalSyncState(
      status: status ?? this.status,
      isServer: isServer ?? this.isServer,
      serverAddress: serverAddress ?? this.serverAddress,
      connectedClientsCount: connectedClientsCount ?? this.connectedClientsCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingQueueCount: pendingQueueCount ?? this.pendingQueueCount,
      message: message ?? this.message,
      discoveredServers: discoveredServers ?? this.discoveredServers,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
    );
  }
}
