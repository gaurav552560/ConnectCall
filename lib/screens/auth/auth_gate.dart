import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../../services/zego_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is checking authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const _AuthenticatedScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}

class _AuthenticatedScreen extends StatefulWidget {
  const _AuthenticatedScreen();

  @override
  State<_AuthenticatedScreen> createState() =>
      _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<_AuthenticatedScreen>
    with WidgetsBindingObserver {
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    initializeZego();
  }

  Future<void> initializeZego() async {
    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final UserService userService = UserService();

    await userService.updateOnlineStatus(
      firebaseUser.uid,
      true,
    );

    final userProfile =
    await userService.getUserProfile(firebaseUser.uid);

    final String userName =
    userProfile?.name.isNotEmpty == true
        ? userProfile!.name
        : (firebaseUser.email ?? 'User');

    await ZegoService.initialize(
      userID: firebaseUser.uid,
      userName: userName,
    );

    if (!mounted) return;

    setState(() {
      isInitialized = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    final UserService userService = UserService();

    if (state == AppLifecycleState.resumed) {
      userService.updateOnlineStatus(
        firebaseUser.uid,
        true,
      );
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      userService.updateOnlineStatus(
        firebaseUser.uid,
        false,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      UserService().updateOnlineStatus(
        firebaseUser.uid,
        false,
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const HomeScreen();
  }
}