import 'package:uuid/uuid.dart';
import '../enums/sync_enums.dart';

class SyncPayloadModel {
  final String uuid;
  final String tableName;
  final SyncAction action;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isDeleted;
  final bool isSynced;

  const SyncPayloadModel({
    required this.uuid,
    required this.tableName,
    required this.action,
    required this.data,
    required this.timestamp,
    this.isDeleted = false,
    this.isSynced = true,
  });

  factory SyncPayloadModel.create({
    required String tableName,
    required SyncAction action,
    required Map<String, dynamic> data,
    String? recordId,
    bool isDeleted = false,
  }) {
    return SyncPayloadModel(
      uuid: recordId ?? const Uuid().v4(),
      tableName: tableName,
      action: action,
      data: data,
      timestamp: DateTime.now().toUtc(),
      isDeleted: isDeleted || action == SyncAction.delete,
      isSynced: false,
    );
  }

  /// Evaluates Last-Write-Wins (LWW) between this incoming payload and an existing timestamp
  bool winsAgainst(DateTime existingTimestamp, {bool existingIsDeleted = false}) {
    // If incoming is soft-delete and equal or newer timestamp, delete wins
    if (isDeleted && (timestamp.isAfter(existingTimestamp) || timestamp.isAtSameMomentAs(existingTimestamp))) {
      return true;
    }
    // If existing was deleted at a later or equal time, existing deletion wins
    if (existingIsDeleted && (existingTimestamp.isAfter(timestamp) || existingTimestamp.isAtSameMomentAs(timestamp))) {
      return false;
    }
    return timestamp.isAfter(existingTimestamp);
  }

  SyncPayloadModel copyWith({
    String? uuid,
    String? tableName,
    SyncAction? action,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return SyncPayloadModel(
      uuid: uuid ?? this.uuid,
      tableName: tableName ?? this.tableName,
      action: action ?? this.action,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'tableName': tableName,
      'action': action.value,
      'data': data,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
    };
  }

  factory SyncPayloadModel.fromJson(Map<String, dynamic> json) {
    return SyncPayloadModel(
      uuid: json['uuid'] as String? ?? const Uuid().v4(),
      tableName: json['tableName'] as String? ?? 'general',
      action: SyncAction.fromString(json['action'] as String? ?? 'update'),
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)?.toUtc() ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      isDeleted: json['isDeleted'] as bool? ?? (json['action'] == 'delete'),
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  @override
  String toString() => 'SyncPayloadModel(uuid: $uuid, table: $tableName, action: ${action.name}, time: $timestamp, deleted: $isDeleted)';
}
