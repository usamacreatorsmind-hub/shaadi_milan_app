import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/app_router.dart';
import '../../../features/auth/domain/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:riverpod/src/framework.dart';

class AppDrawer extends ConsumerWidget {
  final AsyncValue<dynamic> agentAsync;

  const AppDrawer({super.key, required this.agentAsync});

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
                      data.designation.label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${AppLabels.agentIdLabel(context)}${data.agentId}",
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
                      title: AppLabels.dashboard(context),
                      onTap: () {
                        context.maybePop();
                      },
                    ),
                    DrawerItem(
                      icon: Icons.people_outline,
                      title: AppLabels.myClients(context),
                      onTap: () {
                        context.maybePop();
                      },
                    ),

                    DrawerItem(
                      icon: Icons.bar_chart_outlined,
                      title: AppLabels.analytics(context),
                      onTap: () {
                        context.maybePop();
                      },
                    ),

                    // DrawerItem(
                    //   icon: Icons.reviews_outlined,
                    //   title: "Reviews",
                    //   onTap: () {
                    //     context.maybePop();
                    //     context.pushRoute(  ReviewRoute());
                    //   },
                    // ),
                    DrawerItem(
                      icon: Icons.support_agent,
                      title: AppLabels.supportTickets(context),
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(
                          AgentSupportRoute(agentId: data.agentId),
                        );
                      },
                    ),

                    DrawerItem(
                      icon: Icons.description_outlined,
                      title: AppLabels.documents(context),
                      onTap: () {
                        context.maybePop();
                      },
                    ),
                    const Divider(),
                    DrawerItem(
                      icon: Icons.settings_outlined,
                      title: AppLabels.settings(context),
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(AgentSettingsRoute());
                      },
                    ),

                    DrawerItem(
                      icon: Icons.person_outline,
                      title: AppLabels.myProfile(context),
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(AgentEntityRoute(uid: data.agentId));
                      },
                    ),
                    // DrawerItem(
                    //   icon: Icons.reviews_outlined,
                    //   title: "My Reviews",
                    //   onTap: () {
                    //     context.maybePop();
                    //     context.pushRoute(MyReviewRoute());
                    //   },
                    // ),
                    const Divider(),
                    DrawerItem(
                      icon: Icons.logout_rounded,
                      title: AppLabels.logout(context),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLabels.logout(context)),
                            content: Text(AppLabels.logoutConfirm(context)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(AppLabels.cancel(context)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  AppLabels.logout(context),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) {
                            context.router.replaceAll([const AuthWrapperRoute()]);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) {
          return Text(AppLabels.errorOccurred(context));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
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
