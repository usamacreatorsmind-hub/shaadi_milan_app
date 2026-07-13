import 'package:shadi_milan/app/custom/custom_widgets/drawer.dart';
import 'package:shadi_milan/features/user/user_app/presentation/screens/user_details_screen.dart';

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
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // ── 1. PLAIN TOOLBAR (no FlexibleSpace, no expandedHeight) ──
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    // No expandedHeight → height is exactly kToolbarHeight
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: innerBoxIsScrolled ? 4 : 0,
                    title: AnimatedOpacity(
                      // Only show name in toolbar when user has scrolled
                      opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        agent.agentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    centerTitle: true,
                  ),

                  // ── 2. PROFILE HEADER (natural height, no overlap) ──────────
                  SliverToBoxAdapter(
                    child: Container(
                      color: theme.primaryColor,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: ProfileHeader(agent: agent),
                    ),
                  ),

                  // ── 3. STICKY TAB BAR ───────────────────────────────────────
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: theme.primaryColor,
                        tabAlignment: TabAlignment.center,
                        isScrollable: true,
                        indicatorColor: theme.primaryColor,
                        indicatorWeight: 3,
                        unselectedLabelColor: Colors.grey,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        dividerColor: Colors.grey.shade200,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
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
  double get minExtent => _tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabBar,
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
        ],
      ),
    );
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with white border ring
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: agent.profileImageUrl.isNotEmpty
                ? NetworkImage(agent.profileImageUrl)
                : null,
            child: agent.profileImageUrl.isEmpty
                ? Text(
                    agent.agentName.isNotEmpty
                        ? agent.agentName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),

        const SizedBox(height: 12),

        // Name — white on primary background
        Text(
          agent.agentName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),

        const SizedBox(height: 4),

        // Email — slightly translucent white
        Text(
          agent.agentEmail,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Approval badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: agent.isApproved
                ? Colors.green.withValues(alpha: 0.25)
                : Colors.red.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: agent.isApproved
                  ? Colors.green.shade300
                  : Colors.red.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                agent.isApproved
                    ? Icons.verified_rounded
                    : Icons.cancel_rounded,
                size: 14,
                color: agent.isApproved
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
              const SizedBox(width: 4),
              Text(
                agent.isApproved ? 'Approved' : 'Not Approved',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: agent.isApproved
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
            ],
          ),
        ),
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
