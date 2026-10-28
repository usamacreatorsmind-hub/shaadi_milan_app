import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadi_milan/core/app_version_config/remote_config_service.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import '../../../../agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../../../../core/filters/home_filter_controller.dart';
import '../../../../../app/router/app_router.dart';
import '../../domain/states/religion_state.dart';
import '../../domain/states/state_city.dart';
import '../controllers/home_controller.dart';
import 'package:shadi_milan/core/utils/image_url_optimizer.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/premium_upgrade_bottom_sheet.dart';

/// =======================
/// BLOCKED USERS PROVIDER
/// =======================
final blockedUsersProvider = StateProvider<Set<String>>((ref) => {});

List<String> getAllImagesForViewModel(MatrimonyProfileViewModel vm) {
  final profile = vm.profile;
  final user = vm.user;

  final raw = <String>[
    profile.images.primaryImageUrl,
    profile.images.profileImageUrl,
    if (user?.profileImageUrl != null && user!.profileImageUrl.isNotEmpty) user.profileImageUrl,
    ...profile.images.secondaryImageUrls,
    profile.images.imageWithAgentUrl,
  ];

  final unique = <String>{};
  final cleaned = <String>[];
  for (final url in raw) {
    if (url.trim().isEmpty) continue;
    final optimized = optimizeImageUrl(url, width: 800, quality: 75);
    if (unique.add(optimized)) cleaned.add(optimized);
  }

  return cleaned;
}

String getDisplayImageForViewModel(MatrimonyProfileViewModel vm) {
  final images = getAllImagesForViewModel(vm);
  return images.isNotEmpty ? images.first : '';
}

/// =======================
/// USER HOME SCREEN
/// =======================

