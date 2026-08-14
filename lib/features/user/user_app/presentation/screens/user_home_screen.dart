import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadi_milan/core/app_version_config/remote_config_service.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import '../../../../agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../../../../core/filters/home_filter_controller.dart';
import '../../../../../app/router/app_router.dart';
import '../../domain/states/religion_state.dart';
import '../../domain/states/state_city.dart';
import '../controllers/home_controller.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  initState() {
    super.initState();

    // If you want fresh data every time the screen is entered,
    // invalidate is fine. However, watch() will trigger the fetch
    // automatically if not already loaded. If you need a manual refresh,
    // consider adding a RefreshIndicator to the UI instead of
    // invalidating on every initState.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Fetch the matrimony profiles when screen loads
      ref.invalidate(homeControllerProvider);
      // ref.invalidate(currentUserRecommendedIdsProvider);

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return Center(child: Text(AppLabels.userNotFound(context)));

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
            return homeState.metrimonyProfiles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (profiles) {
                final currentUserProfile = profiles.where((p) => p.profile.userId == user.uid).firstOrNull?.profile;
                final myCity = currentUserProfile?.address.city.en.toLowerCase().trim() ?? '';

                var filteredProfiles = profiles.where((viewModel) {
                  final profile = viewModel.profile;
                  if (profile.userId == user.uid) return false;

                  final stateMatch =
                      filter.state.isEmpty || (profile.address.state.en.toLowerCase().trim() == filter.state.toLowerCase().trim());
                  final cityMatch =
                      filter.city.isEmpty || (profile.address.city.en.toLowerCase().trim() == filter.city.toLowerCase().trim());
                  final religionMatch =
                      filter.religion.isEmpty ||
                      (profile.cultural.religion.en.toLowerCase().trim() == filter.religion.toLowerCase().trim());
                  final casteMatch =
                      filter.caste.isEmpty || (profile.cultural.caste.en.toLowerCase().trim() == filter.caste.toLowerCase().trim());

                  bool genderMatch = true;
                  final filterGender = filter.gender;
                  if (filterGender.isNotEmpty && filterGender != AppLabels.allProfiles(context)) {
                    genderMatch = profile.identity.gender.en.toLowerCase() == filterGender.toLowerCase();
                  }

                  bool cityFilterMatch = true;
                  if (filter.fromMyCity && myCity.isNotEmpty) {
                    cityFilterMatch = profile.address.city.en.toLowerCase().trim() == myCity;
                  }

                  return stateMatch && cityMatch && religionMatch && casteMatch && genderMatch && cityFilterMatch;
                }).toList();

                if (filter.justJoined) {
                  filteredProfiles.sort((a, b) {
                    final dateA = a.user?.createdAt ?? DateTime(1900);
                    final dateB = b.user?.createdAt ?? DateTime(1900);
                    return dateB.compareTo(dateA);
                  });
                }

                final visibleProfiles = filteredProfiles.where((viewModel) => isRecommended(viewModel)).toList();

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      title: const Text(
                        "My matches",
                        style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      centerTitle: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
                          onPressed: () => context.router.push(const UserNotificationRoute()),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            _FilterChip(label: "Filters", icon: Icons.tune, onTap: () => _showFilterDialog(context)),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: "Just Joined",
                              isSelected: filter.justJoined,
                              onTap: () => ref.read(homeFilterProvider.notifier).toggleJustJoined(),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: "From my City",
                              isSelected: filter.fromMyCity,
                              onTap: () => ref.read(homeFilterProvider.notifier).toggleFromMyCity(),
                            ),
                          ],
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
                                  Text(
                                    AppLabels.noProfilesFound(context),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
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
                          scrollDirection: Axis.vertical,
                          itemCount: visibleProfiles.length + (visibleProfiles.length ~/ 4),
                          itemBuilder: (context, index) {
                            // Every 5th item is a suggestions section
                            if (index > 0 && (index + 1) % 5 == 0) {
                              return _SuggestionsSection(allProfiles: filteredProfiles, currentUser: user);
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

                            final allImages = {
                              if (profile.images.primaryImageUrl.isNotEmpty) profile.images.primaryImageUrl,
                              ...profile.images.secondaryImageUrls.where((url) => url.isNotEmpty),
                              if (profile.images.profileImageUrl.isNotEmpty) profile.images.profileImageUrl,
                              if (profile.images.imageWithAgentUrl.isNotEmpty) profile.images.imageWithAgentUrl,
                            }.toList();

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final paymentState = ref.watch(paymentNotifierProvider(profile.userId));
                                  final isPremium = paymentState.status == PayStatus.success;

                                  return ProfileCard(
                                    uid: profile.userId,
                                    name: displayName.isEmpty ? 'N/A' : displayName,
                                    age: profile.identity.age,
                                    dob: profile.identity.dob,
                                    designation: designation,
                                    images: allImages,
                                    agentDesignation: agent?.designation.label,
                                    location: location,
                                    height: "${profile.physical.height} cm",
                                    caste: caste,
                                    isPremium: isPremium,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                );
              },
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

  const _FilterChip({required this.label, this.icon, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey.shade300),
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
                      TextButton(
                        onPressed: () {
                          ref.read(homeFilterProvider.notifier).reset();
                        },
                        child: Text(AppLabels.reset(context)),
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
class ProfileCard extends StatefulWidget {
  final String uid;
  final String name;
  final int age;
  final DateTime dob;
  final dynamic designation;
  final List<String> images;
  final String? agentDesignation;
  final String location;
  final String height;
  final String caste;
  final bool isPremium;

  const ProfileCard({
    super.key,
    required this.uid,
    required this.name,
    required this.age,
    required this.dob,
    required this.designation,
    required this.images,
    this.agentDesignation,
    required this.location,
    required this.height,
    required this.caste,
    this.isPremium = false,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _SuggestionsSection extends ConsumerWidget {
  final List<MatrimonyProfileViewModel> allProfiles;
  final UserEntity currentUser;

  const _SuggestionsSection({required this.allProfiles, required this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(homeFilterProvider);

    // Filter suggestions based on preferences (Same religion or same city as fallback)
    final suggestions = allProfiles
        .where((vm) {
          if (vm.profile.userId == currentUser.uid) return false;

          final matchesReligion = vm.profile.cultural.religion.en == filter.religion;
          final matchesState = vm.profile.address.state.en == filter.state;

          return matchesReligion || matchesState;
        })
        .take(4)
        .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final vm = suggestions[index];
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
                        if (vm.profile.images.primaryImageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: vm.profile.images.primaryImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.person, size: 40, color: Colors.grey),
                          )
                        else
                          const Icon(Icons.person, size: 40, color: Colors.grey),

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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (widget.images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentImageIndex + 1) % widget.images.length;
        _pageController.animateToPage(nextIndex, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.router.push(UserDetailRoute(uid: widget.uid)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image Section
                widget.images.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, size: 80, color: Colors.grey),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: widget.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: widget.images[index],
                                fit: BoxFit.cover,
                                memCacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).round(),
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(width: double.infinity, height: double.infinity, color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                          // Image Indicators (Tinder style)
                          if (widget.images.length > 1)
                            Positioned(
                              top: 12,
                              left: 12,
                              right: 12,
                              child: Row(
                                children: List.generate(
                                  widget.images.length,
                                  (index) => Expanded(
                                    child: Container(
                                      height: 3,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Profile Info Overlay
                Positioned(
                  left: 20,
                  bottom: 24,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.isPremium) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                                        child: const Icon(Icons.verified, color: Colors.white, size: 18),
                                      ),
                                    ],
                                    if (widget.age > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        "${widget.age}",
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (widget.dob.year != 1900) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "DOB: ${DateFormat('dd MMM yyyy').format(widget.dob)}",
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              // Chat / Connect Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    context.pushRoute(UserChatRoomRoute(peerId: widget.uid));
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 26),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Chat",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              Consumer(
                                builder: (context, ref, child) {
                                  final currentUserId = ref.watch(currentUserProvider).value?.uid;
                                  if (currentUserId == null) return const SizedBox.shrink();

                                  final wishlistAsync = ref.watch(myWishlistStreamProvider(currentUserId));

                                  return wishlistAsync.when(
                                    data: (wishlists) {
                                      final isSaved = wishlists.any((w) => w.receiverId == widget.uid);
                                      return Column(
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                final wishlistRepo = ref.read(myWishlistNotifierProvider.notifier);
                                                if (isSaved) {
                                                  final wish = wishlists.firstWhere((w) => w.receiverId == widget.uid);
                                                  await wishlistRepo.removeWishlist(wish.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(const SnackBar(content: Text('Removed from Wishlist')));
                                                  }
                                                } else {
                                                  // Get user data for agent IDs
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
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(const SnackBar(content: Text('Saved to Wishlist')));
                                                  }
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(30),
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: isSaved ? Colors.red : Colors.white.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                                ),
                                                child: Icon(
                                                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                                                  color: Colors.white,
                                                  size: 26,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isSaved ? "Saved" : "Save",
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      );
                                    },
                                    loading: () => const CircularProgressIndicator(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.image_outlined, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${widget.images.length}",
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.height != "0.0 cm" || widget.location.isNotEmpty || widget.caste.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            [
                              if (widget.height != "0.0 cm") widget.height,
                              if (widget.location.isNotEmpty) widget.location,
                              if (widget.caste.isNotEmpty) widget.caste,
                            ].join(' • '),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      if (widget.designation != null &&
                          widget.designation.toString().toLowerCase() != 'null' &&
                          widget.designation.toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.designation is BilingualValue
                              ? (Localizations.localeOf(context).languageCode == 'hi'
                                    ? (widget.designation as BilingualValue).hi
                                    : (widget.designation as BilingualValue).en)
                              : widget.designation.toString(),
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w400),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
