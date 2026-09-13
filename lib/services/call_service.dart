import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/call_model.dart';

class CallService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Save a call record
  Future<void> createCall(CallModel call) async {
    await _firestore
        .collection('calls')
        .doc(call.id)
        .set(call.toMap());
  }

  // Get call history of current user
  Stream<List<CallModel>> getCallHistory(
      String userId,
      ) {
    return _firestore
        .collection('calls')
        .snapshots()
        .map((snapshot) {
      final List<CallModel> calls = snapshot.docs
          .map(
            (doc) => CallModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .where((call) {
        return call.callerId == userId ||
            call.receiverId == userId;
      }).toList();

      // Sort latest calls first
      calls.sort((a, b) {
        final DateTime aTime =
            a.createdAt ??
                a.startedAt ??
                DateTime(1970);

        final DateTime bTime =
            b.createdAt ??
                b.startedAt ??
                DateTime(1970);

        return bTime.compareTo(aTime);
      });

      return calls;
    });
  }
  // Update an existing call record
  Future<void> updateCall(
      String callId,
      Map<String, dynamic> data,
      ) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .update(data);
  }

  // Delete a call record
  Future<void> deleteCall(String callId) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .delete();
  }
}