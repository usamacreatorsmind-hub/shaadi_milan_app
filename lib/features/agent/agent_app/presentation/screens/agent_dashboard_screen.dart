import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/app_version_config/remote_config_service.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

import '../../../../../app/custom/custom_widgets/drawer.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../l10n/app_translation_service.dart';
import '../notifier/analytics_provider.dart';
import '../notifier/user_nofier.dart';
import 'agen_profile.screen.dart';

@RoutePage()
class AgentDashboardScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentDashboardScreen({required this.agentId, super.key});

  @override
  ConsumerState<AgentDashboardScreen> createState() =>
      _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends ConsumerState<AgentDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await RemoteConfigService.instance.checkForUpdate(context);
        await RemoteConfigService.instance.checkForMaintenanceMode(context);
      } catch (e) {
        debugPrint('RemoteConfig check failed on AgentHomeScreen: $e');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(usersPaymentsNotifierProvider.notifier)
          .getUsersPayment(agentId: widget.agentId);
      ref.read(agentUsersNotifierProvider.notifier).getUsersForAgent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsProvider(widget.agentId));
    final usersAsync = ref.watch(agentUsersNotifierProvider);
    final theme = Theme.of(context);

    final agentAsync = ref.watch(agentProvider(widget.agentId));

    return Scaffold(
      drawer: AppDrawer(agentAsync: agentAsync),

      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,

            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),

            floating: false,
            pinned: true,
            title: Text(
              AppLabels.dashboardTitle(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.primaryColor, theme.colorScheme.secondary],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        AppLabels.welcome(context),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      agentAsync.when(
                        data: (agent) => Text(
                          agent.agentName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => Text(
                          AppLabels.loading(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        error: (error, stack) => Text(
                          AppLabels.staffMember(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // 🌐 Language Toggle
              PopupMenuButton<String>(
                icon: const Icon(Icons.translate, color: Colors.white),
                onSelected: (String code) {
                  ref.read(appTranslationServiceProvider).setLanguageCode(code);
                  ref.read(localeProvider.notifier).state = Locale(code);
                },
                itemBuilder: (BuildContext context) => AppTranslation
                    .supportedTranslations
                    .map(
                      (lang) => PopupMenuItem<String>(
                        value: lang.languageCode,
                        child: Text(lang.nativeName),
                      ),
                    )
                    .toList(),
              ),

              // notificattion
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  context.router.push(const AgentnotificationRoute());
                },
              ),

              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(analyticsAsync, usersAsync),
                  const SizedBox(height: 24),
                  Text(
                    AppLabels.quickActions(context),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLabels.recentClients(context),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          AutoTabsRouter.of(context).setActiveIndex(1);
                        },
                        child: Text(AppLabels.viewAll(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRecentClientsList(usersAsync),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    AsyncValue<dynamic> analyticsAsync,
    AsyncValue<dynamic> usersAsync,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: AppLabels.totalRevenue(context),
          value: analyticsAsync.when(
            data: (data) => '₹${data.totalRevenue}',
            loading: () => '...',
            error: (_, __) => AppLabels.somethingWentWrong(context),
          ),
          icon: Icons.currency_rupee,
          color: Colors.green,
        ),
        _buildStatCard(
          title: AppLabels.totalClients(context),
          value: usersAsync.when(
            data: (data) => '${data.length}',
            loading: () => '...',
            error: (_, __) => AppLabels.somethingWentWrong(context),
          ),
          icon: Icons.people,
          color: Colors.blue,
        ),

        _buildStatCard(
          title: AppLabels.totalCommission(context),
          value: analyticsAsync.when(
            data: (data) => '₹${data.totalCommission.toStringAsFixed(0)}',
            loading: () => '...',
            error: (_, __) => AppLabels.somethingWentWrong(context),
          ),
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
        ),

        _buildStatCard(
          title: AppLabels.pending(context),
          value: analyticsAsync.when(
            data: (data) => '${data.pendingCount}',
            loading: () => '...',
            error: (_, __) => AppLabels.somethingWentWrong(context),
          ),
          icon: Icons.pending_actions,
          color: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          context,
          icon: Icons.analytics,
          label: AppLabels.reports(context),
          color: Colors.blue,
          onTap: () {
            AutoTabsRouter.of(context).setActiveIndex(2);
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.support_agent,
          label: AppLabels.support(context),
          color: Colors.teal,
          onTap: () {
            context.router.push(const ContactUsRoute());
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentClientsList(AsyncValue<dynamic> usersAsync) {
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(AppLabels.noClientsYet(context)),
            ),
          );
        }
        final recentUsers = users.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentUsers.length,
          itemBuilder: (context, index) {
            final user = recentUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user.email),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  context.router.push(ViewUserRoute(userId: user.uid));
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('${AppLabels.errorOccurred(context)}: $e')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLabels.logout(context)),
          content: Text(AppLabels.logoutConfirm(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLabels.cancel(context)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
              },
              child: Text(
                AppLabels.logout(context),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
