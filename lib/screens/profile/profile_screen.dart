import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/zego_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? user;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final userProfile =
      await _userService.getUserProfile(
        currentUser.uid,
      );

      if (!mounted) return;

      setState(() {
        user = userProfile;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load profile'),
        ),
      );
    }
  }

  Future<void> editProfile() async {
    if (user == null) {
      return;
    }

    final nameController =
    TextEditingController(text: user!.name);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),

          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final newName =
                nameController.text.trim();

                if (newName.isEmpty) {
                  return;
                }

                await _userService.updateUserProfile(
                  user!.uid,
                  {
                    'name': newName,
                  },
                );

                if (!mounted) return;

                setState(() {
                  user = UserModel(
                    uid: user!.uid,
                    name: newName,
                    email: user!.email,
                    isOnline: user!.isOnline,
                    createdAt: user!.createdAt,
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
  }

  Future<void> logout() async {
    try {
      final currentUser =
          FirebaseAuth.instance.currentUser;

      // Set user offline in Firestore
      if (currentUser != null) {
        await _userService.updateOnlineStatus(
          currentUser.uid,
          false,
        );
      }

      // Uninitialize ZEGOCLOUD
      ZegoService.dispose();

      // Sign out from Firebase
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to logout'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('Profile not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 55,
              child: Icon(
                Icons.person,
                size: 55,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user!.email,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: user!.isOnline
                        ? Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  user!.isOnline
                      ? 'Online'
                      : 'Offline',
                ),
              ],
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: editProfile,

                icon: const Icon(
                  Icons.edit,
                ),

                label: const Text(
                  'Edit Profile',
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: logout,

                icon: const Icon(
                  Icons.logout,
                ),

                label: const Text(
                  'Logout',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}