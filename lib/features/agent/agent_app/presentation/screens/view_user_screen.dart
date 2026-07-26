import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/features/agent/agent_app/domain/states/match_filter_state.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/metrimony_notifier.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/image_state.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/religion_state.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/state_city.dart';
import 'package:shadi_milan/features/user/user_app/widgets/pdf_viewer_bottomsheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_translation_service.dart';
import '../../../../l10n/l10n_helper.dart';
import '../notifier/user_nofier.dart';

@RoutePage()
class ViewUserScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool showMatchButton;

  const ViewUserScreen({super.key, required this.userId, this.showMatchButton = true});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends ConsumerState<ViewUserScreen> with SingleTickerProviderStateMixin {
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
          .getUserPayment(userId: userId, agentId: FirebaseAuth.instance.currentUser!.uid);

      if (registrationPayment == null || registrationPayment.status != 'SUCCESS') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.cannotCloseProfileNoRegistrationPayment)));
        }
        return;
      }

      final payments = await ref.read(userPaymentDsProvider).getAfterMarriagePaymentForUser(userId: userId);

      if (payments == null || payments.status != 'SUCCESS') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.cannotCloseProfileNoAfterMarriagePayment)));
        }
        return;
      }

      await ref.read(agentUserNotifierProvider.notifier).closeMatrimonyProfile(userId);

      ref.invalidate(agentUserNotifierProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.profileClosedSuccessfully)));
        context.router.maybePop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.failedToCloseProfile(e.toString()))));
      }
    }
  }

  void _showCloseProfileDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.closeMatrimonyProfile),
        content: Text(context.l10n.closeProfileConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _closeProfile(context, userId);
            },
            child: Text(context.l10n.closeProfileButton),
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
          data: (user) => BilingualParser(
            value: user?.fullName ?? BilingualValue.empty(),

            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),

          orElse: () => Text(context.l10n.userDetails, style: TextStyle(color: theme.colorScheme.onPrimary)),
        ),
        actions: [
          userAsync.maybeWhen(
            data: (user) {
              if (widget.showMatchButton && user != null && user.profileStatus == 'active') {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 235, 227, 227)),
                  onPressed: () => _showCloseProfileDialog(context, user.uid),
                  child: Text(context.l10n.closeProfileButton),
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
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: [
            Tab(icon: const Icon(Icons.person_outline), text: context.l10n.profileTab),
            Tab(icon: const Icon(Icons.favorite_border), text: context.l10n.matrimonyProfileTab),
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
              Text(context.l10n.errorLoadingUser, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(error.toString(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(agentUserNotifierProvider.notifier).fetchUserById(widget.userId),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(context.l10n.userNotFound),
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
      bottomNavigationBar: widget.showMatchButton ? _MatchProfilesBottomBar(userId: widget.userId) : null,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// TAB 1 – User Profile (data from `users` collection)
// ──────────────────────────────────────────────────────────────

class _UserProfileTab extends StatelessWidget {
  final dynamic user; // UserEntity

  const _UserProfileTab({required this.user});

  String _formatDate(DateTime dt, BuildContext context) {
    if (dt.millisecondsSinceEpoch == 0) return context.l10n.notAvailable;
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
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
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
                          ? DecorationImage(image: NetworkImage(user.profileImageUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: user.profileImageUrl.isEmpty
                        ? Center(
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName.en.isNotEmpty
                                        ? user.fullName.en[0].toUpperCase()
                                        : user.fullName.hi.isNotEmpty
                                        ? user.fullName.hi[0].toUpperCase()
                                        : '?'
                                  : '?',
                              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: theme.primaryColor),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                BilingualParser(
                  value: user.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatusItem(
                      icon: user.isProfileCreated ? Icons.check_circle : Icons.error,
                      label: context.l10n.bioData,
                      value: user.isProfileCreated ? context.l10n.created : context.l10n.pending,
                      color: user.isProfileCreated ? Colors.green : Colors.orange,
                    ),
                    _StatusItem(
                      icon: Icons.verified_user,
                      label: context.l10n.profileStatus,
                      value: user.profileStatus,
                      color: user.profileStatus == 'active' ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contact
          _SectionCard(
            title: context.l10n.contactInformation,
            icon: Icons.contact_mail,
            children: [
              _InfoRow(context.l10n.phone, user.phone.isNotEmpty ? user.phone : context.l10n.notProvided),
              const Divider(height: 16),
              _InfoRow(context.l10n.email, user.email),
            ],
          ),

          // Account
          _SectionCard(
            title: context.l10n.accountInformation,
            icon: Icons.account_box,
            children: [
              _InfoRow(context.l10n.role, user.role.isNotEmpty ? user.role : context.l10n.userRole),
              const Divider(height: 16),
              _InfoRow(context.l10n.gender, user.gender.isNotEmpty ? user.gender : context.l10n.notSpecified),
            ],
          ),

          // Activity
          _SectionCard(
            title: context.l10n.activity,
            icon: Icons.history,
            children: [
              _InfoRow(context.l10n.createdAt, _formatDate(user.createdAt, context)),
              const Divider(height: 16),
              _InfoRow(context.l10n.lastSeen, _formatDate(user.lastSeen, context)),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.favorite_border, size: 56, color: Colors.grey),
        title: Text(context.l10n.matrimonyProfileNotFound, textAlign: TextAlign.center),
        content: Text(context.l10n.matrimonyProfileNotFoundContent, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.ok))],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationJsonProvider);
    final religionsAsync = ref.watch(religionsProvider);

    ref.listen(matrimonyProfileViewModelProvider(userId), (prev, next) {
      // Show dialog on first transition to null data (profile doesn't exist yet)
      if (next.hasValue && next.value == null && (prev == null || prev.isLoading)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _showNoProfileDialog(context);
        });
      }
    });

    final profileAsync = ref.watch(matrimonyProfileViewModelProvider(userId));

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(context.l10n.matrimonyProfileNotAvailable),
          ],
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(context.l10n.matrimonyProfileNotCreatedYet),
              ],
            ),
          );
        }

        final locale = ref.watch(localeProvider);
        final langCode = locale.languageCode;

        String resolvedState = profile.address.state.en;
        String resolvedCity = profile.address.city.en;
        String resolvedReligion = profile.cultural.religion.en;
        String resolvedCaste = profile.cultural.caste.en;

        if (locationAsync.hasValue) {
          final states = locationAsync.value!;
          final stateObj = states.where((s) => s.name == profile.address.state.en || s.name == profile.address.state.hi).firstOrNull;
          if (stateObj != null) {
            resolvedState = stateObj.name;
            final cityObj = stateObj.cities
                .where(
                  (c) =>
                      c.id == profile.address.city.en ||
                      c.id == profile.address.city.hi ||
                      c.name == profile.address.city.en ||
                      c.name == profile.address.city.hi,
                )
                .firstOrNull;
            if (cityObj != null) {
              resolvedCity = cityObj.name;
            }
          }
        }

        if (religionsAsync.hasValue) {
          final religions = religionsAsync.value!;
          final religionObj = religions
              .where(
                (r) =>
                    r.id == profile.cultural.religion.en ||
                    r.id == profile.cultural.religion.hi ||
                    r.name == profile.cultural.religion.en ||
                    r.name == profile.cultural.religion.hi,
              )
              .firstOrNull;
          if (religionObj != null) {
            resolvedReligion = religionObj.name;
            final casteObj = religionObj.castes
                .where(
                  (c) =>
                      c.id == profile.cultural.caste.en ||
                      c.id == profile.cultural.caste.hi ||
                      c.name == profile.cultural.caste.en ||
                      c.name == profile.cultural.caste.hi,
                )
                .firstOrNull;
            if (casteObj != null) {
              resolvedCaste = casteObj.name;
            }
          }
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
                title: context.l10n.identityInformation,
                icon: Icons.person,
                children: [
                  _InfoRow(context.l10n.fullName, profile.user.fullName),
                  _InfoRow(context.l10n.dateOfBirth, profile.identity.dob.toLocal().toString().split(' ')[0]),
                  _InfoRow(context.l10n.male, '${profile.identity.age} ${context.l10n.ageYrs}'),
                  _InfoRow(context.l10n.gender, profile.identity.gender),
                  _InfoRow(context.l10n.aadharCard, profile.identity.aadhar),
                  if (profile.identity.aboutMe.hi.isNotEmpty || profile.identity.aboutMe.en.isNotEmpty)
                    _InfoRow(context.l10n.aboutMe, profile.identity.aboutMe),
                ],
              ),
              const SizedBox(height: 16),

              // Physical
              _SectionCard(
                title: context.l10n.physicalInformation,
                icon: Icons.accessibility,
                children: [
                  _InfoRow(context.l10n.height, '${profile.physical.height} cm'),
                  _InfoRow(context.l10n.weightKg, '${profile.physical.weight} kg'),
                  _InfoRow(context.l10n.bodyType, profile.physical.bodyType),
                  _InfoRow(context.l10n.complexion, profile.physical.complexion),
                  _InfoRow(
                    context.l10n.physicallyChallenged,
                    profile.physical.physicallyChallenged ? context.l10n.yesLabel : context.l10n.noLabel,
                  ),
                  if (profile.physical.disabilityDetails != null)
                    _InfoRow(context.l10n.disabilityDetails, profile.physical.disabilityDetails!),
                ],
              ),
              const SizedBox(height: 16),

              // Cultural
              _SectionCard(
                title: context.l10n.culturalInformation,
                icon: Icons.temple_hindu,
                children: [
                  _InfoRow(context.l10n.religion, resolvedReligion),
                  _InfoRow(context.l10n.caste, resolvedCaste),
                  _InfoRow(context.l10n.subCaste, profile.cultural.subCaste),
                  _InfoRow(context.l10n.languages, profile.cultural.languages.map((l) => langCode == 'hi' ? l.hi : l.en).join(', ')),
                ],
              ),
              const SizedBox(height: 16),

              // Education
              _SectionCard(
                title: context.l10n.education,
                icon: Icons.school,
                children: [
                  _InfoRow(context.l10n.isIlliterate, profile.education.isIlletrate ? context.l10n.yesLabel : context.l10n.noLabel),
                  if (!profile.education.isIlletrate && profile.education.education != null) ...[
                    _InfoRow(context.l10n.course, profile.education.education!.course),
                    _InfoRow(context.l10n.collegeUniversity, profile.education.education!.college),
                    _InfoRow(context.l10n.passingYear, '${profile.education.education!.passingYear}'),
                    _InfoRow(context.l10n.percentage, '${profile.education.education!.percentage}%'),
                  ],
                  if (profile.education.extraQualification?.qualifications.isNotEmpty == true)
                    _InfoRow(
                      context.l10n.extraQualifications,
                      profile.education.extraQualification!.qualifications.map((q) => langCode == 'hi' ? q.hi : q.en).join(', '),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Employment
              _SectionCard(
                title: context.l10n.employmentDetails,
                icon: Icons.work,
                children: [
                  _InfoRow(context.l10n.jobType, profile.employment.jobType),
                  if (profile.employment.company != null) _InfoRow(context.l10n.organization, profile.employment.company!),
                  if (profile.employment.designation != null) _InfoRow(context.l10n.designation, profile.employment.designation!),
                  if (profile.employment.annualIncome != null) _InfoRow(context.l10n.annualIncome, '₹${profile.employment.annualIncome}'),
                  if (profile.employment.workLocation != null) _InfoRow(context.l10n.workLocation, profile.employment.workLocation!),
                ],
              ),
              const SizedBox(height: 16),

              // Family
              _SectionCard(
                title: context.l10n.familyInformation,
                icon: Icons.family_restroom,
                children: [
                  _InfoRow(context.l10n.fatherName, profile.family.fatherName ?? ''),
                  _InfoRow(context.l10n.motherName, profile.family.motherName ?? ''),
                  _InfoRow(context.l10n.brothers, '${profile.family.numberOfBrothers}'),
                  _InfoRow(context.l10n.sisters, '${profile.family.numberOfSisters}'),
                  _InfoRow(context.l10n.familyType, profile.family.familyType),
                  _InfoRow(context.l10n.familyStatus, profile.family.familyStatus),
                ],
              ),
              const SizedBox(height: 16),

              // Address
              _SectionCard(
                title: context.l10n.address,
                icon: Icons.location_on,
                children: [
                  _InfoRow(context.l10n.address, profile.address.addressLine1),
                  _InfoRow(context.l10n.post, profile.address.post),
                  _InfoRow(context.l10n.policeStation, profile.address.policeStation),
                  _InfoRow(context.l10n.city, resolvedCity),
                  _InfoRow(context.l10n.state, resolvedState),
                  _InfoRow(context.l10n.pincode, profile.address.pincode),
                ],
              ),
              const SizedBox(height: 16),

              // Agent Info
              if (profile.agentEntity != null) ...[
                _SectionCard(
                  title: context.l10n.agentInformation,
                  icon: Icons.support_agent,
                  children: [
                    _InfoRow(context.l10n.agentName, profile.agentEntity!.agentName),
                    _InfoRow(context.l10n.phone, profile.agentEntity!.agentMobile),
                    _InfoRow(context.l10n.email, profile.agentEntity!.agentEmail),
                    _InfoRow(context.l10n.license, profile.agentEntity!.agentLicenseNumber),
                    _InfoRow(context.l10n.city, profile.agentEntity!.agentCity),
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: ElevatedButton.icon(
            onPressed: () => context.router.push(ProfileMatchRoute(profile: profile)),
            icon: const Icon(Icons.favorite),
            label: Text(context.l10n.matchProfiles),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  BilingualParser(
                    value: profile.user.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    '${profile.identity.gender} • ${profile.identity.age} years',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  if (profile.user.phone.isNotEmpty) Text(profile.user.phone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  if (profile.user.email.isNotEmpty) Text(profile.user.email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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

  const _SectionCard({required this.title, required this.icon, required this.children});

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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.primaryColor),
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
  final dynamic value;

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
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: value is BilingualValue
                ? BilingualParser(value: value as BilingualValue)
                : Text(
                    (value == null || value.toString().isEmpty) ? context.l10n.notProvided : value.toString(),
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

  const _StatusItem({required this.icon, required this.label, required this.value, required this.color});

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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
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
      allImages.add(MapEntry(context.l10n.primaryPhoto, images.primaryImageUrl));
    }
    if (images.profileImageUrl.isNotEmpty) {
      allImages.add(MapEntry(context.l10n.profilePhoto, images.profileImageUrl));
    }
    if (images.imageWithAgentUrl.isNotEmpty) {
      allImages.add(MapEntry(context.l10n.photoWithAgent, images.imageWithAgentUrl));
    }
    for (int i = 0; i < images.secondaryImageUrls.length; i++) {
      allImages.add(MapEntry('${context.l10n.gallery} ${i + 1}', images.secondaryImageUrls[i]));
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
                    Icon(Icons.photo_library, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(context.l10n.photosAndDocuments, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  if (hasAadhar) Tab(text: context.l10n.aadharCard),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    ...allImages.map((e) => _ImageViewer(imageUrl: e.value, label: e.key)),
                    if (hasAadhar) _DocumentViewer(documentUrl: images.aadharCardUrl, label: context.l10n.aadharCard),
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
            Icon(Icons.broken_image_outlined, size: 56, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text('$label not available', style: TextStyle(color: Colors.grey[600])),
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
          Text(context.l10n.tapToViewFullscreen, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
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
          Icon(isPdf ? Icons.picture_as_pdf : Icons.image, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openDocument(context, isPdf),
            icon: const Icon(Icons.open_in_new),
            label: Text(isPdf ? context.l10n.openPdf : context.l10n.viewDocument),
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
        builder: (context) => PdfViewerBottomsheet(source: documentUrl, title: label, isLocal: false),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Image.network(documentUrl, errorBuilder: (_, _, _) => _ImageError(label: label)),
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
          Text(context.l10n.matchingOptions, style: Theme.of(context).textTheme.titleLarge),
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
                  Text(context.l10n.filterProfiles, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      TextButton(onPressed: () => ref.read(matchFilterProvider.notifier).reset(), child: Text(context.l10n.reset)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
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
                      Text(
                        context.l10n.location,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      locationAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                        data: (states) {
                          /// Selected state object
                          final selectedState = states.where((s) => s.name == filter.state).firstOrNull;

                          final selectedCity = selectedState?.cities.where((c) => c.id == filter.city || c.name == filter.city).firstOrNull;

                          return Column(
                            children: [
                              _buildDropdown<StateCityModel>(
                                title: context.l10n.state,
                                value: selectedState,
                                items: states,
                                itemLabel: (s) => s.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(matchFilterProvider.notifier).updateState(val.name);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown<CityModel>(
                                title: context.l10n.city,
                                value: selectedCity,
                                items: selectedState?.cities ?? [],
                                itemLabel: (c) => c.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(matchFilterProvider.notifier).updateCity(val.id);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.cultural,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      religionsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                        data: (religions) {
                          final selectedReligion = religions.where((r) => r.id == filter.religion || r.name == filter.religion).firstOrNull;

                          final selectedCaste = selectedReligion?.castes
                              .where((c) => c.id == filter.caste || c.name == filter.caste)
                              .firstOrNull;

                          return Column(
                            children: [
                              _buildDropdown<ReligionCasteModel>(
                                title: context.l10n.religion,
                                value: selectedReligion,
                                items: religions,
                                itemLabel: (r) => r.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(matchFilterProvider.notifier).updateReligion(val.id);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown<CasteModel>(
                                title: context.l10n.caste,
                                value: selectedCaste,
                                items: selectedReligion?.castes ?? [],
                                itemLabel: (c) => c.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(matchFilterProvider.notifier).updateCaste(val.id);
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
                child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.applyFilters)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDropdown<T>({
    required String title,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
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
          if (user == null) return _buildPlaceholder(context.l10n.userNotFound);

          final isSameAgent = currentUserAgentId == user.agentId;

          return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 236, 236),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
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
                      backgroundImage: user.profileImageUrl.isNotEmpty ? NetworkImage(user.profileImageUrl) : null,
                      child: user.profileImageUrl.isEmpty ? Icon(Icons.person, color: Colors.grey[600]) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BilingualParser(
                            value: user.fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                user.phone.isNotEmpty ? user.phone : context.l10n.noPhone,
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _getStatusColor(status)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(formatDateTime(updatedAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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
                        icon: Icon(isSameAgent ? Icons.check_circle_outline : Icons.person),
                        label: Text(isSameAgent ? context.l10n.sameAgent : context.l10n.contactAgent),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isSameAgent ? Colors.green : Colors.blue,
                          side: BorderSide(color: isSameAgent ? Colors.green : Colors.blue),
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
                      label: Text(context.l10n.updateStatus),
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
              child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
        error: (_, _) => _buildPlaceholder(context.l10n.errorLoadingUser),
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
    final Map<String, String> statusOptions = {
      'Pending': context.l10n.pending,
      'Contacted': context.l10n.statusContacted,
      'Interested': context.l10n.statusInterested,
      'NotInterested': context.l10n.statusNotInterested,
      'Closed': context.l10n.closed,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.updateStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.entries
              .map(
                (entry) => ListTile(
                  title: Text(entry.value),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(ref, entry.key, context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(WidgetRef ref, String newStatus, BuildContext context) async {
    try {
      await ref
          .read(agentUserNotifierProvider.notifier)
          .updateUserWishlistStatus(userId: parentUserId, profileId: profileId, status: newStatus);
      ref.invalidate(agentUserNotifierProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.statusUpdatedTo(newStatus))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.failedToUpdateStatus(e.toString()))));
      }
    }
  }

  void _showSameAgentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(context.l10n.sameAgent),
        content: Text(context.l10n.sameAgentMessage),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.ok))],
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
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(dynamic agent, BuildContext context) {
    if (agent.isApproved) {
      return Chip(label: Text(context.l10n.approved), backgroundColor: Colors.greenAccent);
    }
    if (agent.isRejected) {
      return Chip(label: Text(context.l10n.rejected), backgroundColor: Colors.redAccent);
    }
    return Chip(label: Text(context.l10n.pending), backgroundColor: Colors.orangeAccent);
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
              backgroundImage: agent.profileImageUrl.isNotEmpty ? NetworkImage(agent.profileImageUrl) : null,
              child: agent.profileImageUrl.isEmpty ? const Icon(Icons.support_agent, color: Colors.blue) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(agent.agentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        loading: () => Text(context.l10n.agentDetails),
        error: (_, _) => Text(context.l10n.agentDetails),
      ),
      content: agentAsync.when(
        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        error: (_, _) => SizedBox(height: 120, child: Center(child: Text(context.l10n.failedToLoadAgentInfo))),
        data: (agent) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.phone, context.l10n.phone, agent.agentMobile),
              const Divider(),
              _buildInfoRow(Icons.email, context.l10n.email, agent.agentEmail),
              const Divider(),
              _buildInfoRow(Icons.location_on, context.l10n.location, '${agent.agentCity}, ${agent.agentState}'),
              const Divider(),
              _buildStatusChip(agent, context),
            ],
          ),
        ),
      ),
      actions: agentAsync.when(
        data: (agent) => [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.closeLabel)),
          if (agent.agentMobile.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                final number = agent.agentMobile.replaceAll(RegExp(r'[^0-9]'), '');
                final url = 'https://wa.me/$number?text=${Uri.encodeComponent(context.l10n.whatsappContactMessage)}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.message, size: 18),
              label: Text(context.l10n.whatsapp),
            ),
            ElevatedButton.icon(
              onPressed: () {
                launchUrl(Uri.parse('tel:${agent.agentMobile}'), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.phone, size: 18),
              label: Text(context.l10n.call),
            ),
          ],
        ],
        loading: () => [],
        error: (_, _) => [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.closeLabel))],
      ),
    );
  }
}
