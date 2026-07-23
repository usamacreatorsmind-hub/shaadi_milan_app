import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_labels.dart';

@RoutePage()
class UserNotificationScreen extends StatelessWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.notifications(context))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            NotificationTile(
              title: AppLabels.accountVerification(context),
              subtitle: AppLabels.accountUnderReview(context),
              icon: Icons.hourglass_empty,
              iconColor: Colors.orange,
            ),
            NotificationTile(
              title: AppLabels.profileUpdate(context),
              subtitle: AppLabels.profileUpdateSuccess(context),
              icon: Icons.person_outline,
              iconColor: Colors.blue,
            ),
            NotificationTile(
              title: AppLabels.newMatchFoundTitle(context),
              subtitle: AppLabels.newMatchFoundSubtitle(context),
              icon: Icons.favorite_border,
              iconColor: Colors.red,
              onTap: () {
                // Handle navigation to matches screen
              },
            ),
            NotificationTile(
              title: AppLabels.newMessageTitle(context),
              subtitle: AppLabels.newMessageFrom(context, 'John Doe'),
              icon: Icons.message_outlined,
              iconColor: Colors.purple,
              onTap: () {
                // Handle navigation to messages screen
              },
            ),
            NotificationTile(
              title: AppLabels.paymentReminder(context),
              subtitle: AppLabels.subscriptionRenewalDue(context),
              icon: Icons.credit_card,
              iconColor: Colors.green,
              onTap: () {
                // Handle navigation to payment screen
              },
            ),
            const Divider(),
          ],
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
