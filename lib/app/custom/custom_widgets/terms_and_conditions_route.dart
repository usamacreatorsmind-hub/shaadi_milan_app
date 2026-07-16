import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
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
        title: Text(AppLabels.termsAndConditions(context)),
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
              "${AppLabels.termsAndConditionsFor(context)} ${AppLabels.appName(context)}",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.acceptanceTermsTitle(context),
              content: AppLabels.acceptanceTermsContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.eligibilityTitle(context),
              content: AppLabels.eligibilityContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.accountRegistrationTitle(context),
              content: AppLabels.accountRegistrationContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.userConductTitle(context),
              content: AppLabels.userConductContent(context),
            ),

            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.contentOwnershipTitle(context),
              content: AppLabels.contentOwnershipContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.premiumServicesTitle(context),
              content: AppLabels.premiumServicesContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.disclaimerWarrantiesTitle(context),
              content: AppLabels.disclaimerWarrantiesContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.limitationLiabilityTitle(context),
              content: AppLabels.limitationLiabilityContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.indemnificationTitle(context),
              content: AppLabels.indemnificationContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.changesTermsTitle(context),
              content: AppLabels.changesTermsContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.governingLawTitle(context),
              content: AppLabels.governingLawContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.contactUsTitle(context),
              content:
                  "${AppLabels.contactUsContent(context)} Email: ${AppConstants.supportEmail}",
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
          AppLabels.privacyPolicy(context),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLabels.privacyImportantMessage(context),
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
