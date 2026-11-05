import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

import '../../../../app/custom/custom_widgets/app_logo.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../../l10n/app_translation_service.dart';

@RoutePage()
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF4F5), // Ultra Soft Red
              Color(0xFFFFFAF0), // Floral White (Creamy)
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🌐 Language Toggle Switch
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final locale = ref.watch(localeProvider);
                        final isHindi = locale.languageCode == 'hi';

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "EN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isHindi ? FontWeight.normal : FontWeight.bold,
                                color: isHindi ? Colors.grey : Theme.of(context).primaryColor,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: isHindi,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (val) {
                                  final code = val ? 'hi' : 'en';
                                  ref.read(appTranslationServiceProvider).setLanguageCode(code);
                                  ref.read(localeProvider.notifier).state = Locale(code);
                                },
                              ),
                            ),
                            Text(
                              "हि",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isHindi ? FontWeight.bold : FontWeight.normal,
                                color: isHindi ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      /// 💍 App Branding with Animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                          );
                        },
                        child: Column(
                          children: [
                            const AppLogo(size: 200),
                            const SizedBox(height: 20),
                            Text(
                              AppLabels.appName(context),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                // theme color
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLabels.splashTagline(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                // theme color
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Column(
                        children: [
                          /// ❤️ User Card (Member Portal)
                          _EnhancedRoleCard(
                            title: AppLabels.memberPortal(context),
                            subtitle: AppLabels.findSoulmateSubtitle(context),
                            icon: Icons.favorite_rounded,
                            beginColor: const Color(0xFFFFD700), // Gold
                            endColor: const Color(0xFFB8860B),   // Dark Gold
                            delay: 0.2,
                            onTap: () => context.router.push(UserLoginRoute()),
                          ),
                          const SizedBox(height: 24),

                          /// 👔 Agent Card (Staff Portal)
                          _EnhancedRoleCard(
                            title: AppLabels.staffPortal(context),
                            subtitle: AppLabels.manageLeadsSubtitle(context),
                            icon: Icons.business_center_rounded,
                            beginColor: const Color(0xFFC70310), // Matching Theme Red
                            endColor: const Color(0xFF8B0000),   // Deep Maroon
                            delay: 0.4,
                            onTap: () => context.router.push(AgentLoginRoute()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔒 Modern Glass Footer
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      border: Border(top: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.08))),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user, size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              AppLabels.verifiedProfiles(context),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 🔗 Links Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FooterLink(
                              text: AppLabels.privacyPolicy(context),
                              onTap: () => AppConstants.openUrl(AppConstants.privacyPolicyUrl),
                            ),
                            _LinkSeparator(),
                            _FooterLink(
                              text: AppLabels.termsAndConditions(context),
                              onTap: () => AppConstants.openUrl(AppConstants.termsAndConditionsUrl),
                            ),
                            _LinkSeparator(),
                            _FooterLink(
                              text: AppLabels.needHelpContactUs(context),
                              onTap: () => context.pushRoute(const ContactUsRoute()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final dynamic icon; // Using dynamic to avoid FaIconData vs IconData type mismatch
  final Color color;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: FaIcon(icon, color: color, size: 20),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class _LinkSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        "|",
        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
      ),
    );
  }
}

class _EnhancedRoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color beginColor;
  final Color endColor;
  final double delay;
  final VoidCallback onTap;

  const _EnhancedRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.beginColor,
    required this.endColor,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_EnhancedRoleCard> createState() => _EnhancedRoleCardState();
}

class _EnhancedRoleCardState extends State<_EnhancedRoleCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 50 * (1 - value)), child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.beginColor, widget.endColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: widget.endColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Stack(
              children: [
                // Decorative background circle
                Positioned(right: -20, top: -20, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: Icon(widget.icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(widget.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
