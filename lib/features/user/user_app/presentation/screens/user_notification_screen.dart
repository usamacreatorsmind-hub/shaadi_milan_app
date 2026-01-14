import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UserNotificationScreen extends StatelessWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Container(
        child: Card(
          child: Column(
            // implement  user if verified or not
            children: [
              NotificationTile(
                title: 'Account Verification',

                subtitle:
                    'Your account is currently under review. Please wait for verification.',

                icon: Icons.hourglass_empty,

                iconColor: Colors.orange,
              ),

              NotificationTile(
                title: 'Profile Update',
                subtitle: 'Your profile has been successfully updated.',
                icon: Icons.person_outline,
                iconColor: Colors.blue,
              ),
              NotificationTile(
                title: 'New Match Found!',
                subtitle: 'We found a new match for you. Check it out!',
                icon: Icons.favorite_border,
                iconColor: Colors.red,
                onTap: () {
                  // Handle navigation to matches screen
                },
              ),

              NotificationTile(
                title: 'New Message',
                subtitle: 'You have a new message from John Doe.',
                icon: Icons.message_outlined,
                iconColor: Colors.purple,
                onTap: () {
                  // Handle navigation to messages screen
                },
              ),

              NotificationTile(
                title: 'Payment Reminder',
                subtitle: 'Your subscription renewal is due soon.',
                icon: Icons.credit_card,
                iconColor: Colors.green,
                onTap: () {
                  // Handle navigation to payment screen
                },
              ),

              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
      ),
    );
  }
}
