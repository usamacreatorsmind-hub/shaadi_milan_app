import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_constants.dart';

@RoutePage()
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🌈 Refined Header with Modern Gradient
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: theme.primaryColor,
            automaticallyImplyLeading: true,
            leading: const AutoLeadingButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              centerTitle: true,
              title: Text(
                AppLabels.contactUs(context),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, const Color(0xFFE91E63)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Background patterns
                  Positioned(right: -30, top: -20, child: Icon(Icons.headset_mic_rounded, size: 200, color: Colors.white.withOpacity(0.1))),
                  Positioned(
                    left: -20,
                    bottom: 20,
                    child: Icon(Icons.support_agent_rounded, size: 120, color: Colors.white.withOpacity(0.1)),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(Icons.contact_support_rounded, size: 56, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 📄 Body Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              transform: Matrix4.translationValues(0, -32, 0),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 25),
                  Text(
                    AppLabels.hereToHelp(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLabels.contactDescription(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),

                  _ContactTile(
                    icon: Icons.alternate_email_rounded,
                    color: const Color(0xFFF44336),
                    title: AppLabels.emailUs(context),
                    subtitle: AppConstants.supportEmail,
                    onTap: () => _launchUrl(AppConstants.emailLink),
                  ),

                  _ContactTile(
                    icon: Icons.phone_in_talk_rounded,
                    color: const Color(0xFF2196F3),
                    title: AppLabels.callUs(context),
                    subtitle: "+91 98765 43210", // Example phone or AppLabels.phone(context)
                    onTap: () => _launchUrl(AppConstants.phoneLink),
                  ),

                  _ContactTile(
                    icon: FontAwesomeIcons.whatsapp,
                    color: const Color(0xFF4CAF50),
                    title: AppLabels.whatsapp(context),
                    subtitle: "Fast response via WhatsApp",
                    onTap: () => _launchUrl(AppConstants.whatsappLink),
                    isFaIcon: true,
                  ),

                  _ContactTile(
                    icon: Icons.history_edu_rounded,
                    color: theme.primaryColor,
                    title: AppLabels.sendAMessage(context),
                    subtitle: "Raise a support ticket",
                    onTap: () {
                      context.pushRoute(SupportTicketFormRoute());
                    },
                  ),

                  const SizedBox(height: 24),

                  /// ⏰ Support Hours Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.access_time_filled_rounded, color: theme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLabels.supportTeamAvailable(context),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppConstants.supportHours,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $urlString");
    }
  }
}

/// 🔹 Reusable Modern Contact Tile
class _ContactTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isFaIcon;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isFaIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: isFaIcon ? Icon(Icons.info, color: color, size: 26) : Icon(Icons.info, color: color, size: 26),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
