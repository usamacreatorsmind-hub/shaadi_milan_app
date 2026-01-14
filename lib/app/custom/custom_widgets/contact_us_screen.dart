// define a beautiful screen

import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_support_outlined,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              "We're here to help!",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Have questions, feedback, or need assistance? Reach out to us through any of the channels below.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: "Email Us",
              subtitle: "support@arvikamarriage.com",
              onTap: () => _launchUrl('mailto:support@arvikamarriage.com'),
            ),
            const SizedBox(height: 20),
            _buildContactCard(
              context,
              icon: Icons.phone_outlined,
              title: "Call Us",
              subtitle: "+91 98765 43210",
              onTap: () => _launchUrl('tel:+91 98765 43210'),
            ),

            const SizedBox(height: 20),
            _buildContactCard(
              context,
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: "+91 98765 43210",
              onTap: () => _launchUrl('https://wa.me/919876543210'),
            ),
            const SizedBox(height: 20),

            // a card to send message
            _buildContactCard(
              context,
              icon: Icons.message_outlined,
              title: "Send us a message",
              subtitle: "We'll get back to you shortly",
              onTap: () {
                context.pushRoute(const SupportTicketFormRoute());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Opening message interface... (Not implemented)",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
            Text(
              "Our support team is available from 9 AM to 6 PM (IST), Monday to Friday.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            children: [
              Icon(icon, size: 30, color: theme.colorScheme.primary),
              const SizedBox(width: 20),
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
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
