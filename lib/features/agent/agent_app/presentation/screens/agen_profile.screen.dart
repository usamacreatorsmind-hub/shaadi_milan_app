import 'package:arvika_marriage_bureau/app/custom/custom_widgets/drawer.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_details_screen.dart';

import '../../../../../app/custom/custom_widgets/mime_type.dart';
import '../../../../user/user_app/widgets/pdf_viewer_bottomsheet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../user/user_app/data/repositories_impl/agent_repository_impl.dart';
import '../../../../auth/domain/states/agent_state.dart';

final agentProvider = FutureProvider.family<AgentEntity, String>((ref, uid) {
  return ref.watch(agentRepositoryProvider).fetchAgent(uid);
});

@RoutePage()
class AgentEntityScreen extends ConsumerWidget {
  final String uid;
  const AgentEntityScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProvider(uid));
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(agentAsync: agentAsync),

      body: agentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (agent) {
          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // ===== APP BAR + PROFILE + TABS =====
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 300,
                    backgroundColor: theme.primaryColor,
                    iconTheme: IconThemeData(
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: SizedBox(
                      height: 56,
                      child: Center(
                        child: Text(
                          agent.agentName,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: ProfileHeader(agent: agent),
                      ),
                    ),
                  ),

                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        tabAlignment: TabAlignment.center,
                        isScrollable: true,
                        indicatorColor: Colors.transparent,
                        unselectedLabelColor: Colors.grey,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        dividerColor: Colors.transparent,

                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          TabWidget(label: 'Overview', icon: Icons.person),
                          TabWidget(label: 'Media', icon: Icons.image),
                          TabWidget(label: 'Contact', icon: Icons.contact_mail),
                          TabWidget(label: 'Status', icon: Icons.verified_user),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  OverviewTab(agent: agent),
                  MediaTab(agent: agent),
                  ContactTab(agent: agent),
                  StatusTab(agent: agent),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  const _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class OverviewTab extends StatefulWidget {
  final AgentEntity agent;
  const OverviewTab({super.key, required this.agent});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: OverviewCard(agent: widget.agent),
        ),
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final AgentEntity agent;
  const OverviewCard({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final fullAddress =
        '${agent.agentAddress}, ${agent.agentCity}, ${agent.agentState} - ${agent.agentPincode}';

    return InfoSectionCard(
      icon: Icons.dashboard_customize_outlined,
      title: "Agent Overview",
      children: [
        _ContactTile(
          color: primary,
          onTap: () {
            launchUrl(Uri.parse('tel:${agent.agentMobile}'));
          },
          icon: Icons.phone_outlined,
          label: "Mobile",
          value: agent.agentMobile,
        ),
        SizedBox(height: 10),
        _ContactTile(
          color: primary,
          onTap: () {
            // You can add navigation to a map application or just display the address
            // For now, let's just show a snackbar or copy to clipboard
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Agent ID: ${agent.agentId}')),
            );
          },
          icon: Icons.person_outline,
          label: "Agent ID",
          value: agent.agentId,
        ),
        // build all with contact tile
        SizedBox(height: 10),
        _ContactTile(
          color: primary,
          onTap: () {
            launchUrl(Uri.parse('mailto:${agent.agentEmail}'));
          },
          icon: Icons.email_outlined,
          label: "Email",
          value: agent.agentEmail,
        ),
        SizedBox(height: 10),
        _ContactTile(
          color: primary,
          onTap: () {
            // You can add navigation to a map application or just display the address
            // For now, let's just show a snackbar or copy to clipboard
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Address: $fullAddress')));
          },
          icon: Icons.location_on_outlined,
          label: "Address",
          value: fullAddress,
        ),
        SizedBox(height: 10),
        _ContactTile(
          color: primary,
          onTap: () {
            // You can add navigation to a map application or just display the address
            // For now, let's just show a snackbar or copy to clipboard
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pincode: ${agent.agentPincode}')),
            );
          },
          icon: Icons.location_pin,
          label: "Pincode",
          value: agent.agentPincode,
        ),
      ],
    );
  }
}

