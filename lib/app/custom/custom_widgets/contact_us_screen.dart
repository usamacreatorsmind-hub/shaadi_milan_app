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
      body: CustomScrollView(
        slivers: [
          /// 🌈 Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(AppLabels.contactUs(context)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(height: 40),
                    Icon(
                      Icons.contact_support_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 📄 Body
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  AppLabels.hereToHelp(context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLabels.contactDescription(context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                _ContactTile(
                  iconWidget: const Icon(Icons.email_outlined, color: Colors.redAccent),
                  color: Colors.redAccent,
                  title: AppLabels.emailUs(context),
                  subtitle: AppConstants.supportEmail,
                  onTap: () => _launchUrl(AppConstants.emailLink),
                ),

                _ContactTile(
                  iconWidget: const Icon(Icons.phone_outlined, color: Colors.blueAccent),
                  color: Colors.blueAccent,
                  title: AppLabels.callUs(context),
                  subtitle: AppLabels.phone(context),
                  onTap: () => _launchUrl(AppConstants.phoneLink),
                ),

                _ContactTile(
                  iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                  color: Colors.green,
                  title: AppLabels.whatsapp(context),
                  subtitle: AppLabels.phone(context),
                  onTap: () => _launchUrl(AppConstants.whatsappLink),
                ),

                _ContactTile(
                  iconWidget: const Icon(Icons.message_outlined, color: Colors.deepPurple),
                  color: Colors.deepPurple,
                  title: AppLabels.sendAMessage(context),
                  subtitle: AppLabels.getBackShortly(context),
                  onTap: () {
                    context.pushRoute(SupportTicketFormRoute());
                  },
                ),

                const SizedBox(height: 40),

                /// ⏰ Support Time
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${AppLabels.supportTeamAvailable(context)}\n${AppConstants.supportHours}",
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
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

/// 🔹 Reusable Contact Tile
class _ContactTile extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: iconWidget,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
