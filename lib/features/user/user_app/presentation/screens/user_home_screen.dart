import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/user_recemmonded_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';

import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/custom/custom_widgets/user_drawer.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../../../widgets/marquee.dart';

import '../../../../../core/filters/home_filter_controller.dart';

import '../../../../../app/router/app_router.dart';
import '../../domain/states/religion_state.dart';
import '../../domain/states/state_city.dart';
import '../controllers/home_controller.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// =======================
/// USER HOME SCREEN
/// =======================
@RoutePage()
class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // current user provider
    final currentUserAsync = ref.watch(currentUserProvider);

    final homeState = ref.watch(homeControllerProvider);
    final filter = ref.watch(homeFilterProvider);
    final recommendedIdsAsync = ref.watch(currentUserRecommendedIdsProvider);
    final recommendedProfileIds =
        recommendedIdsAsync.asData?.value ?? const <String>[];
    final recommendedProfileIdSet = recommendedProfileIds.toSet();

    String filterText = '';
    if (filter.city.isNotEmpty) {
      filterText = '${filter.city}, ${filter.state}';
    } else if (filter.state.isNotEmpty) {
      filterText = filter.state;
    }

    if (filter.religion.isNotEmpty) {
      if (filterText.isNotEmpty) filterText += ' | ';
      filterText += filter.religion;
      if (filter.caste.isNotEmpty) {
        filterText += ' (${filter.caste})';
      }
    }

    bool isRecommended(MatrimonyProfileViewModel viewModel) {
      final profile = viewModel.profile;
      final profileUser = viewModel.user;

      final candidateIds = <String>{
        profile.userId,
        profile.metrimonyId,
        profile.identity.profileId,
        profileUser?.uid ?? '',
        profileUser?.profileId ?? '',
        profileUser?.metrimonyId ?? '',
      }..removeWhere((id) => id.isEmpty);

      final matches = candidateIds.any(recommendedProfileIdSet.contains);
      debugPrint(
        'Recommended check for ${profileUser?.fullName ?? profile.userId}: '
        'candidates=$candidateIds, suggested=$recommendedProfileIds, match=$matches',
      );
      return matches;
    }

    return Scaffold(
      drawer: UserDrawer(userAsync: currentUserAsync),

      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text("User not found"));

          // Watch the payment status directly for this user.
          // The PaymentNotifier fetches the status from Firebase.
          final paymentState = ref.watch(paymentNotifierProvider(user.uid));

          if (paymentState.status == PayStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // If payment is successful, show the home content.
          // Otherwise, show the payment screen.

          // change after publishing on playstore
          if (paymentState.status == PayStatus.idle) {
            return CustomScrollView(
              slivers: [
                ModernGradientAppBar(
                  title: "Home",
                  subtitle: "Find your best match",
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          context.router.push(const UserNotificationRoute()),
                    ),
                  ],
                ),
                // other slivers...

                /// ================= LOCATION BAR =================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Marquee(
                                    pauseDuration: Duration(milliseconds: 500),
                                    velocity: 50,

                                    filterText.isEmpty
                                        ? 'All Profiles'
                                        : filterText,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Filter',
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const FilterRightSheet(),
                              transitionBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return SlideTransition(
                                      position: Tween(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _HomeSummaryCard(
                      fullName: user.fullName,
                      hasFilter: filterText.isNotEmpty,
                      filterText: filterText.isEmpty
                          ? 'All Profiles'
                          : filterText,
                    ),
                  ),
                ),

                /// ================= PROFILES LIST =================
                homeState.metrimonyProfiles.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) {
                    debugPrint('Error loading profiles: $e');

                    return SliverToBoxAdapter(
                      child: Center(child: Text(e.toString())),
                    );
                  },
                  data: (profiles) {
                    final filteredProfiles = profiles.where((viewModel) {
                      final profile = viewModel.profile;

                      // If no state is selected, or if state matches
                      final stateMatch =
                          filter.state.isEmpty ||
                          (profile.address.state == filter.state);
                      // If no city is selected, or if city matches
                      final cityMatch =
                          filter.city.isEmpty ||
                          (profile.address.city == filter.city);

                      // If no religion is selected, or if religion matches
                      final religionMatch =
                          filter.religion.isEmpty ||
                          (profile.cultural.religion == filter.religion);

                      // If no caste is selected, or if caste matches
                      final casteMatch =
                          filter.caste.isEmpty ||
                          (profile.cultural.caste == filter.caste);

                      return stateMatch &&
                          cityMatch &&
                          religionMatch &&
                          casteMatch;
                    }).toList();

                    final visibleProfiles = filteredProfiles.where((viewModel) {
                      return isRecommended(viewModel);
                    }).toList();

                    if (visibleProfiles.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 42,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No recommended profiles match your filters.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(homeFilterProvider.notifier)
                                        .reset();
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reset filters'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.only(bottom: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final viewModel = visibleProfiles[index];
                          final profile = viewModel.profile;
                          final user = viewModel.user;
                          final displayName = user?.fullName ?? 'N/A';
                          final designation = profile.employment.designation;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ProfileCard(
                              uid: profile.userId,
                              name: displayName.isEmpty ? 'N/A' : displayName,
                              age: profile.identity.age,
                              designation:
                                  (designation == null || designation.isEmpty)
                                  ? 'N/A'
                                  : designation,
                              imageUrl: profile.images.primaryImageUrl,
                            ),
                          );
                        }, childCount: visibleProfiles.length),
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            // If payment is not successful, show the payment screen.
            debugPrint("Navigating to payment screen");
            debugPrint(paymentState.status.name);
            debugPrint(user.uid);
            return UserPaymentScreen(userId: user.uid);
          }
        },
      ),
    );
  }
}

class _HomeSummaryCard extends StatelessWidget {
  final String fullName;
  final bool hasFilter;
  final String filterText;

  const _HomeSummaryCard({
    required this.fullName,
    required this.hasFilter,
    required this.filterText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${fullName.isEmpty ? 'User' : fullName.split(' ').first}',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? 'Showing filtered results'
                : 'Showing all available matches',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune_rounded, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    filterText,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

/// =======================
/// FILTER RIGHT SHEET
/// =======================
class FilterRightSheet extends ConsumerWidget {
  const FilterRightSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(homeFilterProvider);
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
              /// Header
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
                        onPressed: () {
                          ref.read(homeFilterProvider.notifier).reset();
                        },
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
                      // ================= LOCATION SECTION =================
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
                          /// All state names from JSON
                          final stateNames = states.map((e) => e.name).toList();

                          /// Selected state object
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

                      // ================= RELIGION SECTION =================
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

  /// ================= DROPDOWN BUILDER =================
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

/// =======================
/// PROFILE CARD (SIMPLE)
/// =======================
class ProfileCard extends StatelessWidget {
  final String uid;
  final String name;
  final int age;
  final String designation;
  final String imageUrl;

  const ProfileCard({
    super.key,
    required this.uid,
    required this.name,
    required this.age,
    required this.designation,

    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.router.push(UserDetailRoute(uid: uid)),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: imageUrl.isEmpty
                          ? Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 64),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 64),
                                  ),
                            ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.cake_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$age yrs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Icon(
                                Icons.work_outline_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  designation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        context.router.push(UserDetailRoute(uid: uid)),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('View Profile'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
