enum SyncAction {
  insert,
  update,
  delete;

  String get value => name;

  static SyncAction fromString(String val) {
    return SyncAction.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SyncAction.update,
    );
  }
}

enum SyncMessageType {
  handshake,
  handshakeAck,
  heartbeatPing,
  heartbeatPong,
  mutation,
  fullSyncRequest,
  fullSyncResponse,
  ack,
  error;

  String get value => name;

  static SyncMessageType fromString(String val) {
    return SyncMessageType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SyncMessageType.error,
    );
  }
}

enum LocalSyncConnectionState {
  disconnected,
  searching,
  connecting,
  connected,
  syncing,
  serverRunning,
  error;

  bool get isConnected => this == LocalSyncConnectionState.connected || this == LocalSyncConnectionState.syncing || this == LocalSyncConnectionState.serverRunning;
  bool get isServer => this == LocalSyncConnectionState.serverRunning;
}
