import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String id;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String receiverName;
  final String callType;
  final String status;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int duration;

  const CallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.receiverName,
    required this.callType,
    required this.status,
    this.createdAt,
    this.startedAt,
    this.endedAt,
    required this.duration,
  });

  factory CallModel.create({
    required String id,
    required String callerId,
    required String receiverId,
    required String callerName,
    required String receiverName,
    required String callType,
  }) {
    return CallModel(
      id: id,
      callerId: callerId,
      receiverId: receiverId,
      callerName: callerName,
      receiverName: receiverName,
      callType: callType,
      status: 'ongoing',
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
      endedAt: null,
      duration: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'callType': callType,
      'status': status,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'duration': duration,
    };
  }

  factory CallModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return CallModel(
      id: id,
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      callType: map['callType'] ?? 'audio',
      status: map['status'] ?? 'completed',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      startedAt: map['startedAt'] is Timestamp
          ? (map['startedAt'] as Timestamp).toDate()
          : null,
      endedAt: map['endedAt'] is Timestamp
          ? (map['endedAt'] as Timestamp).toDate()
          : null,
      duration: map['duration'] ?? 0,
    );
  }
}