import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/custom/custom_widgets/contact_us_screen.dart';
import '../../../../../app/custom/custom_widgets/user_drawer.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:shadi_milan/features/user/user_app/widgets/agent_bottom_sheet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileScreenProvider =
    StreamProvider.family<MetrimonyProfileViewModel, String>((ref, userId) {
      final repository = ref.watch(matrimonyRepositoryProvider);
      final userRepo = ref.watch(userRepositoryProvider);
      final agentRepo = ref.watch(agentRepositoryProvider);

      return repository.watchMatrimonyProfile(userId).asyncMap((
        matrimonyProfile,
      ) async {
        final user = await userRepo.fetchUser(userId);

        // fetch AgentEntity
        AgentEntity? agent;
        if (user.agentId.isNotEmpty) {
          try {
            agent = await agentRepo.fetchAgent(user.agentId);
          } catch (e) {
            debugPrint(
              'Error fetching agent with ID: ${user.agentId}, Error: $e',
            );
            agent = null;
          }
        } else {
          debugPrint('Agent ID is empty for user: $userId');
        }

        return MetrimonyProfileViewModel(
          metrimonyProfile: matrimonyProfile,
          userProfile: user,
          agentEntity: agent,
        );
      });
    });

@RoutePage()
class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileScreenProvider(userId));
    final theme = Theme.of(context);

    final currentUserAsync = ref.watch(currentUserProvider);
    return Scaffold(
      drawer: UserDrawer(userAsync: currentUserAsync),
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stackTrace) {
          debugPrint(stackTrace.toString());

          return Center(child: Text('Error: $err'));
        },
        data: (profile) {
          return CustomScrollView(
            slivers: [
              ModernGradientAppBar(
                title: "My Profile",
                subtitle: "Manage your account",
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),

              // SliverAppBar(
              //   backgroundColor: Colors.grey[100],
              //   expandedHeight: 120,
              //   floating: false,
              //   pinned: true,
              //   flexibleSpace: FlexibleSpaceBar(
              //     titlePadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 10,
              //     ),
              //     centerTitle: false,
              //     title: Text(
              //       "My Profile",
              //       style: TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: theme.primaryColor,
              //       ),
              //     ),
              //   ),
              // ),
              // SliverAppBar(
              //   backgroundColor: Colors.grey[100],
              //   expandedHeight: 120,
              //   floating: false,
              //   pinned: true,
              //   flexibleSpace: FlexibleSpaceBar(
              //     titlePadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 10,
              //     ),
              //     centerTitle: false,
              //     title: Text(
              //       "My Profile",
              //       style: TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: theme.primaryColor,
              //       ),
              //     ),
              //   ),
              // ),
              SliverToBoxAdapter(child: _ProfileHeaderCard(profile: profile)),

              SliverPadding(
                padding: const EdgeInsets.only(bottom: 1),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // 🔹 TITLE

                        // 🔹 PREMIUM CARD

                        //  check for payments collection if status is success then show premium card
                        Consumer(
                          builder: (context, ref, child) {
                            final paymentState = ref.watch(
                              paymentNotifierProvider(userId),
                            );
                            if (paymentState.status == PayStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            // change after publishing on playstore
                            if (paymentState.status == PayStatus.idle) {
                              print(" this  is payment status");
                              print(paymentState.status);
                              return GestureDetector(
                                onTap: () => AutoRouter.of(context).push(
                                  UserPaymentSuccessRoute(user: profile.user),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Custom Icon Container
                                      Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade500,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.verified_user_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Premium Active",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                            const Text(
                                              "You are a Premium Member!",
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.green.shade300,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return _PremiumCard(profile: profile);
                          },
                        ),

                        // 🔹 GENERAL SECTION
                        _SectionTitle(title: "General"),
                        _SettingsTile(
                          icon: Icons.person_search_outlined,
                          title: "My Profile",
                          onTap: () {
                            AutoRouter.of(
                              context,
                            ).push(MyProfileRoute(uid: userId));
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.support_agent_outlined,
                          title: "Agent Details",
                          onTap: () {
                            if (profile.agentEntity != null) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => AgentBottomSheet(
                                  agent: profile.agentEntity!,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No agent assigned yet."),
                                ),
                              );
                            }
                          },
                        ),

                        // user status
                        _SettingsTile(
                          icon: Icons.verified_user_outlined,
                          title: "User Status",
                          onTap: () {
                            // navigate to user status screen
                            AutoRouter.of(context).push(UserStatusRoute());
                          },
                        ),

                        // // user Review
                        // _SettingsTile(
                        //   icon: Icons.verified_user_outlined,
                        //   title: "My Review",
                        //   onTap: () {
                        //     // navigate to user status screen
                        //     AutoRouter.of(context).push(const MyReviewRoute());
                        //   },
                        // ),

                        // Contact Support
                        // stting tile
                        _SettingsTile(
                          icon: Icons.contact_support_outlined,
                          title: "Contact Support",
                          onTap: () {
                            AutoRouter.of(context).push(const ContactUsRoute());
                          },
                        ),

                        // 🔹 ACCOUNT SETTINGS SECTION
                        _SectionTitle(title: "Account Settings"),

                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: "Change Password",
                          onTap: () {
                            // navigate to change password screen
                            AutoRouter.of(context).push(ChangePasswordRoute());
                          },
                        ),

                        // payment route
                        _SettingsTile(
                          icon: Icons.payment_outlined,
                          title: "Payment History",
                          onTap: () {
                            AutoRouter.of(
                              context,
                            ).push(UserPaymentOrderHistoryRoute());
                          },
                        ),

                        _SettingsTile(
                          icon: Icons.family_restroom_outlined,
                          title: "Post Marriage Payment",
                          onTap: () {
                            AutoRouter.of(context).push(
                              UserAfterMarriagePaymentRoute(userId: userId),
                            );
                          },
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(
                                Theme.of(context).primaryColor,
                              ),
                              side: WidgetStateProperty.all(
                                BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            onPressed: () {
                              //LOGOUT HERE

                              ref.watch(authRepositoryProvider).signOut();

                              AutoRouter.of(context).replace(UserLoginRoute());

                              print("Logout button pressed");
                            },
                            child: const Text("Logout"),
                          ),
                        ),

                        SizedBox(height: 100),
                      ],
                    );
                  }, childCount: 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;

  const _ProfileHeaderCard({required this.profile});

  bool get hasImage => profile.userProfile.profileImageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // 1. Decorative Background Element
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: primaryColor.withOpacity(0.05),
              ),
            ),

            // 2. Main Content
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  // --- Avatar with Status Indicator ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.1),
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: hasImage
                              ? NetworkImage(
                                  profile.userProfile.profileImageUrl,
                                )
                              : null,
                          child: !hasImage
                              ? Text(
                                  profile.userProfile.fullName.isNotEmpty
                                      ? profile.userProfile.fullName[0]
                                            .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      // Verification Badge
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Name & Badge ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          profile.user.fullName ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.stars_rounded,
                        color: Colors.amber[700],
                        size: 20,
                      ),
                    ],
                  ),

                  // --- Subtitle (Email/Role) ---
                  Text(
                    profile.user.email?.toLowerCase() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 20),

                  // --- Profile Stats Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("Profile", "85%"),
                      _buildVerticalDivider(),
                      _buildStatColumn("Status", "Active"),
                      _buildVerticalDivider(),
                      _buildStatColumn("Trust Score", "4.8"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }
}

