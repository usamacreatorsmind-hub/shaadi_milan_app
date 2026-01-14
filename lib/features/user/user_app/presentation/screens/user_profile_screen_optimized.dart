// import 'package:arvika_marriage_bureau/app/custom/custom_widgets/animated_app_bar.dart';
// import 'package:arvika_marriage_bureau/app/custom/custom_widgets/user_drawer.dart';
// import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
// import 'package:arvika_marriage_bureau/app/router/app_router.dart';
// import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
// import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/matrimony_repository_impl.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/user_status_controller.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/widgets/agent_bottom_sheet.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// /// Provider for user profile screen data
// final userProfileScreenProvider =
//     StreamProvider.family<MetrimonyProfileViewModel, String>((ref, userId) {
//       final repository = ref.watch(matrimonyRepositoryProvider);
//       final userRepo = ref.watch(userRepositoryProvider);
//       final agentRepo = ref.watch(agentRepositoryProvider);

//       return repository.watchMatrimonyProfile(userId).asyncMap((
//         matrimonyProfile,
//       ) async {
//         final user = await userRepo.fetchUser(userId);

//         // Fetch AgentEntity
//         AgentEntity? agent;
//         if (matrimonyProfile.agentId.isNotEmpty) {
//           try {
//             agent = await agentRepo.fetchAgent(matrimonyProfile.agentId);
//           } catch (e) {
//             debugPrint('Error fetching agent: $e');
//             agent = null;
//           }
//         }

//         return MetrimonyProfileViewModel(
//           metrimonyProfile: matrimonyProfile,
//           userProfile: user,
//           agentEntity: agent,
//         );
//       });
//     });

// @RoutePage()
// class UserProfileScreenOptimized extends ConsumerWidget {
//   final String userId;

//   const UserProfileScreenOptimized({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final profileAsync = ref.watch(userProfileScreenProvider(userId));
//     final theme = Theme.of(context);
//     final currentUserAsync = ref.watch(currentUserProvider);

//     return Scaffold(
//       drawer: UserDrawer(userAsync: currentUserAsync),
//       backgroundColor: Colors.grey[50],
//       body: profileAsync.when(
//         loading: () => const _LoadingView(),
//         error: (err, stackTrace) => _ErrorView(error: err.toString()),
//         data: (profile) => _ProfileContent(profile: profile, userId: userId),
//       ),
//     );
//   }
// }

// /// Loading view with shimmer effect
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         const MinimalAppBar(title: "Home", showShadow: false),
//         SliverFillRemaining(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Loading your profile...',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// Error view
// class _ErrorView extends StatelessWidget {
//   final String error;

//   const _ErrorView({required this.error});

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         const MinimalAppBar(title: 'My Profile'),
//         SliverFillRemaining(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Oops! Something went wrong',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     error,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// Main profile content
// class _ProfileContent extends ConsumerWidget {
//   final MetrimonyProfileViewModel profile;
//   final String userId;

//   const _ProfileContent({required this.profile, required this.userId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return CustomScrollView(
//       slivers: [
//         // Modern app bar
//         ModernGradientAppBar(
//           title: 'My Profile',
//           subtitle: 'Manage your account',
//           centerTitle: false,
//         ),

//         // Profile header card
//         SliverToBoxAdapter(child: _ProfileHeaderCard(profile: profile)),

//         // Premium/Subscription section
//         SliverToBoxAdapter(
//           child: _PremiumSection(profile: profile, userId: userId),
//         ),

