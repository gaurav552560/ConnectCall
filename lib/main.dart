import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final navigatorKey = GlobalKey<NavigatorState>();

  ZegoUIKitPrebuiltCallInvitationService()
      .setNavigatorKey(navigatorKey);

  if (!kIsWeb) {
    await ZegoUIKit().initLog();

    await ZegoUIKitPrebuiltCallInvitationService()
        .useSystemCallingUI(
      [
        ZegoUIKitSignalingPlugin(),
      ],
    );
  }

  runApp(
    ConnectCallApp(
      navigatorKey: navigatorKey,
    ),
  );
}

class ConnectCallApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ConnectCallApp({
    super.key,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConnectCall',

      navigatorKey: navigatorKey,

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}