class _PremiumCard extends StatelessWidget {
  final MetrimonyProfileViewModel? profile;
  const _PremiumCard({this.profile});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (profile != null) {
          // if agent id not present
          if (profile!.user.agentId.isEmpty) {
            // create a model bottom sheet  to take user id or  show contact details if he does not know
            print(" inside bottom sheet");
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,

              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),

              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              // theme color
              backgroundColor: theme.canvasColor,
              builder: (BuildContext context) {
                return AgentFormWidget();
              },
            );

            return;
          }

          AutoRouter.of(
            context,
          ).push(UserPaymentRoute(userId: profile!.userProfile.uid));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.primaryColor.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 50,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upgrade to Premium",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Get unlimited access to all features and connect with more matches.",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.primaryColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// creat a state provider for tab
final agentSetupProvider = StateProvider<int>((ref) => 1);

final agentDetailProvider = StateProvider<int>((ref) => 0);

class AgentFormWidget extends ConsumerStatefulWidget {
  const AgentFormWidget({super.key});

  @override
  ConsumerState<AgentFormWidget> createState() => _AgentFormWidgetState();
}

class _AgentFormWidgetState extends ConsumerState<AgentFormWidget> {
  final TextEditingController _agentIdController = TextEditingController();
  AgentEntity? _fetchedAgent;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _agentIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchAgent() async {
    final agentId = _agentIdController.text.trim();
    if (agentId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fetchedAgent = null;
    });

