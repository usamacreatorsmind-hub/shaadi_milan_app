import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/features/l10n/app_translation_service.dart';

/// Preference key helper recording that a user chose "View Profiles" (explore mode).
String onboardingExplorePrefKey(String uid) => 'has_chosen_view_profiles_$uid';

@RoutePage()
class OnboardingChoiceScreen extends ConsumerWidget {
  const OnboardingChoiceScreen({super.key});

  Future<void> _chooseViewProfiles(BuildContext context, WidgetRef ref) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(onboardingExplorePrefKey(uid), true);
    }
    if (context.mounted) {
      context.router.replaceAll([UserMainShellRoute()]);
    }
  }

  void _chooseCompleteProfile(BuildContext context) {
    context.router.replaceAll([const MatrimonyFormFlowRoute()]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: theme.primaryColor,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isHindi ? 'आपका स्वागत है!' : 'Welcome to Shaadi Milan!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isHindi
                      ? 'आप आगे कैसे बढ़ना चाहते हैं? आप अभी प्रोफाइल्स देख सकते हैं या अपनी पूरी प्रोफाइल बना सकते हैं।'
                      : 'How would you like to continue? You can explore profiles first or complete your full matrimony profile right away.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),

                // Option A: Complete Your Profile
                _OptionCard(
                  icon: Icons.verified_user_rounded,
                  badgeText: isHindi ? 'अनुशंसित' : 'RECOMMENDED',
                  title: isHindi ? 'अपनी प्रोफाइल पूरी करें' : 'Complete Your Profile',
                  description: isHindi
                      ? '9-स्टेप फॉर्म भरें और दूसरे यूज़र्स की सभी जानकारी, चैट और कॉल का लाभ उठाएं।'
                      : 'Fill the 9-step matrimony profile to view complete details of matches and unlock Chat & Call with Premium.',
                  buttonLabel:
                      isHindi ? 'प्रोफाइल पूरी करें' : 'Complete Your Profile',
                  isPrimary: true,
                  accentColor: theme.primaryColor,
                  onTap: () => _chooseCompleteProfile(context),
                ),
                const SizedBox(height: 18),

                // Option B: View Profiles
                _OptionCard(
                  icon: Icons.explore_rounded,
                  title: isHindi ? 'प्रोफाइल्स देखें' : 'View Profiles',
                  description: isHindi
                      ? 'पहले ऐप एक्सप्लोर करें। कुछ व्यक्तिगत जानकारी (जैसे पिता का नाम, मोबाइल, पता) प्रोफाइल पूरी करने तक छिपी रहेगी।'
                      : 'Explore profiles on the Home screen first. Sensitive details (father\'s name, mobile, address) & Chat/Call stay locked until you complete your profile.',
                  buttonLabel: isHindi ? 'प्रोफाइल्स देखें' : 'View Profiles',
                  isPrimary: false,
                  accentColor: theme.primaryColor,
                  onTap: () => _chooseViewProfiles(context, ref),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String? badgeText;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isPrimary;
  final Color accentColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    this.badgeText,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isPrimary,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary
              ? accentColor.withValues(alpha: 0.45)
              : Colors.grey.shade200,
          width: isPrimary ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isPrimary ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: isPrimary
                ? ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
