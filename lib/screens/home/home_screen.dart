import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../services/call_service.dart';
import '../../services/user_service.dart';
import '../contacts/contacts_screen.dart';
import '../history/call_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeContent(
        onNavigate: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      const ContactsScreen(),
      const CallHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const HomeContent({
    super.key,
    required this.onNavigate,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final UserService _userService = UserService();

  final TextEditingController searchController =
  TextEditingController();

  UserModel? user;
  bool isLoading = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadUserProfile() async {
    try {
      final User? currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final UserModel? userProfile =
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final String userName =
    user?.name.isNotEmpty == true
        ? user!.name
        : 'User';

    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.onNavigate(3);
                          },
                          borderRadius:
                          BorderRadius.circular(30),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                child: Text(
                                  userName[0]
                                      .toUpperCase(),
                                  style:
                                  const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  userName,
                                  style:
                                  const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons
                              .notifications_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Search recent calls
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchText =
                            value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText:
                      'Search recent calls...',
                      prefixIcon:
                      const Icon(Icons.search),
                      suffixIcon:
                      searchText.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          searchController
                              .clear();

                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.people,
                          title: 'Contacts',
                          onTap: () {
                            widget.onNavigate(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.history,
                          title: 'Call History',
                          onTap: () {
                            widget.onNavigate(2);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Recent Calls
                  const Text(
                    'Recent Calls',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          if (currentUser == null)
            const SliverToBoxAdapter(
              child: Center(
                child: Text('Please login first'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              sliver: StreamBuilder<List<CallModel>>(
                stream: CallService()
                    .getCallHistory(
                  currentUser.uid,
                ),
                builder: (
                    context,
                    snapshot,
                    ) {
                  // Loading
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child:
                        CircularProgressIndicator(),
                      ),
                    );
                  }

                  // Error
                  if (snapshot.hasError) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Unable to load recent calls',
                        ),
                      ),
                    );
                  }

                  final List<CallModel> calls =
                      snapshot.data ?? [];

                  // Empty
                  if (calls.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Icon(
                              Icons
                                  .phone_disabled_outlined,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No recent calls',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Search calls by other person's name
                  final List<CallModel> filteredCalls =
                  calls.where((call) {
                    if (searchText.isEmpty) {
                      return true;
                    }

                    final String otherUserName =
                    call.callerId ==
                        currentUser.uid
                        ? call.receiverName
                        : call.callerName;

                    return otherUserName
                        .toLowerCase()
                        .contains(searchText);
                  }).toList();

                  // No search results
                  if (filteredCalls.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'No matching calls',
                          ),
                        ),
                      ),
                    );
                  }

                  // Lazy list
                  return SliverList.builder(
                    itemCount: filteredCalls.length,
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      return _RecentCallTile(
                        call: filteredCalls[index],
                        currentUserId:
                        currentUser.uid,
                      );
                    },
                  );
                },
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}

class _RecentCallTile extends StatelessWidget {
  final CallModel call;
  final String currentUserId;

  const _RecentCallTile({
    required this.call,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutgoing =
        call.callerId == currentUserId;

    final String otherUserName =
    isOutgoing
        ? call.receiverName
        : call.callerName;

    final bool isMissed =
        call.status == 'missed';

    final bool isDeclined =
        call.status == 'declined';

    final String direction =
    isOutgoing ? 'Outgoing' : 'Incoming';

    final String callType =
    call.callType == 'video'
        ? 'Video'
        : 'Audio';

    final String duration =
    _formatDuration(call.duration);

    final String statusText =
    isMissed
        ? 'Missed'
        : isDeclined
        ? 'Declined'
        : duration;

    final Color? statusColor =
    isMissed || isDeclined
        ? Colors.red
        : null;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: CircleAvatar(
          child: Text(
            otherUserName.isNotEmpty
                ? otherUserName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          otherUserName.isNotEmpty
              ? otherUserName
              : 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              isOutgoing
                  ? Icons.call_made
                  : Icons.call_received,
              size: 15,
              color: statusColor,
            ),
            const SizedBox(width: 4),
            Text(
              '$callType • $direction',
            ),
          ],
        ),
        trailing: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight:
            isMissed || isDeclined
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) {
      return '00:00';
    }

    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}