import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/user_model.dart';
import '../../services/permission_service.dart';
import '../../services/user_service.dart';

class ContactsScreen extends StatefulWidget {
  final String initialSearch;
  const ContactsScreen({
    super.key,
    this.initialSearch = '',
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final UserService _userService = UserService();

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';
  @override
  void initState() {
    super.initState();

    searchText = widget.initialSearch;
    searchController.text = widget.initialSearch;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),

      body: Column(
        children: [

          // Search
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(Icons.search),

                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();

                    setState(() {
                      searchText = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Users
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _userService.getUsers(
                currentUser.uid,
              ),

              builder: (context, snapshot) {

                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load contacts',
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                // Search filtering
                final filteredUsers = users.where((user) {
                  return user.name
                      .toLowerCase()
                      .contains(searchText.toLowerCase());
                }).toList();

                // No users
                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [

                        Icon(
                          Icons.people_outline,
                          size: 60,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No contacts found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Register another user to see them here.',
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount: filteredUsers.length,

                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    return ContactTile(
                      user: user,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final UserModel user;

  const ContactTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [

            // Profile avatar
            CircleAvatar(
              radius: 25,

              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // User information
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [

                      Container(
                        width: 8,
                        height: 8,

                        decoration: BoxDecoration(
                          color: user.isOnline
                              ? Colors.green
                              : Colors.grey,

                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        user.isOnline
                            ? 'Online'
                            : 'Offline',

                        style: TextStyle(
                          fontSize: 13,

                          color: user.isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Audio call
            ZegoSendCallInvitationButton(
              invitees: [
                ZegoUIKitUser(
                  id: user.uid,
                  name: user.name,
                ),
              ],
              isVideoCall: false,
              resourceID: 'connect_calls',
              timeoutSeconds: 60,
              onPressed: (
                  String code,
                  String message,
                  List<String> errorInvitees,
                  ) {
                if (code.isEmpty && errorInvitees.isEmpty) {
                  return;
                }

                final bool userUnavailable =
                    message.contains('107026') ||
                        message.contains('not registered');

                final String errorMessage = userUnavailable
                    ? '${user.name} is offline or unavailable.'
                    : 'Unable to start the call. Please try again.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                  ),
                );
              },
              onWillPressed: () async {
                final PermissionStatus status =
                await Permission.microphone.status;

                if (status.isPermanentlyDenied) {
                  await PermissionService.openSettings();
                  return false;
                }

                final bool allowed =
                await PermissionService.requestMicrophone();

                if (!allowed) {
                  return false;
                }

                return true;
              },
              icon: ButtonIcon(
                icon: const Icon(Icons.call),
              ),
              buttonSize: const Size(40, 40),
              iconSize: const Size(24, 24),
              verticalLayout: false,
            ),

            // Video call
            ZegoSendCallInvitationButton(
              invitees: [
                ZegoUIKitUser(
                  id: user.uid,
                  name: user.name,
                ),
              ],
              isVideoCall: true,
              resourceID: 'connect_calls',
              timeoutSeconds: 60,
              onPressed: (
                  String code,
                  String message,
                  List<String> errorInvitees,
                  ) {
                if (code.isEmpty && errorInvitees.isEmpty) {
                  return;
                }

                final bool userUnavailable =
                    message.contains('107026') ||
                        message.contains('not registered');

                final String errorMessage = userUnavailable
                    ? '${user.name} is offline or unavailable.'
                    : 'Unable to start the call. Please try again.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                  ),
                );
              },
              onWillPressed: () async {
                final PermissionStatus cameraStatus =
                await Permission.camera.status;

                final PermissionStatus microphoneStatus =
                await Permission.microphone.status;

                if (cameraStatus.isPermanentlyDenied ||
                    microphoneStatus.isPermanentlyDenied) {
                  await PermissionService.openSettings();
                  return false;
                }

                final bool allowed =
                await PermissionService.requestCameraAndMicrophone();

                if (!allowed) {
                  return false;
                }

                return true;
              },
              icon: ButtonIcon(
                icon: const Icon(Icons.videocam),
              ),
              buttonSize: const Size(40, 40),
              iconSize: const Size(24, 24),
              verticalLayout: false,
            ),
          ],
        ),
      ),
    );
  }
}