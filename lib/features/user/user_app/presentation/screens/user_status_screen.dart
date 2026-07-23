import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/appbar.dart';
import '../../../../../core/constants/app_labels.dart';
import '../controllers/user_status_controller.dart';

@RoutePage()
class UserStatusScreen extends ConsumerWidget {
  const UserStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //   watch current user's status
    final userStatusState = ref.watch(userStatusControllerProvider);

    final userStatus = userStatusState.userStatus;

    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.userStatus(context)),
      body: userStatusState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userStatusState.error != null
          ? Center(
              child: Text(
                AppLabels.error(context, userStatusState.error.toString()),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const SizedBox(height: 10),
                  _buildStatusRow(
                    context,
                    '${AppLabels.paymentId(context)}:',
                    userStatus.paymentId ??
                        AppLabels.notAvailableShort(context),
                    Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(height: 10),
                  _buildStatusRow(
                    context,
                    '${AppLabels.paymentDate(context)}:',
                    userStatus.paymentAt != null
                        ? '${userStatus.paymentAt!.toLocal().day}/${userStatus.paymentAt!.toLocal().month}/${userStatus.paymentAt!.toLocal().year}'
                        : AppLabels.notAvailableShort(context),
                    Theme.of(context).textTheme.bodyMedium?.color,
                  ),

                  const SizedBox(height: 10),
                  if (userStatus.paymentId != null)
                    _buildStatusRow(
                      context,
                      '${AppLabels.paymentId(context)}:',
                      userStatus.paymentId!,
                      Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  const SizedBox(height: 10),
                  if (userStatus.paymentAt != null)
                    _buildStatusRow(
                      context,
                      '${AppLabels.paymentDate(context)}:',
                      '${userStatus.paymentAt!.toLocal().day}/${userStatus.paymentAt!.toLocal().month}/${userStatus.paymentAt!.toLocal().year}',
                      Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
