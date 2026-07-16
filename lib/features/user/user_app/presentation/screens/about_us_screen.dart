import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

@RoutePage()
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // ================= SLIVER APP BAR =================
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLabels.aboutUs(context)),
              centerTitle: true,
              background: Container(
                padding: const EdgeInsets.only(bottom: 40),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLabels.appName(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLabels.appTagline(context),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _infoSection(
                    context,
                    icon: Icons.groups,
                    title: AppLabels.whoWeAre(context),
                    description: AppLabels.whoWeAreDescription(context),
                  ),

                  _infoSection(
                    context,
                    icon: Icons.flag,
                    title: AppLabels.missionTitle(context),
                    description: AppLabels.missionContent(context),
                  ),

                  _infoSection(
                    context,
                    icon: Icons.verified,
                    title: AppLabels.valuesTitle(context),
                    description: AppLabels.valuesContent(context),
                  ),

                  _infoSection(
                    context,
                    icon: Icons.thumb_up_alt,
                    title: AppLabels.whyChooseUsTitle(context),
                    description: AppLabels.whyChooseUsContent(context),
                  ),

                  const SizedBox(height: 24),

                  // ================= FOOTER =================
                  Center(
                    child: Column(
                      children: [
                        Text(
                          AppLabels.madeWithLove(context),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLabels.copyright(context),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
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

  // ================= SECTION CARD =================
  static Widget _infoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
