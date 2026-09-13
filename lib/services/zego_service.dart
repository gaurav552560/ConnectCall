import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoService {
  static const int appID = 1881649304;

  static const String appSign = 'ac482a86ddeda993ec5b56c0c7ff5245a2cc2a8173dc93a832b96e636a0d7a1d';

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static String? _activeCallId;
  static DateTime? _callStartedAt;
  static bool _callConnected = false;

  static Future<void> initialize({
    required String userID,
    required String userName,
  }) async {
    final ZegoUIKitSignalingPlugin signalingPlugin =
    ZegoUIKitSignalingPlugin();

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: [
        signalingPlugin,
      ],
      invitationEvents:
      ZegoUIKitPrebuiltCallInvitationEvents(
        onOutgoingCallSent: (
            String callID,
            ZegoCallUser caller,
            ZegoCallInvitationType callType,
            List<ZegoCallUser> callees,
            String customData,
            ) async {
          if (callees.isEmpty) {
            return;
          }

          final ZegoCallUser callee = callees.first;

          _activeCallId = callID;
          _callConnected = false;
          _callStartedAt = null;

          await _createCallRecord(
            callID: callID,
            callerId: caller.id,
            callerName: caller.name,
            receiverId: callee.id,
            receiverName: callee.name,
            callType: callType,
          );
        },

        onOutgoingCallAccepted: (
            String callID,
            ZegoCallUser callee,
            ) async {
          _activeCallId = callID;
          _callConnected = true;
          _callStartedAt = DateTime.now();

          await _updateCallRecord(
            callID,
            {
              'status': 'ongoing',
              'startedAt': Timestamp.fromDate(
                _callStartedAt!,
              ),
            },
          );
        },

        onOutgoingCallDeclined: (
            String callID,
            ZegoCallUser callee,
            String customData,
            ) async {
          await _updateCallRecord(
            callID,
            {
              'status': 'declined',
              'endedAt': Timestamp.now(),
              'duration': 0,
            },
          );

          _clearActiveCall();
        },

        onOutgoingCallTimeout: (
            String callID,
            List<ZegoCallUser> callees,
            bool isVideoCall,
            ) async {
          await _updateCallRecord(
            callID,
            {
              'status': 'missed',
              'endedAt': Timestamp.now(),
              'duration': 0,
            },
          );

          _clearActiveCall();
        },

        onIncomingCallReceived: (
            String callID,
            ZegoCallUser caller,
            ZegoCallInvitationType callType,
            List<ZegoCallUser> callees,
            String customData,
            ) async {
          _activeCallId = callID;
          _callConnected = false;
          _callStartedAt = null;
        },

        onIncomingCallAcceptButtonPressed: () async {
          if (_activeCallId == null) {
            return;
          }

          _callConnected = true;
          _callStartedAt = DateTime.now();

          await _updateCallRecord(
            _activeCallId!,
            {
              'status': 'ongoing',
              'startedAt': Timestamp.fromDate(
                _callStartedAt!,
              ),
            },
          );
        },

        onIncomingCallDeclineButtonPressed: () async {
          if (_activeCallId == null) {
            return;
          }

          await _updateCallRecord(
            _activeCallId!,
            {
              'status': 'declined',
              'endedAt': Timestamp.now(),
              'duration': 0,
            },
          );

          _clearActiveCall();
        },

        onIncomingCallTimeout: (
            String callID,
            ZegoCallUser caller,
            ) async {
          await _updateCallRecord(
            callID,
            {
              'status': 'missed',
              'endedAt': Timestamp.now(),
              'duration': 0,
            },
          );

          _clearActiveCall();
        },
      ),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (
            ZegoCallEndEvent event,
            VoidCallback defaultAction,
            ) async {
          await _finishCallRecord(event.callID);
          defaultAction.call();
        },
      ),
    );

    try {
      await signalingPlugin
          .enableNotifyWhenAppRunningInBackgroundOrQuit();

      debugPrint(
        'Offline push notification registration completed.',
      );
    } catch (e) {
      debugPrint(
        'Offline push notification registration failed: $e',
      );
    }
  }

  // Create call record
  static Future<void> _createCallRecord({
    required String callID,
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required ZegoCallInvitationType callType,
  }) async {
    await _firestore
        .collection('calls')
        .doc(callID)
        .set({
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'callType':
      callType == ZegoCallInvitationType.videoCall
          ? 'video'
          : 'audio',
      'status': 'ringing',
      'createdAt': Timestamp.now(),
      'startedAt': null,
      'endedAt': null,
      'duration': 0,
    });
  }

  // Update call record
  static Future<void> _updateCallRecord(
      String callID,
      Map<String, dynamic> data,
      ) async {
    await _firestore
        .collection('calls')
        .doc(callID)
        .update(data);
  }

  // Finish call record
  static Future<void> _finishCallRecord(
      String callID,
      ) async {
    final DateTime endedAt = DateTime.now();

    if (!_callConnected || _callStartedAt == null) {
      await _updateCallRecord(
        callID,
        {
          'status': 'missed',
          'endedAt': Timestamp.fromDate(endedAt),
          'duration': 0,
        },
      );

      _clearActiveCall();
      return;
    }

    final int duration =
        endedAt.difference(_callStartedAt!).inSeconds;

    await _updateCallRecord(
      callID,
      {
        'status': 'completed',
        'endedAt': Timestamp.fromDate(endedAt),
        'duration': duration,
      },
    );

    _clearActiveCall();
  }

  // Clear active call data
  static void _clearActiveCall() {
    _activeCallId = null;
    _callStartedAt = null;
    _callConnected = false;
  }

  // Dispose
  static void dispose() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();

    _clearActiveCall();
  }
}