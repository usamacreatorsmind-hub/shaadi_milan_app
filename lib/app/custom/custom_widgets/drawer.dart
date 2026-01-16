import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/app_router.dart';
import '../../../features/auth/domain/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:riverpod/src/framework.dart';

class AppDrawer extends ConsumerWidget {
  AsyncValue<dynamic> agentAsync;

  AppDrawer({super.key, required this.agentAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Drawer(
      child: agentAsync.when(
        data: (data) {
          return Column(
            children: [
              // ===== HEADER =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 48,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,

                      backgroundImage: data.profileImageUrl.isNotEmpty
                          ? NetworkImage(data.profileImageUrl)
                          : null,
                      child: data.profileImageUrl.isEmpty
                          ? Text(
                              data.agentName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                color: theme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.agentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.agentEmail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Agent ID: ${data.agentId}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ===== MENU ITEMS =====
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerItem(
                      icon: Icons.dashboard_outlined,
                      title: "Dashboard",
                      onTap: () {
                        context.popRoute();
                      },
                    ),
                    DrawerItem(
                      icon: Icons.people_outline,
                      title: "My Clients",
                      onTap: () {
                        context.popRoute();
                      },
                    ),

                    DrawerItem(
                      icon: Icons.bar_chart_outlined,
                      title: "Analytics",
                      onTap: () {
                        context.popRoute();
                      },
                    ),
                    DrawerItem(
                      icon: Icons.reviews_outlined,
                      title: "Reviews",
                      onTap: () {
                        context.popRoute();
                        context.pushRoute(const ReviewRoute());
                      },
                    ),

                    DrawerItem(
                      icon: Icons.support_agent,
                      title: "Support Tickets",
                      onTap: () {
                        context.popRoute();
                        context.pushRoute(
                          AgentSupportRoute(agentId: data.agentId),
                        );
                      },
                    ),

                    DrawerItem(
                      icon: Icons.description_outlined,
                      title: "Documents",
                      onTap: () {
                        context.popRoute();
                      },
                    ),
                    const Divider(),
                    DrawerItem(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () {
                        context.popRoute();
                        context.pushRoute(const AgentSettingsRoute());
                      },
                    ),

                    DrawerItem(
                      icon: Icons.person_outline,
                      title: "My Profile",
                      onTap: () {
                        context.popRoute();
                        context.pushRoute(AgentEntityRoute(uid: data.agentId));
                      },
                    ),
                    DrawerItem(
                      icon: Icons.reviews_outlined,
                      title: "My Reviews",
                      onTap: () {
                        context.popRoute();
                        context.pushRoute(const MyReviewRoute());
                      },
                    ),
                  ],
                ),
              ),

              // ===== LOGOUT =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: clear auth + navigate to login
                      ref.read(authRepositoryProvider).signOut();
                      context.router.replace(const AgentLoginRoute());
                    },
                  ),
                ),
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) {
          return Text("error occurred");
        },
        loading: () {
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}
