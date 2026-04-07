import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

@RoutePage()
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy for ${AppConstants.appName}",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Text(
            //   "Last updated: ${AppConstants.privacyPolicyLastUpdated}",
            //   style: theme.textTheme.bodySmall?.copyWith(
            //     color: Colors.grey.shade600,
            //   ),
            // ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "1. Introduction",
              content:
                  "Welcome to Arvika Marriage Bureau. We are committed to protecting your privacy and handling your data in an open and transparent manner. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website and use our services.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "2. Information We Collect",
              content:
                  "We collect various types of information to provide and improve our services to you:\n\n"
                  "• Personal Data: This includes your name, email address, phone number, date of birth, gender, marital status, religion, caste, educational background, occupation, income, physical attributes, family details, and photographs.\n"
                  "• Usage Data: Information on how the service is accessed and used (e.g., IP address, browser type, pages visited, time spent on pages).\n"
                  "• Communication Data: Records of your correspondence with us and other users.",
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              title: "3. How We Use Your Information",
              content:
                  "We use the collected data for various purposes:\n\n"
                  "• To provide and maintain our service.\n"
                  "• To create and manage your profile.\n"
                  "• To match you with suitable profiles.\n"
                  "• To communicate with you about your account or services.\n"
                  "• To improve our services and develop new features.\n"
                  "• To detect, prevent, and address technical issues.\n"
                  "• To comply with legal obligations.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "4. Disclosure of Your Information",
              content:
                  "We may share your information in the following situations:\n\n"
                  "• With Other Users: Your profile information (excluding direct contact details unless you choose to share them) will be visible to other registered users to facilitate matchmaking.\n"
                  "• With Service Providers: We may employ third-party companies and individuals to facilitate our service, provide the service on our behalf, perform service-related services, or assist us in analyzing how our service is used.\n"
                  "• For Legal Reasons: We may disclose your Personal Data in the good faith belief that such action is necessary to comply with a legal obligation, protect and defend the rights or property of Arvika Marriage Bureau, prevent or investigate possible wrongdoing in connection with the service, protect the personal safety of users of the service or the public, or protect against legal liability.\n"
                  "• Business Transfers: If Arvika Marriage Bureau is involved in a merger, acquisition, or asset sale, your Personal Data may be transferred.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "5. Security of Your Data",
              content:
                  "The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,

              title: "6. Your Data Protection Rights",
              content:
                  "Depending on your location, you may have the following data protection rights:\n\n"
                  "• The right to access, update, or delete the information we have on you.\n"
                  "• The right to rectify your information if it is inaccurate or incomplete.\n"
                  "• The right to object to our processing of your Personal Data.\n"
                  "• The right to request that we restrict the processing of your personal information.\n"
                  "• The right to data portability.\n"
                  "• The right to withdraw consent at any time where Arvika Marriage Bureau relied on your consent to process your personal information.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "7. Links to Other Sites",
              content:
                  "Our service may contain links to other sites that are not operated by us. If you click on a third-party link, you will be directed to that third party's site. We strongly advise you to review the Privacy Policy of every site you visit. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.",
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "8. Children's Privacy",
              content:
                  "Our service does not address anyone under the age of 18 ('Children'). We do not knowingly collect personally identifiable information from anyone under the age of 18. If you are a parent or guardian and you are aware that your child has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers.",
            ),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "9. Changes to This Privacy Policy",
              content:
                  "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. We will let you know via email and/or a prominent notice on our service, prior to the change becoming effective and update the 'last updated' date at the top of this Privacy Policy. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.",
            ),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "10. Governing Law",
              content:
                  "These Terms shall be governed and construed in accordance with the laws of ${AppConstants.governingLaw}, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.",
            ),

            _buildSection(
              context,
              title: "11. Your Consent",
              content:
                  "By using our service, you hereby consent to our Privacy Policy and agree to its terms.",
            ),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "12. Governing Law",
              content:
                  "These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.",
            ),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "13. Grievance Officer",
              content:
                  "In accordance with Information Technology Act 2000 and rules made there under, the name and contact details of the Grievance Officer are provided below:\n\n"
                  "Name: ${AppConstants.grievanceOfficerName}\n"
                  "Email: ${AppConstants.grievanceEmail}\n"
                  "Address: ${AppConstants.grievanceOfficerAddress}",
            ),

            const SizedBox(height: 20),

            _buildLinkSection(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
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
}
