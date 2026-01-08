
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
@RoutePage()
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("About Us"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome to Arvika Marriage Bureau",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Your trusted partner in finding your perfect match.",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              context,
              title: "Our Mission",
              content:
                  "At Arvika Marriage Bureau, our mission is to connect individuals seeking lifelong companionship with compatible partners. We strive to create a platform that is safe, reliable, and efficient, ensuring a joyful journey towards matrimony.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "What We Offer",
              content:
                  "We provide a comprehensive matchmaking service with a focus on personalized experiences. Our features include detailed profile creation, advanced search filters, secure communication tools, and dedicated support to guide you every step of the way.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "Our Values",
              content:
                  "Trust, respect, and integrity are at the core of everything we do. We are committed to maintaining a high standard of privacy and ensuring a respectful environment for all our members.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "Why Choose Us?",
              content:
                  "With years of experience in matchmaking, a vast database of genuine profiles, and a team dedicated to your success, Arvika Marriage Bureau stands out as a premier choice for your matrimonial needs. We understand the cultural nuances and personal preferences that are vital in finding a life partner.",
            ),
            const SizedBox(height: 30),
            Text(
              "Thank you for choosing Arvika Marriage Bureau. We look forward to being a part of your beautiful journey!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "© 2024 Arvika Marriage Bureau. All rights reserved.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          textAlign: TextAlign.justify,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