    try {
      final agent = await ref
          .read(agentRepositoryProvider)
          .fetchAgentEntitybyAgentId(agentId);

      if (mounted) {
        setState(() {
          _fetchedAgent = agent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Agent not found or invalid ID";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(agentSetupProvider);
    final agentDetail = ref.watch(agentDetailProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: "Agent Setup"),
            const SizedBox(height: 12),

            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: _ActionTab(
                    icon: Icons.person_add_alt_1_outlined,
                    title: "Enter Agent ID",
                    isSelected: selectedTab == 1,
                    onTap: () {
                      ref.read(agentSetupProvider.notifier).state = 1;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTab(
                    icon: Icons.contact_phone_outlined,
                    title: "Contact Support",
                    isSelected: selectedTab == 2,

                    onTap: () {
                      ref.read(agentSetupProvider.notifier).state = 2;
                    },
                  ),
                ),

                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 24),

            if (selectedTab == 1)
              _buildAgentForm()
            else
              _buildContactAndSupportForm(),
          ],
        ),
      ),
    );
  }

  void _assignAgent({required String agentId}) {
    if (agentId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter Agent ID")));
      return;
    }

    ref
        .read(userRepositoryProvider)
        .updateAgentId(
          ref.read(authRepositoryProvider).currentUser!.uid,
          agentId,
        );

    /// update state
    ref.invalidate(
      userProfileScreenProvider(
        ref.read(authRepositoryProvider).currentUser!.uid,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Agent $agentId assigned successfully!")),
    );

    _agentIdController.clear();
    Navigator.pop(context);
  }

  Container _buildAgentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Assign an agent to your profile to get personalized assistance and faster service.",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _agentIdController,
            decoration: InputDecoration(
              labelText: "Agent ID",
              hintText: "Enter Agent ID (e.g., AGT-12345)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _fetchAgent,
              ),
            ),
            onSubmitted: (_) => _fetchAgent(),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red))
          else if (_fetchedAgent != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,

                    backgroundImage: _fetchedAgent!.profileImageUrl.isNotEmpty
                        ? NetworkImage(_fetchedAgent!.profileImageUrl)
                        : null,

                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.15),
                  ),
                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Agent Details:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Name: ${_fetchedAgent!.agentName}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        "Mobile: ${_fetchedAgent!.agentMobile}",
                      ),
                      Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        "Email: ${_fetchedAgent!.agentEmail}",
                      ),
                      Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        "Agent ID: ${_fetchedAgent!.agentId}",
                      ),
                      Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        "Address: ${_fetchedAgent!.agentAddress}",
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fetchedAgent != null
                  ? () => _assignAgent(agentId: _fetchedAgent!.uid)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Assign Agent", style: TextStyle(fontSize: 16)),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Container _buildContactAndSupportForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "If you don't have an Agent ID, you can contact our support team for assistance.",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            child: Column(
              children: [
                AppTextField(
                  prefixIcon: Icons.person,

                  iconColor: Theme.of(context).primaryColor,
                  label: "Full Name",
                  hint: "Enter your full name",
                  obscureText: false,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  prefixIcon: Icons.email,

                  iconColor: Theme.of(context).primaryColor,
                  label: "Email Address",
                  hint: "Enter your email address",
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  prefixIcon: Icons.phone,
                  iconColor: Theme.of(context).primaryColor,
                  label: "Phone Number",
                  hint: "Enter your phone number",
                  obscureText: false,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  prefixIcon: Icons.message,
                  iconColor: Theme.of(context).primaryColor,
                  label: "Message",
                  hint: "Enter your message",
                  obscureText: false,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Your request has been submitted. Our team will contact you shortly.",
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Submit Request",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  final VoidCallback onTap;

  const _ActionTab({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? theme.primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? theme.primaryColor : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