@RoutePage()
class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // If you want fresh data every time the screen is entered,
    // invalidate is fine. However, watch() will trigger the fetch
    // automatically if not already loaded. If you need a manual refresh,
    // consider adding a RefreshIndicator to the UI instead of
    // invalidating on every initState.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // No need to invalidate here as watch() handles initial fetch and stream updates.
      // Caching provided by Riverpod will make the app feel much faster on subsequent opens.

      try {
        // ignore: use_build_context_synchronously
        await RemoteConfigService.instance.checkForUpdate(context);
        // ignore: use_build_context_synchronously
        await RemoteConfigService.instance.checkForMaintenanceMode(context);
      } catch (e) {
        debugPrint('RemoteConfig check failed on UserHomeScreen: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // current user provider
    final currentUserAsync = ref.watch(currentUserProvider);

    final homeState = ref.watch(homeControllerProvider);
    final filter = ref.watch(homeFilterProvider);

    // 🚀 RESET SCROLL when filter changes
    ref.listen(homeFilterProvider, (previous, next) {
      if (previous != next && _pageController.hasClients) {
        _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });

    final locationAsync = ref.watch(locationJsonProvider);
    final religionsAsync = ref.watch(religionsProvider);

    String filterText = '';

    // We need to resolve names from IDs for better UI display
    final resolvedState = filter.state;
    String resolvedCity = filter.city;
    String resolvedReligion = filter.religion;
    String resolvedCaste = filter.caste;

    if (locationAsync.hasValue) {
      final states = locationAsync.value!;
      final stateObj = states.where((s) => s.name == filter.state).firstOrNull;
      if (stateObj != null) {
        final cityObj = stateObj.cities.where((c) => c.id == filter.city || c.name == filter.city).firstOrNull;
        if (cityObj != null) {
          resolvedCity = cityObj.name;
        }
      }
    }

    if (religionsAsync.hasValue) {
      final religions = religionsAsync.value!;
      final religionObj = religions.where((r) => r.id == filter.religion || r.name == filter.religion).firstOrNull;
      if (religionObj != null) {
        resolvedReligion = religionObj.name;
        final casteObj = religionObj.castes.where((c) => c.id == filter.caste || c.name == filter.caste).firstOrNull;
        if (casteObj != null) {
          resolvedCaste = casteObj.name;
        }
      }
    }

    if (resolvedCity.isNotEmpty) {
      filterText = '$resolvedCity, $resolvedState';
    } else if (resolvedState.isNotEmpty) {
      filterText = resolvedState;
    }

    if (resolvedReligion.isNotEmpty) {
      if (filterText.isNotEmpty) filterText += ' | ';
      filterText += resolvedReligion;
      if (resolvedCaste.isNotEmpty) {
        filterText += ' ($resolvedCaste)';
      }
    }

    bool isRecommended(MatrimonyProfileViewModel viewModel) {
      return true;
    }

    return Scaffold(
      body: currentUserAsync.when(
        loading: () => const _HomeShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return Center(child: Text(AppLabels.userNotFound(context)));

          final paymentState = ref.watch(paymentNotifierProvider(user.uid));

          if (paymentState.status == PayStatus.loading) {
            return const _HomeShimmer();
          }

          return homeState.metrimonyProfiles.when(
            loading: () => const _HomeShimmer(),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (profiles) {
              final currentUserProfile = profiles.where((p) => p.profile.userId == user.uid).firstOrNull?.profile;
              final myCity = currentUserProfile?.address.city.en.toLowerCase().trim() ?? '';

              var filteredProfiles = profiles.where((viewModel) {
                final profile = viewModel.profile;
                final userEntity = viewModel.user;
                if (profile.userId == user.uid) return false;

                // 👫 AUTOMATIC GENDER FILTER (Show only opposite gender)
                final myGender = user.gender.en.toLowerCase().trim();
                final theirGender = profile.identity.gender.en.toLowerCase().trim();

                bool genderMatch = true;
                if (myGender == 'male') {
                  genderMatch = theirGender == 'female';
                } else if (myGender == 'female') {
                  genderMatch = theirGender == 'male';
                }

                // 🔍 ROBUST SEARCH LOGIC
                bool searchMatch = true;
                if (filter.searchQuery.isNotEmpty) {
                  final queryParts = filter.searchQuery.toLowerCase().trim().split(RegExp(r'\s+'));
                  final nameEn = userEntity?.fullName.en.toLowerCase() ?? '';
                  final nameHi = userEntity?.fullName.hi.toLowerCase() ?? '';
                  final mId = profile.metrimonyId.toLowerCase();
                  final casteEn = profile.cultural.caste.en.toLowerCase();
                  final casteHi = profile.cultural.caste.hi.toLowerCase();
                  final religionEn = profile.cultural.religion.en.toLowerCase();
                  final religionHi = profile.cultural.religion.hi.toLowerCase();
                  final cityEn = profile.address.city.en.toLowerCase();
                  final cityHi = profile.address.city.hi.toLowerCase();

                  // All parts of the query must match at least one field
                  searchMatch = queryParts.every(
                    (part) =>
                        nameEn.contains(part) ||
                        nameHi.contains(part) ||
                        mId.contains(part) ||
                        casteEn.contains(part) ||
                        casteHi.contains(part) ||
                        religionEn.contains(part) ||
                        religionHi.contains(part) ||
                        cityEn.contains(part) ||
                        cityHi.contains(part),
                  );
                }

                final stateMatch =
                    filter.state.isEmpty || (profile.address.state.en.toLowerCase().trim() == filter.state.toLowerCase().trim());
                final cityMatch = filter.city.isEmpty || (profile.address.city.en.toLowerCase().trim() == filter.city.toLowerCase().trim());
                final religionMatch =
                    filter.religion.isEmpty || (profile.cultural.religion.en.toLowerCase().trim() == filter.religion.toLowerCase().trim());
                final casteMatch =
                    filter.caste.isEmpty || (profile.cultural.caste.en.toLowerCase().trim() == filter.caste.toLowerCase().trim());

                bool cityFilterMatch = true;
                if (filter.fromMyCity && myCity.isNotEmpty) {
                  cityFilterMatch = profile.address.city.en.toLowerCase().trim() == myCity;
                }

                // 🎂 AGE MATCH
                final ageMatch = profile.identity.age >= filter.minAge && profile.identity.age <= filter.maxAge;

                // 📅 DAILY MATCH (Updated in last 2 days)
                bool dailyMatch = true;
                if (filter.daily) {
                  final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
                  final updatedAt = userEntity?.lastSeen ?? DateTime(1900);
                  dailyMatch = updatedAt.isAfter(twoDaysAgo);
                }

                // 🤝 MY MATCHES (Same Religion + Opposite Gender)
                bool myMatchesMatch = true;
                if (filter.myMatches) {
                  final userRelEn = user.fullName.en; // Using name as proxy if religion not in user entity
                  // Assuming user's religion should match profile's religion
                  // Better to check against currentUserProfile religion if available
                  final myRel = currentUserProfile?.cultural.religion.en.toLowerCase().trim() ?? '';
                  final profileRel = profile.cultural.religion.en.toLowerCase().trim();

                  final myGender = user.gender.en.toLowerCase().trim();
                  final profileGender = profile.identity.gender.en.toLowerCase().trim();

                  final religionOk = myRel.isEmpty || profileRel == myRel;
                  final genderOk = myGender.isEmpty || profileGender != myGender;

                  myMatchesMatch = religionOk && genderOk;
                }

                return searchMatch &&
                    stateMatch &&
                    cityMatch &&
                    religionMatch &&
                    casteMatch &&
                    genderMatch &&
                    cityFilterMatch &&
                    ageMatch &&
                    dailyMatch &&
                    myMatchesMatch;
              }).toList();

              if (filter.justJoined) {
                // Filter for last 7 days if Just Joined is active
                final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
                filteredProfiles = filteredProfiles.where((vm) {
                  final createdAt = vm.user?.createdAt ?? DateTime(1900);
                  return createdAt.isAfter(sevenDaysAgo);
                }).toList();

                filteredProfiles.sort((a, b) {
                  final dateA = a.user?.createdAt ?? DateTime(1900);
                  final dateB = b.user?.createdAt ?? DateTime(1900);
                  return dateB.compareTo(dateA);
                });
              } else if (filter.daily) {
                // Sort by last seen for Daily
                filteredProfiles.sort((a, b) {
                  final dateA = a.user?.lastSeen ?? DateTime(1900);
                  final dateB = b.user?.lastSeen ?? DateTime(1900);
                  return dateB.compareTo(dateA);
                });
              } else if (filter.myMatches) {
                // Sort by last seen for My Matches
                filteredProfiles.sort((a, b) {
                  final dateA = a.user?.lastSeen ?? DateTime(1900);
                  final dateB = b.user?.lastSeen ?? DateTime(1900);
                  return dateB.compareTo(dateA);
                });
              }

              final visibleProfiles = filteredProfiles.where((viewModel) => isRecommended(viewModel)).toList();

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FilterHeaderDelegate(
                      child: GestureDetector(
                        // Absorb vertical drag to prevent page scrolling when interacting with horizontal chips
                        onVerticalDragStart: (_) {},
                        onVerticalDragUpdate: (_) {},
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              _FilterChip(
                                label: "Search & Filter",
                                icon: Icons.search,
                                onTap: () => _showFilterDialog(context),
                                isSelected: ref.read(homeFilterProvider.notifier).isFilterActive,
                              ),
                              const SizedBox(width: 6),
                              if (ref.read(homeFilterProvider.notifier).isFilterActive)
                                _FilterChip(
                                  label: "Clear All",
                                  icon: Icons.clear_all_rounded,
                                  onTap: () {
                                    ref.read(homeFilterProvider.notifier).reset();
                                    HapticFeedback.mediumImpact();
                                  },
                                  isSelected: false,
                                  activeColor: Colors.redAccent,
                                ),
                              if (ref.read(homeFilterProvider.notifier).isFilterActive) const SizedBox(width: 6),
                              _FilterChip(
                                label: "New Profiles",
                                isSelected: filter.justJoined,
                                onTap: () {
                                  ref.read(homeFilterProvider.notifier).toggleJustJoined();
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icons.fiber_new_rounded,
                              ),
                              const SizedBox(width: 6),
                              _FilterChip(
                                label: "Near Me",
                                isSelected: filter.fromMyCity,
                                onTap: () {
                                  ref.read(homeFilterProvider.notifier).toggleFromMyCity();
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icons.location_on_rounded,
                              ),
                              const SizedBox(width: 6),
                              _FilterChip(
                                label: "Daily",
                                isSelected: filter.daily,
                                onTap: () {
                                  ref.read(homeFilterProvider.notifier).toggleDaily();
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icons.event_note_rounded,
                              ),
                              const SizedBox(width: 6),
                              _FilterChip(
                                label: "My matches",
                                isSelected: filter.myMatches,
                                onTap: () {
                                  ref.read(homeFilterProvider.notifier).toggleMyMatches();
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icons.people_alt_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!user.isProfileCreated)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLabels.completeProfileTitle(context),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLabels.completeProfileMessage(context),
                                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onErrorContainer),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: () => context.router.push(const MatrimonyFormFlowRoute()),
                                      icon: const Icon(Icons.edit_note_rounded),
                                      label: Text(AppLabels.completeProfileButton(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                body: visibleProfiles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 42, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 10),
                                Text(AppLabels.noProfilesFound(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: () {
                                    ref.read(homeFilterProvider.notifier).reset();
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(AppLabels.resetFilters(context)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: visibleProfiles.length + (visibleProfiles.length ~/ 6),
                        itemBuilder: (context, index) {
                          // Every 5th item is a suggestions section
                          if (index > 0 && (index + 1) % 5 == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _SuggestionsSection(allProfiles: filteredProfiles, currentUser: user),
                            );
                          }

                          // Calculate actual profile index
                          final profileIndex = index - (index ~/ 5);
                          if (profileIndex >= visibleProfiles.length) return const SizedBox.shrink();

                          final viewModel = visibleProfiles[profileIndex];
                          final profile = viewModel.profile;
                          final userEntity = viewModel.user;
                          final agent = viewModel.agent;
                          final isHindi = Localizations.localeOf(context).languageCode == 'hi';
                          final displayName = userEntity != null ? (isHindi ? userEntity.fullName.hi : userEntity.fullName.en) : 'N/A';

                          final designation = profile.employment.designation;
                          final caste = isHindi ? profile.cultural.caste.hi : profile.cultural.caste.en;
                          final location = isHindi
                              ? "${profile.address.city.hi}, ${profile.address.state.hi}"
                              : "${profile.address.city.en}, ${profile.address.state.en}";

                          final allImages = getAllImagesForViewModel(viewModel);

                          // 🚀 PRE-CACHE next profile for smoother scrolling
                          if (profileIndex + 1 < visibleProfiles.length) {
                            final nextVm = visibleProfiles[profileIndex + 1];
                            final nextImage = getDisplayImageForViewModel(nextVm);
                            if (nextImage.isNotEmpty) {
                              precacheImage(CachedNetworkImageProvider(nextImage, maxWidth: 800, maxHeight: 1000), context);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final paymentState = ref.watch(paymentNotifierProvider(profile.userId));
                                final isPremium = paymentState.status == PayStatus.success;
                                final isBlocked = ref.watch(blockedUsersProvider).contains(profile.userId);

                                return ProfileCard(
                                  uid: profile.userId,
                                  name: displayName.isEmpty ? 'N/A' : displayName,
                                  age: profile.identity.age,
                                  dob: profile.identity.dob,
                                  designation: designation,
                                  income: profile.employment.annualIncome,
                                  degree: profile.education.education?.course,
                                  religion: isHindi ? profile.cultural.religion.hi : profile.cultural.religion.en,
                                  images: allImages,
                                  agentDesignation: agent?.designation.label,
                                  location: location,
                                  height: "${profile.physical.height.round()} cm",
                                  caste: caste,
                                  isPremium: isPremium,
                                  isBlocked: isBlocked,
                                  lastSeen: userEntity?.lastSeen,
                                );
                              },
                            ),
                          );
                        },
                      ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const FilterRightSheet(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? activeColor;

  const _FilterChip({required this.label, this.icon, this.onTap, this.isSelected = false, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade700), const SizedBox(width: 6)],
            Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, alignment: Alignment.center, child: child);
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
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
                  Text(AppLabels.filterProfiles(context), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (ref.read(homeFilterProvider.notifier).isFilterActive)
                        TextButton.icon(
                          onPressed: () {
                            ref.read(homeFilterProvider.notifier).reset();
                            HapticFeedback.mediumImpact();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(AppLabels.reset(context)),
                          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        ),
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
                      // ================= SEARCH SECTION =================
                      const Text(
                        "Search",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (val) => ref.read(homeFilterProvider.notifier).updateSearchQuery(val),
                        controller: TextEditingController(text: filter.searchQuery)
                          ..selection = TextSelection.collapsed(offset: filter.searchQuery.length),
                        decoration: InputDecoration(
                          hintText: "Search by Name or ID",
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: filter.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => ref.read(homeFilterProvider.notifier).updateSearchQuery(''),
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ================= LOCATION SECTION =================
                      Text(
                        AppLabels.location(context),
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
                                title: AppLabels.state(context),
                                value: selectedState,
                                items: states,
                                itemLabel: (s) => s.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(homeFilterProvider.notifier).updateState(val.name);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown<CityModel>(
                                title: AppLabels.city(context),
                                value: selectedCity,
                                items: selectedState?.cities ?? [],
                                itemLabel: (c) => c.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(homeFilterProvider.notifier).updateCity(val.id);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ================= GENDER SECTION =================
                      Text(
                        AppLabels.gender(context),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown<String>(
                        title: AppLabels.gender(context),
                        value: filter.gender.isEmpty ? null : filter.gender,
                        items: [AppLabels.allProfiles(context), AppLabels.male(context), AppLabels.female(context)],
                        itemLabel: (g) => g,
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(homeFilterProvider.notifier).updateGender(val);
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // ================= AGE RANGE SECTION =================
                      Text(
                        "Age Range",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      RangeSlider(
                        values: RangeValues(filter.minAge, filter.maxAge),
                        min: 18,
                        max: 70,
                        divisions: 52,
                        activeColor: Theme.of(context).primaryColor,
                        labels: RangeLabels(filter.minAge.round().toString(), filter.maxAge.round().toString()),
                        onChanged: (RangeValues values) {
                          ref.read(homeFilterProvider.notifier).updateAgeRange(values.start, values.end);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${filter.minAge.round()} yrs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("${filter.maxAge.round()} yrs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ================= RELIGION SECTION =================
                      Text(
                        AppLabels.cultural(context),
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
                                title: AppLabels.religion(context),
                                value: selectedReligion,
                                items: religions,
                                itemLabel: (r) => r.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(homeFilterProvider.notifier).updateReligion(val.id);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown<CasteModel>(
                                title: AppLabels.caste(context),
                                value: selectedCaste,
                                items: selectedReligion?.castes ?? [],
                                itemLabel: (c) => c.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(homeFilterProvider.notifier).updateCaste(val.id);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // ================= QUICK FILTERS SECTION =================
                      Text(
                        "Quick Filters",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text("Just Joined (New)"),
                        subtitle: const Text("Show recently registered profiles first"),
                        value: filter.justJoined,
                        onChanged: (_) => ref.read(homeFilterProvider.notifier).toggleJustJoined(),
                        activeColor: Theme.of(context).primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text("Near Me (My City)"),
                        subtitle: const Text("Only show profiles from your city"),
                        value: filter.fromMyCity,
                        onChanged: (_) => ref.read(homeFilterProvider.notifier).toggleFromMyCity(),
                        activeColor: Theme.of(context).primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(AppLabels.applyFilters(context))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= DROPDOWN BUILDER =================
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

/// =======================
/// PROFILE CARD (SIMPLE)
/// =======================
class ProfileCard extends ConsumerStatefulWidget {
  final String uid;
  final String name;
  final int age;
  final DateTime dob;
  final dynamic designation;
  final dynamic income;
  final dynamic degree;
  final String religion;
  final List<String> images;
  final String? agentDesignation;
  final String location;
  final String height;
  final String caste;
  final bool isPremium;
  final bool isBlocked;
  final DateTime? lastSeen;

  const ProfileCard({
    super.key,
    required this.uid,
    required this.name,
    required this.age,
    required this.dob,
    required this.designation,
    this.income,
    this.degree,
    required this.religion,
    required this.images,
    this.agentDesignation,
    required this.location,
    required this.height,
    required this.caste,
    this.isPremium = false,
    this.isBlocked = false,
    this.lastSeen,
  });

  @override
  ConsumerState<ProfileCard> createState() => _ProfileCardState();
}

class _SuggestionsSection extends ConsumerWidget {
  final List<MatrimonyProfileViewModel> allProfiles;
  final UserEntity currentUser;

  const _SuggestionsSection({required this.allProfiles, required this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(homeFilterProvider);

    // 🔍 Improved suggestion logic
    final suggestions = allProfiles
        .where((vm) {
          if (vm.profile.userId == currentUser.uid) return false;

          // Case-insensitive and handles empty filters
          final matchesReligion =
              filter.religion.isNotEmpty && vm.profile.cultural.religion.en.toLowerCase().trim() == filter.religion.toLowerCase().trim();
          final matchesState =
              filter.state.isNotEmpty && vm.profile.address.state.en.toLowerCase().trim() == filter.state.toLowerCase().trim();

          return matchesReligion || matchesState;
        })
        .take(4)
        .toList();

    // 💡 FALLBACK: If no targeted suggestions, show the latest profiles instead of blank space
    final finalSuggestions = suggestions.isNotEmpty
        ? suggestions
        : allProfiles.where((vm) => vm.profile.userId != currentUser.uid).take(4).toList();

    if (finalSuggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: theme.primaryColor, size: 24),
                const SizedBox(width: 10),
                const Text(
                  "Suggested for You",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: finalSuggestions.length,
            itemBuilder: (context, index) {
              final vm = finalSuggestions[index];
              final isHindi = Localizations.localeOf(context).languageCode == 'hi';
              final name = isHindi ? vm.user?.fullName.hi : vm.user?.fullName.en;

              return GestureDetector(
                onTap: () => context.pushRoute(UserDetailRoute(uid: vm.profile.userId)),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Properly handled Cached Image
                      Builder(
                        builder: (context) {
                          final imageUrl = getDisplayImageForViewModel(vm);
                          if (imageUrl.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 400, // Smaller for grid suggestions
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.person, size: 40, color: Colors.grey),
                            );
                          }
                          return const Icon(Icons.person, size: 40, color: Colors.grey);
                        },
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? 'N/A',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${vm.profile.identity.age} yrs • ${isHindi ? vm.profile.cultural.caste.hi : vm.profile.cultural.caste.en}",
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _showActions = false;
  Timer? _autoSwipeTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    if (widget.images.length > 1) {
      _autoSwipeTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || !_pageController.hasClients) return;

        final nextIndex = (_currentImageIndex + 1) % widget.images.length;
        _pageController.animateToPage(nextIndex, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🖼 Image Section
            widget.images.isEmpty
                ? Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 80, color: Colors.grey),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                      // 🔄 Reset timer on manual swipe to prevent sudden jumps
                      _autoSwipeTimer?.cancel();
                      _startAutoSwipe();
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        memCacheHeight: 1000,
                        maxWidthDiskCache: 800,
                        maxHeightDiskCache: 1000,
                        fadeInDuration: const Duration(milliseconds: 150),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                        ),
                      );
                    },
                  ),

            // 🖤 Gradient Overlay (Bottom and Top)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.85)],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Navigation Area (Clickable to open details) - Covers image and background
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.isBlocked ? null : () => context.pushRoute(UserDetailRoute(uid: widget.uid)),
              ),
            ),

            // 👑 Top Right Badges & Options
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // 3 Dot Menu
                  GestureDetector(
                    onTap: () => _showProfileOptions(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                      child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.isPremium) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.workspace_premium, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.images.length}",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ◀️ Navigation Arrows
            if (widget.images.length > 1 && !widget.isBlocked) ...[
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white.withOpacity(0.6), size: 20),
                    onPressed: () {
                      if (_currentImageIndex > 0) {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.6), size: 20),
                    onPressed: () {
                      if (_currentImageIndex < widget.images.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                  ),
                ),
              ),
            ],

            // 🚫 Blocked Overlay
            if (widget.isBlocked)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.block_flipped, color: Colors.white, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          "Blocked Profile",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("You have blocked ${widget.name}", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(blockedUsersProvider.notifier).update((state) => {...state}..remove(widget.uid)),
                          icon: const Icon(Icons.undo_rounded, size: 18),
                          label: const Text("Unblock Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 📝 Profile Info Overlay
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: widget.isBlocked ? 0.3 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: widget.isBlocked ? null : () => context.pushRoute(UserDetailRoute(uid: widget.uid)),
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name, Age and DOB
                            Text(
                              "${widget.name}, ${widget.age} (${DateFormat('dd MMM yyyy').format(widget.dob)})",
                              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Row 1: Height · Location · Religion - Caste
                            Text(
                              [
                                if (widget.height != "0 cm") widget.height,
                                widget.location,
                                "${widget.religion} - ${widget.caste}",
                              ].join(' · '),
                              style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Row 2: Occupation · Earns Income
                            ...(() {
                              final des = widget.designation != null
                                  ? (widget.designation is BilingualValue
                                        ? (isHindi ? (widget.designation as BilingualValue).hi : (widget.designation as BilingualValue).en)
                                        : widget.designation.toString())
                                  : '';
                              final inc = widget.income != null
                                  ? "Earns ${widget.income is BilingualValue ? (isHindi ? (widget.income as BilingualValue).hi : (widget.income as BilingualValue).en) : widget.income.toString()}"
                                  : '';
                              final items = [if (des.isNotEmpty) des, if (inc.isNotEmpty) inc];
                              if (items.isEmpty) return <Widget>[];
                              return [
                                const SizedBox(height: 1),
                                Text(
                                  items.join(' · '),
                                  style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13.5, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ];
                            }()),

                            // Row 3: Education/Degree
                            ...(() {
                              if (widget.degree == null) return <Widget>[];
                              final deg = widget.degree is BilingualValue
                                  ? (isHindi ? (widget.degree as BilingualValue).hi : (widget.degree as BilingualValue).en)
                                  : widget.degree.toString();
                              if (deg.isEmpty) return <Widget>[];
                              return [
                                const SizedBox(height: 1),
                                Text(
                                  deg,
                                  style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13.5, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ];
                            }()),

                            const SizedBox(height: 6),

                            // Status Chips
                            Row(
                              children: [
                                _StatusChip(
                                  icon: Icons.circle,
                                  iconColor: Colors.green,
                                  label: _timeAgo(widget.lastSeen),
                                  backgroundColor: Colors.black.withOpacity(0.4),
                                ),
                                const SizedBox(width: 10),
                                _StatusChip(
                                  icon: Icons.people,
                                  iconColor: Colors.redAccent,
                                  label: "You & ${widget.isPremium ? 'Him' : 'Her'}", // Dynamic based on gender if available
                                  backgroundColor: Colors.black.withOpacity(0.4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Connect Now Button or Actions
                    if (!_showActions)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () => setState(() => _showActions = true),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF09BE6E), Color(0xFF0AA4B8)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF0AA4B8).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, color: Colors.white),
                                Text(
                                  " Connect Now",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                          decoration: BoxDecoration(color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 1. Chat Button
                              _ActionButton(
                                icon: Icons.chat_bubble_rounded,
                                label: "Chat",
                                backgroundColor: Colors.teal,
                                onTap: () {
                                  final currentUserId = ref.read(currentUserProvider).value?.uid;
                                  if (currentUserId == null) return;
                                  final paymentState = ref.read(paymentNotifierProvider(currentUserId));

                                  if (paymentState.status == PayStatus.success) {
                                    context.pushRoute(UserChatRoomRoute(peerId: widget.uid));
                                  } else {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => const PremiumUpgradeBottomSheet(),
                                    );
                                  }
                                },
                              ),
                              // 2. Wishlist Button
                              Consumer(
                                builder: (context, ref, _) {
                                  final currentUserId = ref.watch(currentUserProvider).value?.uid;
                                  if (currentUserId == null) return const SizedBox.shrink();
                                  final wishlistAsync = ref.watch(myWishlistStreamProvider(currentUserId));
                                  return wishlistAsync.when(
                                    data: (wishlists) {
                                      final isSaved = wishlists.any((w) => w.receiverId == widget.uid);
                                      return _ActionButton(
                                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                                        label: "Wishlist",
                                        backgroundColor: Colors.red,
                                        onTap: () async {
                                          final wishlistRepo = ref.read(myWishlistNotifierProvider.notifier);
                                          if (isSaved) {
                                            final wish = wishlists.firstWhere((w) => w.receiverId == widget.uid);
                                            await wishlistRepo.removeWishlist(wish.id);
                                          } else {
                                            final homeProfiles = ref.read(homeControllerProvider).metrimonyProfiles.value ?? [];
                                            final profileVM = homeProfiles.firstWhere((p) => p.profile.userId == widget.uid);
                                            final currentUserData = await ref.read(userRepositoryProvider).fetchUser(currentUserId);
                                            final wishListItem = WishlistEntity(
                                              senderId: currentUserId,
                                              receiverId: widget.uid,
                                              receiverAgent: profileVM.profile.userId.isNotEmpty ? profileVM.user?.agentId ?? '' : '',
                                              senderAgent: currentUserData.agentId,
                                              status: "pending",
                                              updatedAt: DateTime.now(),
                                            );
                                            await wishlistRepo.addWishlist(wishListItem);
                                          }
                                        },
                                      );
                                    },
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const Icon(Icons.error, color: Colors.white),
                                  );
                                },
                              ),
                              // 3. Call Button
                              _ActionButton(
                                icon: Icons.call,
                                label: "Call",
                                backgroundColor: Colors.green,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Calling feature coming soon!")));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(BuildContext context, WidgetRef ref) {
    final isBlocked = ref.read(blockedUsersProvider).contains(widget.uid);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                icon: Icons.share_outlined,
                label: "Share",
                onTap: () async {
                  Navigator.pop(context);
                  final isHindi = Localizations.localeOf(context).languageCode == 'hi';
                  final profileName = isHindi ? widget.name : widget.name; // name is already local handled

                  final String message = isHindi
                      ? "शादी मिलन पर इस प्रोफाइल को देखें: $profileName, ${widget.age} वर्ष, ${widget.location}। अभी ऐप डाउनलोड करें: https://play.google.com/store/apps/details?id=com.shaadimilan.app"
                      : "Check out this profile on Shaadi Milan: $profileName, ${widget.age} yrs, ${widget.location}. Download the app now: https://play.google.com/store/apps/details?id=com.shaadimilan.app";

                  await Share.share(message);
                },
              ),
              _buildOptionTile(
                icon: Icons.star_border_rounded,
                label: "Add to Shortlist",
                onTap: () async {
                  Navigator.pop(context);
                  final currentUserId = ref.read(currentUserProvider).value?.uid;
                  if (currentUserId == null) return;

                  final homeProfiles = ref.read(homeControllerProvider).metrimonyProfiles.value ?? [];
                  final profileVM = homeProfiles.firstWhere((p) => p.profile.userId == widget.uid);
                  final currentUserData = await ref.read(userRepositoryProvider).fetchUser(currentUserId);

                  final wishListItem = WishlistEntity(
                    senderId: currentUserId,
                    receiverId: widget.uid,
                    receiverAgent: profileVM.user?.agentId ?? '',
                    senderAgent: currentUserData.agentId,
                    status: "pending",
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(myWishlistNotifierProvider.notifier).addWishlist(wishListItem);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Shortlist!")));
                },
              ),
              _buildOptionTile(
                icon: Icons.visibility_off_outlined,
                label: "Hide this Profile",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile hidden successfully")));
                },
              ),
              if (isBlocked)
                _buildOptionTile(
                  icon: Icons.undo_rounded,
                  label: "Unblock this Profile",
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(blockedUsersProvider.notifier).update((state) => {...state}..remove(widget.uid));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Unblocked!")));
                  },
                )
              else
                _buildOptionTile(
                  icon: Icons.block_flipped,
                  label: "Block this Profile",
                  onTap: () {
                    Navigator.pop(context);
                    _showBlockConfirmation(context, ref);
                  },
                ),
              _buildOptionTile(
                icon: Icons.report_gmailerrorred_rounded,
                label: "Report this Profile",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report submitted! We will review it.")));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBlockConfirmation(BuildContext context, WidgetRef ref) {
    bool isChecked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.block_flipped, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text("Block ${widget.name}?", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    "They will no longer be able to see your profile or contact you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    value: isChecked,
                    onChanged: (val) => setModalState(() => isChecked = val ?? false),
                    title: const Text("I understand this action and want to block this user.", style: TextStyle(fontSize: 13)),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isChecked
                              ? () {
                                  ref.read(blockedUsersProvider.notifier).update((state) => {...state, widget.uid});
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Blocked")));
                                }
                              : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                          child: const Text("Block"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Header Shimmer
        Container(
          height: 60,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Profile Card Shimmer
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color backgroundColor;

  const _StatusChip({required this.icon, required this.iconColor, required this.label, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