//         // Settings sections
//         SliverPadding(
//           padding: const EdgeInsets.only(bottom: 100),
//           sliver: SliverList(
//             delegate: SliverChildListDelegate([
//               const _SectionTitle(title: 'General'),
//               _ProfileSettingsTile(
//                 icon: Icons.person_search_outlined,
//                 title: 'My Profile',
//                 subtitle: 'View and edit your profile',
//                 onTap: () => context.router.push(MyProfileRoute(uid: userId)),
//               ),
//               _ProfileSettingsTile(
//                 icon: Icons.support_agent_outlined,
//                 title: 'Agent Details',
//                 subtitle: profile.agentEntity != null
//                     ? 'View your agent information'
//                     : 'No agent assigned',
//                 onTap: () => _showAgentDetails(context, profile),
//               ),
//               _ProfileSettingsTile(
//                 icon: Icons.verified_user_outlined,
//                 title: 'User Status',
//                 subtitle: 'Check verification status',
//                 onTap: () => context.router.push(const UserStatusRoute()),
//               ),
//               _ProfileSettingsTile(
//                 icon: Icons.contact_support_outlined,
//                 title: 'Contact Support',
//                 subtitle: 'Get help from our team',
//                 onTap: () => context.router.push(const ContactUsRoute()),
//               ),

//               const _SectionTitle(title: 'Account Settings'),
//               _ProfileSettingsTile(
//                 icon: Icons.lock_outline,
//                 title: 'Change Password',
//                 subtitle: 'Update your password',
//                 onTap: () => context.router.push(const ChangePasswordRoute()),
//               ),
//               _ProfileSettingsTile(
//                 icon: Icons.payment_outlined,
//                 title: 'Payment History',
//                 subtitle: 'View your transactions',
//                 onTap: () =>
//                     context.router.push(const UserPaymentOrderHistoryRoute()),
//               ),

//               // Logout button
//               _LogoutButton(ref: ref),

//               const SizedBox(height: 24),
//             ]),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showAgentDetails(
//     BuildContext context,
//     MetrimonyProfileViewModel profile,
//   ) {
//     if (profile.agentEntity != null) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (context) => AgentBottomSheet(agent: profile.agentEntity!),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No agent assigned yet.'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
// }

// /// Enhanced profile header card
// class _ProfileHeaderCard extends StatelessWidget {
//   final MetrimonyProfileViewModel profile;

//   const _ProfileHeaderCard({required this.profile});

//   bool get hasImage => profile.userProfile.profileImageUrl.isNotEmpty;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(
//           colors: [Colors.white, theme.primaryColor.withOpacity(0.02)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.primaryColor.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 24),
//           // Avatar
//           _buildAvatar(theme),
//           const SizedBox(height: 16),

//           // Name and badge
//           _buildNameSection(theme),

//           // Email
//           _buildEmailSection(),

//           const SizedBox(height: 24),
//           const Divider(height: 1, thickness: 0.5),
//           const SizedBox(height: 16),

//           // Stats
//           _buildStatsRow(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildAvatar(ThemeData theme) {
//     return Hero(
//       tag: 'profile-avatar-${profile.user.uid}',
//       child: Stack(
//         alignment: Alignment.bottomRight,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: theme.primaryColor.withOpacity(0.2),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: CircleAvatar(
//               radius: 56,
//               backgroundColor: theme.primaryColor.withOpacity(0.1),
//               backgroundImage: hasImage
//                   ? NetworkImage(profile.userProfile.profileImageUrl)
//                   : null,
//               child: !hasImage
//                   ? Text(
//                       profile.userProfile.fullName.isNotEmpty
//                           ? profile.userProfile.fullName[0].toUpperCase()
//                           : '?',
//                       style: TextStyle(
//                         fontSize: 42,
//                         fontWeight: FontWeight.bold,
//                         color: theme.primaryColor,
//                       ),
//                     )
//                   : null,
//             ),
//           ),
//           // Verification badge
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 3),
//             ),
//             child: const Icon(Icons.check, color: Colors.white, size: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNameSection(ThemeData theme) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Flexible(
//           child: Text(
//             profile.user.fullName ?? 'N/A',
//             style: const TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A1A),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Icon(Icons.stars_rounded, color: Colors.amber[700], size: 22),
//       ],
//     );
//   }

//   Widget _buildEmailSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Text(
//         profile.user.email?.toLowerCase() ?? 'N/A',
//         style: TextStyle(
//           fontSize: 14,
//           color: Colors.grey[600],
//           letterSpacing: 0.3,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildStatsRow() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildStatColumn(
//             Icons.verified_outlined,
//             'Complete',
//             '85%',
//             Colors.blue,
//           ),
//           _buildVerticalDivider(),
//           _buildStatColumn(
//             Icons.favorite_outline,
//             'Wishlists',
//             '${profile.user.wishlists.length}',
//             Colors.red,
//           ),
//           _buildVerticalDivider(),
//           _buildStatColumn(Icons.star_outline, 'Rating', '4.8', Colors.amber),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatColumn(
//     IconData icon,
//     String label,
//     String value,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//       ],
//     );
//   }

