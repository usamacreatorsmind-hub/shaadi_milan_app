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
              ListTile(
                leading: Icon(Icons.verified_user, color: Colors.green),
                title: Text('Verification Status'),
                subtitle: Text('Your profile is currently under review.'),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
