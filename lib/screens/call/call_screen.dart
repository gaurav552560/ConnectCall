import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../services/zego_service.dart';

class CallScreen extends StatelessWidget {
  final String callID;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.callID,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    final config = isVideoCall
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    // Use gallery layout instead of picture-in-picture.
    config.layout = ZegoLayout.gallery();

    // We don't need PiP yet.
    config.pip.enableWhenBackground = false;

    return ZegoUIKitPrebuiltCall(
      appID: ZegoService.appID,
      appSign: ZegoService.appSign,
      userID: currentUser.uid,
      userName: currentUser.displayName ??
          currentUser.email ??
          'User',
      callID: callID,
      config: config,
    );
  }
}