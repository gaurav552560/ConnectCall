import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/call_model.dart';
import '../../services/call_service.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    final CallService callService = CallService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
      ),

      body: StreamBuilder<List<CallModel>>(
        stream: callService.getCallHistory(
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
            return const Center(
              child: Text(
                'Unable to load call history',
              ),
            );
          }

          final List<CallModel> calls =
              snapshot.data ?? [];

          // Empty
          if (calls.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_disabled_outlined,
                    size: 60,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No call history',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Your calls will appear here.',
                  ),
                ],
              ),
            );
          }

          // Call history
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: calls.length,

            itemBuilder: (context, index) {
              final CallModel call = calls[index];

              return CallHistoryTile(
                call: call,
                currentUserId: currentUser.uid,
              );
            },
          );
        },
      ),
    );
  }
}

class CallHistoryTile extends StatelessWidget {
  final CallModel call;
  final String currentUserId;

  const CallHistoryTile({
    super.key,
    required this.call,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Find the other person
    final bool isOutgoing =
        call.callerId == currentUserId;

    final String otherUserName =
    isOutgoing
        ? call.receiverName
        : call.callerName;

    // Call direction
    final String direction =
    isOutgoing
        ? 'Outgoing'
        : 'Incoming';

    // Call type
    final String callType =
    call.callType == 'video'
        ? 'Video Call'
        : 'Audio Call';

    // Format date and time
    final String dateTime =
    _formatDateTime(
      call.createdAt ?? call.startedAt,
    );

    // Format duration
    final String duration =
    _formatDuration(call.duration);

    // Call status
    final bool isMissed =
        call.status == 'missed';

    final bool isDeclined =
        call.status == 'declined';

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
        const EdgeInsets.all(12),

        leading: CircleAvatar(
          radius: 25,
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

        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            Row(
              children: [
                Icon(
                  isOutgoing
                      ? Icons.call_made
                      : Icons.call_received,
                  size: 16,
                  color: statusColor,
                ),

                const SizedBox(width: 5),

                Text(
                  '$callType • $direction',
                ),
              ],
            ),

            const SizedBox(height: 3),

            Text(
              dateTime,
            ),
          ],
        ),

        trailing: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              call.callType == 'video'
                  ? Icons.videocam
                  : Icons.call,
              color: statusColor,
            ),

            const SizedBox(height: 5),

            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight:
                isMissed || isDeclined
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) {
      return '00:00';
    }

    final int minutes = seconds ~/ 60;

    final int remainingSeconds =
        seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown time';
    }

    final DateTime now =
    DateTime.now();

    final String time =
    _formatTime(dateTime);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today, $time';
    }

    final DateTime yesterday =
    now.subtract(
      const Duration(days: 1),
    );

    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday, $time';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} $time';
  }

  String _formatTime(DateTime dateTime) {
    final int hour =
    dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final String minute =
    dateTime.minute
        .toString()
        .padLeft(2, '0');

    final String period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }
}