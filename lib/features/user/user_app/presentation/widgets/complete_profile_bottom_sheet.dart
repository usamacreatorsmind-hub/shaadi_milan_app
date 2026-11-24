import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shadi_milan/app/router/app_router.dart';

/// Bottom sheet shown when an incomplete-profile ("View Profiles") user tries
/// to access gated actions (Chat, Call, Premium checkout, or locked personal
/// details). Explains the 2-step unlock: Complete Profile -> Premium Plan.
class CompleteProfileBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showPremiumStep;

  const CompleteProfileBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.showPremiumStep = true,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? subtitle,
    bool showPremiumStep = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompleteProfileBottomSheet(
        title: title,
        subtitle: subtitle,
        showPremiumStep: showPremiumStep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    final resolvedTitle = title ??
        (isHindi
            ? 'पहले अपनी प्रोफाइल पूरी करें'
            : 'Complete Your Profile First');
    final resolvedSubtitle = subtitle ??
        (isHindi
            ? 'प्रोफाइल की पूरी जानकारी देखने, चैट और कॉल करने के लिए कृपया अपनी प्रोफाइल पूरी करें।'
            : 'Complete your matrimony profile to unlock full profile details and connect with matches.');

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle_outlined,
              color: theme.primaryColor,
              size: 46,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            resolvedTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            resolvedSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          _StepRow(
            stepNumber: '1',
            title: isHindi ? 'अपनी प्रोफाइल पूरी करें' : 'Complete Your Profile',
            description: isHindi
                ? 'अपनी जानकारी भरें और सभी प्रोफाइल डिटेल्स अनलॉक करें'
                : 'Fill your details to unlock full family, address & personal info',
            color: theme.primaryColor,
          ),
          if (showPremiumStep) ...[
            const SizedBox(height: 12),
            _StepRow(
              stepNumber: '2',
              title: isHindi ? 'प्रीमियम प्लान लें' : 'Choose a Premium Plan',
              description: isHindi
                  ? 'प्रोफाइल पूरी होने के बाद चैट और कॉल शुरू करने के लिए प्रीमियम लें'
                  : 'Upgrade to Premium after profile completion to Chat & Call',
              color: Colors.amber.shade700,
            ),
          ],
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.pushRoute(const MatrimonyFormFlowRoute());
              },
              icon: const Icon(Icons.edit_note_rounded, size: 22),
              label: Text(
                isHindi ? 'प्रोफाइल पूरी करें' : 'COMPLETE YOUR PROFILE',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isHindi ? 'बाद में करेंगे' : 'Maybe Later',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  final Color color;

  const _StepRow({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              stepNumber,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
