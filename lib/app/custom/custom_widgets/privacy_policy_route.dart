import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:url_launcher/url_launcher.dart';
 
import '../../../core/constants/app_constants.dart';

@RoutePage()
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.privacyPolicy(context)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLabels.privacyPolicyFor(context)} ${AppLabels.appName(context)}",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.introTitle(context),
              content: AppLabels.introContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.infoCollectTitle(context),
              content: AppLabels.infoCollectContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.howUseInfoTitle(context),
              content: AppLabels.howUseInfoContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.disclosureInfoTitle(context),
              content: AppLabels.disclosureInfoContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.securityDataTitle(context),
              content: AppLabels.securityDataContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.dataRightsTitle(context),
              content: AppLabels.dataRightsContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.linksOtherSitesTitle(context),
              content: AppLabels.linksOtherSitesContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.childrenPrivacyTitle(context),
              content: AppLabels.childrenPrivacyContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.changesPrivacyTitle(context),
              content: AppLabels.changesPrivacyContent(context),
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
              title: AppLabels.yourConsentTitle(context),
              content: AppLabels.yourConsentContent(context),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: AppLabels.grievanceOfficerTitle(context),
              content:
                  "${AppLabels.grievanceOfficerNameLabel(context)}: ${AppConstants.grievanceOfficerName}\n"
                  "${AppLabels.grievanceOfficerEmailLabel(context)}: ${AppConstants.grievanceEmail}\n"
                  "${AppLabels.grievanceOfficerAddressLabel(context)}: ${AppConstants.grievanceOfficerAddress}",
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
