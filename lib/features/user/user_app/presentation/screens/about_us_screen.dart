import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
              title: const Text('About Us'),
              centerTitle: true,
              background: Container(
                padding: const EdgeInsets.only(bottom: 40),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 56,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Arvika Marriage Bureau',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Connecting Hearts, Creating Happy Families',
                      style: TextStyle(
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
                    title: 'Who We Are',
                    description:
                        'Arvika Marriage Bureau is a trusted matrimonial service '
                        'dedicated to helping individuals and families find compatible life partners. '
                        'We believe marriage is not just a bond between two individuals, '
                        'but a union of families, values, and traditions.',
                  ),

                  _infoSection(
                    context,
                    icon: Icons.flag,
                    title: 'Our Mission',
                    description:
                        'Our mission is to create a safe, reliable, and respectful '
                        'platform for matchmaking. We focus on transparency, '
                        'privacy, and cultural values while making the search '
                        'for a life partner simple and meaningful.',
                  ),

                  _infoSection(
                    context,
                    icon: Icons.verified,
                    title: 'Our Core Values',
                    description:
                        '• Trust & Privacy\n'
                        '• Genuine & Verified Profiles\n'
                        '• Family-Oriented Matchmaking\n'
                        '• Cultural & Traditional Respect\n'
                        '• Honest & Ethical Services',
                  ),

                  _infoSection(
                    context,
                    icon: Icons.thumb_up_alt,
                    title: 'Why Choose Arvika?',
                    description:
                        '✔ Verified and authentic profiles\n'
                        '✔ Personalized matchmaking support\n'
                        '✔ Simple and secure platform\n'
                        '✔ Dedicated relationship assistance\n'
                        '✔ Commitment to long-term happiness',
                  ),

                  const SizedBox(height: 24),

                  // ================= FOOTER =================
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'Made with ❤️ for meaningful connections',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '© Arvika Marriage Bureau',
                          style: TextStyle(
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
