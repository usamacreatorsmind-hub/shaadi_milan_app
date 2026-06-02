import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/core/filters/home_filter_controller.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/domain/states/match_filter_state.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/metrimony_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/religion_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/state_city.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/pdf_viewer_bottomsheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifier/user_nofier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ViewUserScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool showMatchButton;

  const ViewUserScreen({
    super.key,
    required this.userId,
    this.showMatchButton = true,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends ConsumerState<ViewUserScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentUserNotifierProvider.notifier).fetchUserById(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _closeProfile(BuildContext context, String userId) async {
    try {
      final registrationPayment = await ref
          .read(userPaymentDsProvider)
          .getUserPayment(
            userId: userId,
            agentId: FirebaseAuth.instance.currentUser!.uid,
          );

      if (registrationPayment == null ||
          registrationPayment.status != 'SUCCESS') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot close profile: User has not completed registration payment.',
              ),
            ),
          );
        }
        return;
      }

      final payments = await ref
          .read(userPaymentDsProvider)
          .getAfterMarriagePaymentForUser(userId: userId);

      if (payments == null || payments.status != 'SUCCESS') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot close profile: No successful after-marriage payment found.',
              ),
            ),
          );
        }
        return;
      }

      await ref
          .read(agentUserNotifierProvider.notifier)
          .closeMatrimonyProfile(userId);

      ref.invalidate(agentUserNotifierProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile closed successfully')),
        );
        context.router.maybePop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to close profile: $e')));
      }
    }
  }

  void _showCloseProfileDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close Matrimony Profile'),
        content: const Text(
          'Are you sure you want to close this matrimony profile?\n\n'
          'This user will not appear in search or receive interests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _closeProfile(context, userId);
            },
            child: const Text('Close Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(agentUserNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => context.router.maybePop(),
        ),
        title: userAsync.maybeWhen(
          data: (user) => Text(
            user?.fullName ?? 'User Profile',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
          orElse: () => Text(
            'User Profile',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
        actions: [
          userAsync.maybeWhen(
            data: (user) {
              if (widget.showMatchButton &&
                  user != null &&
                  user.profileStatus == 'active') {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 235, 227, 227),
                  ),
                  onPressed: () => _showCloseProfileDialog(context, user.uid),
                  child: const Text('Close Profile'),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
            alpha: 0.6,
          ),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
            Tab(icon: Icon(Icons.favorite_border), text: 'Matrimony Profile'),
          ],
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error Loading User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(agentUserNotifierProvider.notifier)
                    .fetchUserById(widget.userId),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('User Not Found'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _UserProfileTab(user: user),
              _MatrimonyProfileTab(userId: widget.userId),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.showMatchButton
          ? _MatchProfilesBottomBar(userId: widget.userId)
          : null,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// TAB 1 – User Profile (data from `users` collection)
// ──────────────────────────────────────────────────────────────

class _UserProfileTab extends StatelessWidget {
  final dynamic user; // UserEntity

  const _UserProfileTab({required this.user});

  String _formatDate(DateTime dt) {
    if (dt.millisecondsSinceEpoch == 0) return 'Not available';
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              children: [
                Hero(
                  tag: 'user-avatar-${user.uid}',
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                      image: user.profileImageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(user.profileImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.profileImageUrl.isEmpty
                        ? Center(
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatusItem(
                      icon: user.isProfileCreated
                          ? Icons.check_circle
                          : Icons.error,
                      label: 'Bio Data',
                      value: user.isProfileCreated ? 'Created' : 'Pending',
                      color: user.isProfileCreated
                          ? Colors.green
                          : Colors.orange,
                    ),
                    _StatusItem(
                      icon: Icons.verified_user,
                      label: 'Profile Status',
                      value: user.profileStatus,
                      color: user.profileStatus == 'active'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contact
          _SectionCard(
            title: 'Contact Information',
            icon: Icons.contact_mail,
            children: [
              _InfoRow(
                'Phone',
                user.phone.isNotEmpty ? user.phone : 'Not provided',
              ),
              const Divider(height: 16),
              _InfoRow('Email', user.email),
            ],
          ),

          // Account
          _SectionCard(
            title: 'Account Information',
            icon: Icons.account_box,
            children: [
              _InfoRow('Role', user.role.isNotEmpty ? user.role : 'User'),
              const Divider(height: 16),
              _InfoRow(
                'Gender',
                user.gender.isNotEmpty ? user.gender : 'Not specified',
              ),
            ],
          ),

          // Activity
          _SectionCard(
            title: 'Activity',
            icon: Icons.history,
            children: [
              _InfoRow('Created At', _formatDate(user.createdAt)),
              const Divider(height: 16),
              _InfoRow('Last Seen', _formatDate(user.lastSeen)),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// TAB 2 – Matrimony Profile (data from `metrimony_profiles`)
// ──────────────────────────────────────────────────────────────

class _MatrimonyProfileTab extends ConsumerWidget {
  final String userId;

  const _MatrimonyProfileTab({required this.userId});

  void _showNoProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.favorite_border, size: 56, color: Colors.grey),
        title: const Text(
          'Matrimony Profile Not Found',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'This user has not created a matrimony profile yet.\n\n'
          'Please ask the user to complete their profile setup through the app.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(matrimonyProfileViewModelProvider(userId), (prev, next) {
      // Show dialog on first transition to null data (profile doesn't exist yet)
      if (next.hasValue &&
          next.value == null &&
          (prev == null || prev.isLoading)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _showNoProfileDialog(context);
        });
      }
    });

    final profileAsync = ref.watch(matrimonyProfileViewModelProvider(userId));

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Matrimony profile not available'),
          ],
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Matrimony profile not created yet'),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _MatrimonyHeaderCard(profile: profile),
              const SizedBox(height: 16),

              // Identity
              _SectionCard(
                title: 'Identity Information',
                icon: Icons.person,
                children: [
                  _InfoRow('Full Name', profile.user.fullName),
                  _InfoRow(
                    'Date of Birth',
                    profile.identity.dob.toLocal().toString().split(' ')[0],
                  ),
                  _InfoRow('Age', '${profile.identity.age} years'),
                  _InfoRow('Gender', profile.identity.gender),
                  _InfoRow('Aadhar', profile.identity.aadhar),
                  if (profile.identity.aboutMe.isNotEmpty)
                    _InfoRow('About Me', profile.identity.aboutMe),
                ],
              ),
              const SizedBox(height: 16),

              // Physical
              _SectionCard(
                title: 'Physical Information',
                icon: Icons.accessibility,
                children: [
                  _InfoRow('Height', '${profile.physical.height} cm'),
                  _InfoRow('Weight', '${profile.physical.weight} kg'),
                  _InfoRow('Body Type', profile.physical.bodyType),
                  _InfoRow('Complexion', profile.physical.complexion),
                  _InfoRow(
                    'Physically Challenged',
                    profile.physical.physicallyChallenged ? 'Yes' : 'No',
                  ),
                  if (profile.physical.disabilityDetails != null)
                    _InfoRow(
                      'Disability Details',
                      profile.physical.disabilityDetails!,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Cultural
              _SectionCard(
                title: 'Cultural Information',
                icon: Icons.temple_hindu,
                children: [
                  _InfoRow('Religion', profile.cultural.religion),
                  _InfoRow('Caste', profile.cultural.caste),
                  _InfoRow('Sub Caste', profile.cultural.subCaste),
                  _InfoRow('Languages', profile.cultural.languages.join(', ')),
                ],
              ),
              const SizedBox(height: 16),

              // Education
              _SectionCard(
                title: 'Education',
                icon: Icons.school,
                children: [
                  _InfoRow(
                    'Is Illiterate',
                    profile.education.isIlletrate ? 'Yes' : 'No',
                  ),
                  if (!profile.education.isIlletrate &&
                      profile.education.education != null) ...[
                    _InfoRow('Course', profile.education.education!.course),
                    _InfoRow(
                      'College / University',
                      profile.education.education!.college,
                    ),
                    _InfoRow(
                      'Passing Year',
                      '${profile.education.education!.passingYear}',
                    ),
                    _InfoRow(
                      'Percentage',
                      '${profile.education.education!.percentage}%',
                    ),
                  ],
                  if (profile
                          .education
                          .extraQualification
                          ?.qualifications
                          .isNotEmpty ==
                      true)
                    _InfoRow(
                      'Extra Qualifications',
                      profile.education.extraQualification!.qualifications.join(
                        ', ',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Employment
              _SectionCard(
                title: 'Employment',
                icon: Icons.work,
                children: [
                  _InfoRow('Job Type', profile.employment.jobType),
                  if (profile.employment.company != null)
                    _InfoRow('Company', profile.employment.company!),
                  if (profile.employment.designation != null)
                    _InfoRow('Designation', profile.employment.designation!),
                  if (profile.employment.annualIncome != null)
                    _InfoRow(
                      'Annual Income',
                      '₹${profile.employment.annualIncome}',
                    ),
                  if (profile.employment.workLocation != null)
                    _InfoRow('Work Location', profile.employment.workLocation!),
                ],
              ),
              const SizedBox(height: 16),

              // Family
              _SectionCard(
                title: 'Family Information',
                icon: Icons.family_restroom,
                children: [
                  _InfoRow("Father's Name", profile.family.fatherName),
                  _InfoRow("Mother's Name", profile.family.motherName),
                  _InfoRow('Brothers', '${profile.family.numberOfBrothers}'),
                  _InfoRow('Sisters', '${profile.family.numberOfSisters}'),
                  _InfoRow('Family Type', profile.family.familyType),
                  _InfoRow('Family Status', profile.family.familyStatus),
                ],
              ),
              const SizedBox(height: 16),

              // Address
              _SectionCard(
                title: 'Address',
                icon: Icons.location_on,
                children: [
                  _InfoRow('Address', profile.address.addressLine1),
                  _InfoRow('Post', profile.address.post),
                  _InfoRow('Police Station', profile.address.policeStation),
                  _InfoRow('City', profile.address.city),
                  _InfoRow('State', profile.address.state),
                  _InfoRow('Pincode', profile.address.pincode),
                ],
              ),
              const SizedBox(height: 16),

              // Agent Info
              if (profile.agentEntity != null) ...[
                _SectionCard(
                  title: 'Agent Information',
                  icon: Icons.support_agent,
                  children: [
                    _InfoRow('Agent Name', profile.agentEntity!.agentName),
                    _InfoRow('Phone', profile.agentEntity!.agentMobile),
                    _InfoRow('Email', profile.agentEntity!.agentEmail),
                    _InfoRow(
                      'License',
                      profile.agentEntity!.agentLicenseNumber,
                    ),
                    _InfoRow('City', profile.agentEntity!.agentCity),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Photos & Documents
              _ImagesTabSection(images: profile.images),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Bottom bar – Match Profiles button
// ──────────────────────────────────────────────────────────────

class _MatchProfilesBottomBar extends ConsumerWidget {
  final String userId;

  const _MatchProfilesBottomBar({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(matrimonyProfileViewModelProvider(userId));
    final theme = Theme.of(context);

    return profileAsync.maybeWhen(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () =>
                context.router.push(ProfileMatchRoute(profile: profile)),
            icon: const Icon(Icons.favorite),
            label: const Text('Match Profiles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Matrimony header card
// ──────────────────────────────────────────────────────────────

class _MatrimonyHeaderCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;

  const _MatrimonyHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: profile.images.primaryImageUrl.isNotEmpty
                  ? NetworkImage(profile.images.primaryImageUrl)
                  : const NetworkImage(
                      'https://firebasestorage.googleapis.com/v0/b/fir-app-e3a53.firebasestorage.app/o/company_files%2Ficon-7797704_640.png?alt=media&token=90d1d7fc-9dd9-4ab9-8dfc-480646f5777f',
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.identity.gender} • ${profile.identity.age} years',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  if (profile.user.phone.isNotEmpty)
                    Text(
                      profile.user.phone,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  if (profile.user.email.isNotEmpty)
                    Text(
                      profile.user.email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared section card
// ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
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
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Info row (label + value)
// ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Status item chip (user profile tab)
// ──────────────────────────────────────────────────────────────

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Images / Documents tab section
// ──────────────────────────────────────────────────────────────

class _ImagesTabSection extends StatelessWidget {
  final ProfileImages images;

  const _ImagesTabSection({required this.images});

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, String>> allImages = [];

    if (images.primaryImageUrl.isNotEmpty) {
      allImages.add(MapEntry('Primary Photo', images.primaryImageUrl));
    }
    if (images.profileImageUrl.isNotEmpty) {
      allImages.add(MapEntry('Profile Photo', images.profileImageUrl));
    }
    if (images.imageWithAgentUrl.isNotEmpty) {
      allImages.add(MapEntry('Photo with Agent', images.imageWithAgentUrl));
    }
    for (int i = 0; i < images.secondaryImageUrls.length; i++) {
      allImages.add(MapEntry('Gallery ${i + 1}', images.secondaryImageUrls[i]));
    }

    final hasAadhar = images.aadharCardUrl.isNotEmpty;

    if (allImages.isEmpty && !hasAadhar) return const SizedBox.shrink();

    final tabCount = allImages.length + (hasAadhar ? 1 : 0);

    return DefaultTabController(
      length: tabCount,
      key: ValueKey('img_tabs_$tabCount'),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Photos & Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              TabBar(
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: [
                  ...allImages.map((e) => Tab(text: e.key)),
                  if (hasAadhar) const Tab(text: 'Aadhar Card'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    ...allImages.map(
                      (e) => _ImageViewer(imageUrl: e.value, label: e.key),
                    ),
                    if (hasAadhar)
                      _DocumentViewer(
                        documentUrl: images.aadharCardUrl,
                        label: 'Aadhar Card',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  final String label;

  const _ImageError({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 56,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              '$label not available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _ImageViewer({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _ImageError(label: label);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openFullscreen(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, _, _) => _ImageError(label: label),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to view fullscreen',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentViewer extends StatelessWidget {
  final String documentUrl;
  final String label;

  const _DocumentViewer({required this.documentUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    if (documentUrl.isEmpty) return _ImageError(label: label);

    final isPdf = documentUrl.toLowerCase().endsWith('.pdf');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf : Icons.image,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openDocument(context, isPdf),
            icon: const Icon(Icons.open_in_new),
            label: Text(isPdf ? 'Open PDF' : 'View Document'),
          ),
          const SizedBox(height: 12),
          Text(
            _shortName(documentUrl),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openDocument(BuildContext context, bool isPdf) {
    if (isPdf) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PdfViewerBottomsheet(
          source: documentUrl,
          title: label,
          isLocal: false,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Image.network(
            documentUrl,
            errorBuilder: (_, _, _) => _ImageError(label: label),
          ),
        ),
      );
    }
  }

  String _shortName(String url) {
    final name = url.split('/').last;
    return name.length > 30 ? '...${name.substring(name.length - 30)}' : name;
  }
}

// ──────────────────────────────────────────────────────────────
// Filter right sheet (used by match screen)
// ──────────────────────────────────────────────────────────────

class MatchingOptionsSheet extends ConsumerWidget {
  final String userId, gender, cast, religion, state, district;

  const MatchingOptionsSheet({
    super.key,
    this.userId = '',
    this.gender = '',
    this.cast = '',
    this.religion = '',
    this.state = '',
    this.district = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Matching Options',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class MatchingFilterRightSheet extends ConsumerWidget {
  const MatchingFilterRightSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(matchFilterProvider);
    final locationAsync = ref.watch(locationJsonProvider);
    final religionsAsync = ref.watch(religionsProvider);

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Profiles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            ref.read(matchFilterProvider.notifier).reset(),
                        child: const Text('Reset'),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      locationAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                        data: (states) {
                          final stateNames = states.map((e) => e.name).toList();
                          final selectedState = states.firstWhere(
                            (s) => s.name == filter.state,
                            orElse: () => StateCityModel(name: '', cities: []),
                          );
                          return Column(
                            children: [
                              _buildDropdown(
                                title: 'State',
                                value: filter.state.isEmpty
                                    ? null
                                    : filter.state,
                                items: stateNames,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(homeFilterProvider.notifier)
                                        .updateState(val);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                title: 'City',
                                value: filter.city.isEmpty ? null : filter.city,
                                items: selectedState.cities,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(homeFilterProvider.notifier)
                                        .updateCity(val);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Cultural',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      religionsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                        data: (religions) {
                          final religionNames = religions
                              .map((r) => r.name)
                              .toList();
                          final selectedReligion = religions.firstWhere(
                            (r) => r.name == filter.religion,
                            orElse: () =>
                                ReligionModel(id: '', name: '', castes: []),
                          );
                          return Column(
                            children: [
                              _buildDropdown(
                                title: 'Religion',
                                value: filter.religion.isEmpty
                                    ? null
                                    : filter.religion,
                                items: religionNames,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(homeFilterProvider.notifier)
                                        .updateReligion(val);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                title: 'Caste',
                                value: filter.caste.isEmpty
                                    ? null
                                    : filter.caste,
                                items: selectedReligion.castes,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(homeFilterProvider.notifier)
                                        .updateCaste(val);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _WishlistUserTile extends ConsumerWidget {
  final String profileId;
  final String parentUserId;
  final String status;
  final DateTime updatedAt;
  final String currentUserAgentId;
  final String Function(DateTime) formatDateTime;
  final VoidCallback onTap;

  const _WishlistUserTile({
    required this.profileId,
    required this.parentUserId,
    required this.currentUserAgentId,
    required this.status,
    required this.updatedAt,
    required this.formatDateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(wishlistUserProvider(profileId));

    return GestureDetector(
      onTap: onTap,
      child: userAsync.when(
        data: (user) {
          if (user == null) return _buildPlaceholder('User not found');

          final isSameAgent = currentUserAgentId == user.agentId;

          return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 236, 236),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: user.profileImageUrl.isNotEmpty
                          ? NetworkImage(user.profileImageUrl)
                          : null,
                      child: user.profileImageUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName.isNotEmpty
                                ? user.fullName
                                : 'No Name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.phone.isNotEmpty ? user.phone : 'No phone',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDateTime(updatedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                if (user.agentId.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (isSameAgent) {
                            _showSameAgentDialog(context);
                          } else {
                            showAgentDialog(context, ref, user.agentId);
                          }
                        },
                        icon: Icon(
                          isSameAgent
                              ? Icons.check_circle_outline
                              : Icons.person,
                        ),
                        label: Text(
                          isSameAgent ? 'Same Agent' : 'Contact Agent',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isSameAgent
                              ? Colors.green
                              : Colors.blue,
                          side: BorderSide(
                            color: isSameAgent ? Colors.green : Colors.blue,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showStatusDialog(context, ref),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Update Status'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        error: (_, _) => _buildPlaceholder('Error loading user'),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person_off, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Text(message, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'contacted':
        return Colors.blue;
      case 'interested':
        return Colors.green;
      case 'notinterested':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    final statuses = [
      'Pending',
      'Contacted',
      'Interested',
      'NotInterested',
      'Closed',
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses
              .map(
                (s) => ListTile(
                  title: Text(s),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(ref, s, context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    String newStatus,
    BuildContext context,
  ) async {
    try {
      await ref
          .read(agentUserNotifierProvider.notifier)
          .updateUserWishlistStatus(
            userId: parentUserId,
            profileId: profileId,
            status: newStatus,
          );
      ref.invalidate(agentUserNotifierProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  void _showSameAgentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Same Agent'),
        content: const Text(
          'This user is registered under the same agent. No need to contact another agent for the matrimony process.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showAgentDialog(BuildContext context, WidgetRef ref, String agentId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _AgentDialog(agentId: agentId),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Agent info dialog
// ──────────────────────────────────────────────────────────────

class _AgentDialog extends ConsumerWidget {
  final String agentId;

  const _AgentDialog({required this.agentId});

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(dynamic agent) {
    if (agent.isApproved) {
      return const Chip(
        label: Text('Approved'),
        backgroundColor: Colors.greenAccent,
      );
    }
    if (agent.isRejected) {
      return const Chip(
        label: Text('Rejected'),
        backgroundColor: Colors.redAccent,
      );
    }
    return const Chip(
      label: Text('Pending'),
      backgroundColor: Colors.orangeAccent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProvider(agentId));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      title: agentAsync.when(
        data: (agent) => Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              backgroundImage: agent.profileImageUrl.isNotEmpty
                  ? NetworkImage(agent.profileImageUrl)
                  : null,
              child: agent.profileImageUrl.isEmpty
                  ? const Icon(Icons.support_agent, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                agent.agentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        loading: () => const Text('Agent Details'),
        error: (_, _) => const Text('Agent Details'),
      ),
      content: agentAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => const SizedBox(
          height: 120,
          child: Center(child: Text('Failed to load agent info')),
        ),
        data: (agent) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.phone, 'Phone', agent.agentMobile),
              const Divider(),
              _buildInfoRow(Icons.email, 'Email', agent.agentEmail),
              const Divider(),
              _buildInfoRow(
                Icons.location_on,
                'Location',
                '${agent.agentCity}, ${agent.agentState}',
              ),
              const Divider(),
              _buildStatusChip(agent),
            ],
          ),
        ),
      ),
      actions: agentAsync.when(
        data: (agent) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (agent.agentMobile.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                final number = agent.agentMobile.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                final url =
                    'https://wa.me/$number?text=Hi, I am contacting you regarding a matrimony profile.';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.message, size: 18),
              label: const Text('WhatsApp'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse('tel:${agent.agentMobile}'),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
            ),
          ],
        ],
        loading: () => [],
        error: (_, _) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