class MediaTab extends StatelessWidget {
  final AgentEntity agent;
  const MediaTab({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ImagePreviewCard(
            title: "Profile Image",
            imageUrl: agent.profileImageUrl,
          ),
          ImagePreviewCard(
            title: "Primary Image",
            imageUrl: agent.primaryImageUrl,
          ),
          DocumentCard(title: "Aadhar Document", fileUrl: agent.aadharUrl),
        ],
      ),
    );
  }
}

class ContactTab extends StatelessWidget {
  final AgentEntity agent;
  const ContactTab({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoCard(cardName: "Contact Information", agent: agent),
          const SizedBox(height: 20),
          ActionButtons(agent: agent),
        ],
      ),
    );
  }
}

class StatusTab extends StatelessWidget {
  final AgentEntity agent;
  const StatusTab({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(children: [StatusInfoCard(agent: agent)]),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final AgentEntity agent;
  const ProfileHeader({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          backgroundImage: agent.profileImageUrl.isNotEmpty
              ? NetworkImage(agent.profileImageUrl)
              : null,
          child: agent.profileImageUrl.isEmpty
              ? Text(
                  agent.agentName[0].toUpperCase(),
                  style: TextStyle(fontSize: 30, color: theme.primaryColor),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          agent.agentName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(agent.agentEmail, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class InfoSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;

  const InfoSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.08), primary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: primary, size: 20),
                  ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const InfoTile(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final AgentEntity agent;
  final String cardName;

  const InfoCard({super.key, required this.cardName, required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.08), primary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== HEADER =====
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.contact_mail_outlined, color: primary),
              ),
              const SizedBox(width: 12),
              Text(
                cardName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ===== PHONE =====
          _ContactTile(
            icon: Icons.phone_outlined,
            label: "Mobile",
            value: agent.agentMobile,
            color: primary,
            onTap: () {
              // launchUrl(Uri.parse('tel:${agent.agentMobile}'));
            },
          ),

          const SizedBox(height: 12),

          /// ===== EMAIL =====
          _ContactTile(
            icon: Icons.email_outlined,
            label: "Email",
            value: agent.agentEmail,
            color: primary,
            onTap: () {
              // launchUrl(Uri.parse('mailto:${agent.agentEmail}'));
            },
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusInfoCard extends StatelessWidget {
  final AgentEntity agent;
  const StatusInfoCard({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.verified_outlined,
      title: "Status",
      children: [
        _ContactTile(
          color: Theme.of(context).colorScheme.primary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Agent is ${agent.isApproved ? "Approved" : "Not Approved"}',
                ),
              ),
            );
          },
          icon: Icons.verified_user_outlined,
          label: "Approved",
          value: agent.isApproved ? "✓ Yes" : "✗ No",
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

class ImagePreviewCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  const ImagePreviewCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InfoSectionCard(
        icon: Icons.image_outlined,
        title: title,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(imageUrl: imageUrl),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white, size: 50),
                SizedBox(height: 8),
                Text(
                  "Failed to load image",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final String title;
  final String fileUrl;
  const DocumentCard({super.key, required this.title, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    if (fileUrl.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InfoSectionCard(
        icon: Icons.description_outlined,
        title: title,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("View Document"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              openMedia(context, fileUrl);

              // if (fileUrl.toLowerCase().endsWith('.pdf')) {
              //   // If it's a PDF, show the PDF viewer
              //   // Check if the file is a PDF

              //   showModalBottomSheet(
              //     context: context,
              //     isScrollControlled: true,
              //     builder: (context) {
              //       return PdfViewerBottomsheet(
              //         source: fileUrl,
              //         title: title,
              //         isLocal: false,
              //       );
              //     },
              //   );
              // } else {
              //   // Otherwise, assume it's an image and show the image viewer
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => FullScreenImage(imageUrl: fileUrl),
              //     ),
              //   );
              // }
            },
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final AgentEntity agent;
  const ActionButtons({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.call, size: 20),
              label: const Text("Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => launchUrl(Uri.parse("tel:${agent.agentMobile}")),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade500],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.email, size: 20),
              label: const Text("Email"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () =>
                  launchUrl(Uri.parse("mailto:${agent.agentEmail}")),
            ),
          ),
        ),
      ],
    );
  }
}