//   Widget _buildVerticalDivider() {
//     return Container(height: 50, width: 1, color: Colors.grey[200]);
//   }
// }

// /// Premium section with subscription status
// class _PremiumSection extends ConsumerWidget {
//   final MetrimonyProfileViewModel profile;
//   final String userId;

//   const _PremiumSection({required this.profile, required this.userId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userStatusState = ref.watch(userStatusControllerProvider);

//     if (userStatusState.isLoading) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (userStatusState.userStatus.subscriptionActive) {
//       return _ActivePremiumCard(profile: profile);
//     }

//     return _UpgradePremiumCard(profile: profile);
//   }
// }

// /// Active premium card
// class _ActivePremiumCard extends StatelessWidget {
//   final MetrimonyProfileViewModel profile;

//   const _ActivePremiumCard({required this.profile});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () =>
//           context.router.push(UserPaymentSuccessRoute(user: profile.user)),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade400, Colors.green.shade600],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.green.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: 50,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.verified_user_rounded,
//                 color: Colors.white,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'PREMIUM ACTIVE',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.white70,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'You are a Premium Member!',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Colors.white70,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Upgrade premium card
// class _UpgradePremiumCard extends StatelessWidget {
//   final MetrimonyProfileViewModel profile;

//   const _UpgradePremiumCard({required this.profile});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return GestureDetector(
//       onTap: () => _handleUpgrade(context, profile),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               theme.primaryColor.withOpacity(0.1),
//               theme.primaryColor.withOpacity(0.05),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.primaryColor.withOpacity(0.3),
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.workspace_premium_outlined,
//               size: 50,
//               color: theme.primaryColor,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Upgrade to Premium',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: theme.primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Unlock unlimited features and find your perfect match faster',
//                     style: TextStyle(fontSize: 13, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: theme.primaryColor.withOpacity(0.6),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleUpgrade(BuildContext context, MetrimonyProfileViewModel profile) {
//     if (profile.user.agentId.isEmpty) {
//       // Show agent assignment modal
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.9,
//         ),
//         builder: (context) => const AgentFormWidget(),
//       );
//     } else {
//       context.router.push(UserPaymentRoute(metrimonyProfileViewModel: profile));
//     }
//   }
// }

// /// Enhanced settings tile with better UX
// class _ProfileSettingsTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback? onTap;
//   final Widget? trailing;

//   const _ProfileSettingsTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     this.onTap,
//     this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: Container(
//           height: 48,
//           width: 48,
//           decoration: BoxDecoration(
//             color: theme.primaryColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: theme.primaryColor, size: 24),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//         ),
//         trailing:
//             trailing ??
//             Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
//         onTap: onTap,
//       ),
//     );
//   }
// }

// /// Section title widget
// class _SectionTitle extends StatelessWidget {
//   final String title;

//   const _SectionTitle({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }
// }

// /// Logout button widget
// class _LogoutButton extends StatelessWidget {
//   final WidgetRef ref;

//   const _LogoutButton({required this.ref});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: OutlinedButton.icon(
//         icon: const Icon(Icons.logout_outlined),
//         label: const Text('Logout'),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: Colors.red,
//           side: const BorderSide(color: Colors.red, width: 1.5),
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         onPressed: () => _handleLogout(context),
//       ),
//     );
//   }

//   void _handleLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               ref.read(authRepositoryProvider).signOut();
//               Navigator.pop(context);
//               context.router.replace(const UserLoginRoute());
//             },
//             child: const Text('Logout', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Agent form widget (placeholder - use existing implementation)
// class AgentFormWidget extends StatelessWidget {
//   const AgentFormWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             'Agent Assignment',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Please assign an agent to continue with premium subscription.',
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }
