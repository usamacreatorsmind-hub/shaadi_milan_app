import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

@RoutePage()
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terms and Conditions for ${AppConstants.appName}",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Text(
            //   "Last updated: ${AppConstants.termsLastUpdated}",
            //   style: theme.textTheme.bodySmall?.copyWith(
            //     color: Colors.grey.shade600,
            //   ),
            // ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "1. Acceptance of Terms",
              content:
                  "By accessing or using the Arvika Marriage Bureau website and services, you agree to be bound by these Terms and Conditions and our Privacy Policy. If you do not agree to all the terms and conditions of this agreement, then you may not access the website or use any services.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "2. Eligibility",
              content:
                  "You must be at least 18 years old and of legal marriageable age as per the laws of India to register and use our services. By using the service, you represent and warrant that you have the right, authority, and capacity to enter into this agreement and to abide by all of the terms and conditions of this agreement.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "3. Account Registration",
              content:
                  "To use certain features of the service, you must register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. You are responsible for safeguarding your password and for all activities that occur under your account.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "4. User Conduct",
              content:
                  "You agree to use the service only for lawful purposes and in a way that does not infringe the rights of, restrict, or inhibit anyone else's use and enjoyment of the service. Prohibited behavior includes harassing or causing distress or inconvenience to any other user, transmitting obscene or offensive content, or disrupting the normal flow of dialogue within the service.",
            ),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "5. Content Ownership and License",
              content:
                  "You retain all ownership rights to the content you submit to the service. By submitting content, you grant Arvika Marriage Bureau a worldwide, non-exclusive, royalty-free, transferable license to use, reproduce, distribute, prepare derivative works of, display, and perform the content in connection with the service and Arvika Marriage Bureau's (and its successors' and affiliates') business, including without limitation for promoting and redistributing part or all of the service (and derivative works thereof) in any media formats and through any media channels.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "6. Premium Services and Payments",
              content:
                  "Arvika Marriage Bureau may offer premium services that require payment. All fees are non-refundable unless otherwise stated. We reserve the right to change our prices at any time. Your subscription to premium services will automatically renew unless you cancel it before the end of the current subscription period.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "7. Disclaimer of Warranties",
              content:
                  "The service is provided on an 'as is' and 'as available' basis. Arvika Marriage Bureau makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties, including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "8. Limitation of Liability",
              content:
                  "In no event shall Arvika Marriage Bureau or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Arvika Marriage Bureau's website, even if Arvika Marriage Bureau  or a Arvika Marriage Bureau authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "9. Indemnification",
              content:
                  "You agree to indemnify, defend, and hold harmless Arvika Marriage Bureau, its officers, directors, employees, agents, and third parties, for any losses, costs, liabilities, and expenses (including reasonable attorneys' fees) relating to or arising out of your use of or inability to use the Site or services, any user postings made by you, your violation of any terms of this Agreement or your violation of any rights of a third party, or your violation of any applicable laws, rules or regulations. Arvika Marriage Bureau reserves the right, at its own cost, to assume the exclusive defense and control of any matter otherwise subject to indemnification by you, in which event you will fully cooperate with Arvika Marriage Bureau in asserting any available defenses.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "10. Changes to Terms",
              content:
                  "${AppConstants.appName} reserves the right, in its sole discretion, to change the Terms under which this application is offered. The most current version of the Terms will supersede all previous versions. ${AppConstants.appName} encourages you to periodically review the Terms to stay informed of our updates.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "11. Governing Law",
              content:
                  "These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "12. Contact Us",
              content:
                  "${AppConstants.appName} welcomes your questions or comments regarding the Terms: Email: ${AppConstants.supportEmail}",
            ),

            const SizedBox(height: 20),
            _buildLinkSection(context),

            const SizedBox(height: 20),
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
            color: theme.colorScheme.onSurface,
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

  Widget _buildLinkSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Privacy Policy",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your personal information.",
          textAlign: TextAlign.justify,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(AppConstants.privacyPolicyUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            AppConstants.privacyPolicyUrl,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }


}
