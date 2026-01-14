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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: agentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (agent) {
            return CustomScrollView(
              slivers: [
                // ===== APP BAR + PROFILE + TABS =====
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 300,
                  backgroundColor: theme.primaryColor,
                  iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
                  title: SizedBox(
                    height: 56,
                    child: Center(
                      child: Text(
                        agent.agentName,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 18,
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

                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(52),
                    child: TabBar(
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.tab,

                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(fontSize: 13),

                      indicator: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),

                      labelColor: theme.colorScheme.onPrimary,
                      unselectedLabelColor: theme.colorScheme.onPrimary
                          .withOpacity(0.7),

                      tabs: const [
                        SizedBox(
                          height: 48,
                          child: Tab(
                            icon: Icon(Icons.dashboard_outlined),
                            text: "Overview",
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Tab(
                            icon: Icon(Icons.image_outlined),
                            text: "Media",
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Tab(
                            icon: Icon(Icons.call_outlined),
                            text: "Contact",
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Tab(
                            icon: Icon(Icons.verified_outlined),
                            text: "Status",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== TAB CONTENT =====
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      OverviewTab(agent: agent),
                      MediaTab(agent: agent),
                      ContactTab(agent: agent),
                      StatusTab(agent: agent),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
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
    final fullAddress =
        '${agent.agentAddress}, ${agent.agentCity}, ${agent.agentState} - ${agent.agentPincode}';

    return InfoSectionCard(
      icon: Icons.dashboard_customize_outlined,
      title: "Agent Overview",
      children: [
        InfoTile("Agent ID", agent.agentId),
        const SizedBox(height: 8),
        InfoTile("Role", agent.role),
        const SizedBox(height: 8),
        InfoTile("UID", agent.uid),
        const Divider(height: 24),
        InfoTile("Mobile", agent.agentMobile),
        const SizedBox(height: 8),
        InfoTile("Email", agent.agentEmail),
        const Divider(height: 24),
        InfoTile("Address", fullAddress),
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
          ContactInfoCard(agent: agent),
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
      child: StatusInfoCard(agent: agent),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(icon, color: theme.primaryColor, size: 24),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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

class ContactInfoCard extends StatelessWidget {
  final AgentEntity agent;
  const ContactInfoCard({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.contact_mail_outlined,
      title: "Contact Info",
      children: [
        InfoTile("Mobile", agent.agentMobile),
        const SizedBox(height: 8),
        InfoTile("Email", agent.agentEmail),
      ],
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
        InfoTile("Approved", agent.isApproved ? "✓ Yes" : "✗ No"),
        const SizedBox(height: 8),
        InfoTile("Rejected", agent.isRejected ? "✓ Yes" : "✗ No"),
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
