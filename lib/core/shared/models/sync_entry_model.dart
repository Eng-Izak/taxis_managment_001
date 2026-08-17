enum SyncOperationType {
  create,
  update,
  delete,
}

enum SyncEntityType {
  asset,
  shareholder,
  transaction,
  archivedItem,
  settings,
}

class SyncQueueEntry {
  final String id;
  final SyncEntityType entityType;
  final SyncOperationType operation;
  final String entityId;
  final Map<String, dynamic>? payload;
  final DateTime timestamp;

  const SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.entityId,
    this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'operation': operation.name,
      'entityId': entityId,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json) {
    return SyncQueueEntry(
      id: json['id'] as String? ?? '',
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
        orElse: () => SyncEntityType.asset,
      ),
      operation: SyncOperationType.values.firstWhere(
        (e) => e.name == json['operation'],
        orElse: () => SyncOperationType.update,
      ),
      entityId: json['entityId'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
