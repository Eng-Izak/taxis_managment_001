import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../enums/sync_enums.dart';
import 'sync_payload_model.dart';

class SyncMessageModel {
  final String id;
  final SyncMessageType type;
  final String senderId;
  final String senderPlatform;
  final DateTime timestamp;
  final SyncPayloadModel? payload;
  final List<SyncPayloadModel>? batchPayloads;
  final Map<String, dynamic>? extra;

  const SyncMessageModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderPlatform,
    required this.timestamp,
    this.payload,
    this.batchPayloads,
    this.extra,
  });

  factory SyncMessageModel.handshake({
    required String senderId,
    required String platform,
    String? clientVersion,
  }) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: SyncMessageType.handshake,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
      extra: {'version': clientVersion ?? '1.0.0'},
    );
  }

  factory SyncMessageModel.handshakeAck({
    required String senderId,
    required String platform,
    required int connectedClientsCount,
  }) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: SyncMessageType.handshakeAck,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
      extra: {'clients': connectedClientsCount},
    );
  }

  factory SyncMessageModel.ping({required String senderId, required String platform}) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: SyncMessageType.heartbeatPing,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncMessageModel.pong({required String senderId, required String platform}) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: SyncMessageType.heartbeatPong,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
    );
  }

  factory SyncMessageModel.mutation({
    required String senderId,
    required String platform,
    required SyncPayloadModel payload,
  }) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: SyncMessageType.mutation,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
      payload: payload,
    );
  }

  factory SyncMessageModel.batchSync({
    required String senderId,
    required String platform,
    required List<SyncPayloadModel> payloads,
    bool isFullSyncResponse = false,
  }) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: isFullSyncResponse ? SyncMessageType.fullSyncResponse : SyncMessageType.mutation,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
      batchPayloads: payloads,
    );
  }

  factory SyncMessageModel.fullSyncRequest({
    required String senderId,
    required String platform,
  }) {
    return SyncMessageModel(
      id: const Uuid().v4(),
      type: SyncMessageType.fullSyncRequest,
      senderId: senderId,
      senderPlatform: platform,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'senderId': senderId,
      'senderPlatform': senderPlatform,
      'timestamp': timestamp.toUtc().toIso8601String(),
      if (payload != null) 'payload': payload!.toJson(),
      if (batchPayloads != null) 'batchPayloads': batchPayloads!.map((p) => p.toJson()).toList(),
      if (extra != null) 'extra': extra,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory SyncMessageModel.fromJson(Map<String, dynamic> json) {
    return SyncMessageModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: SyncMessageType.fromString(json['type'] as String? ?? 'error'),
      senderId: json['senderId'] as String? ?? 'unknown',
      senderPlatform: json['senderPlatform'] as String? ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)?.toUtc() ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      payload: json['payload'] != null ? SyncPayloadModel.fromJson(json['payload'] as Map<String, dynamic>) : null,
      batchPayloads: json['batchPayloads'] != null
          ? (json['batchPayloads'] as List<dynamic>)
              .map((p) => SyncPayloadModel.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  factory SyncMessageModel.fromRawJson(String str) {
    final decoded = jsonDecode(str) as Map<String, dynamic>;
    return SyncMessageModel.fromJson(decoded);
  }
}
