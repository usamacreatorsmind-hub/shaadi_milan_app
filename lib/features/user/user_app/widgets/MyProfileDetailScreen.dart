import '../../../auth/domain/states/user_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class MyProfileDetailScreen extends ConsumerStatefulWidget {
  final UserEntity user;
  const MyProfileDetailScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyProfileCardState();
}

class _MyProfileCardState extends ConsumerState<MyProfileDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // what should i make this class dialogg boc or page

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildInfoCard(context, 'Personal Information', [
                    _buildInfoRow('Full Name', widget.user.fullName),
                    _buildInfoRow('Email', widget.user.email),

                    _buildInfoRow('Phone', widget.user.phone),
                    _buildInfoRow('Agent ID', widget.user.agentId),
                  ]),

                  _buildInfoCard(context, 'Verification Status', []),

                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  // Center(
                  //   child: AppButton(text: "Edit Profile", onPressed: () {}),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildInfoRow(String s, String agentId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            s,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            agentId,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Card _buildInfoCard(BuildContext context, String s, List<dynamic> list) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            ...list,
          ],
        ),
      ),
    );
  }
}
