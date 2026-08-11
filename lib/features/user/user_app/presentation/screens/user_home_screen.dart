import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadi_milan/core/app_version_config/remote_config_service.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';

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
            return CustomScrollView(
              slivers: [
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

                /// ================= FILTER CHIPS =================
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        _FilterChip(label: "Filters", icon: Icons.tune, onTap: () => _showFilterDialog(context)),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "Just Joined",
                          isSelected: filter.justJoined,
                          onTap: () => ref.read(homeFilterProvider.notifier).toggleJustJoined(),
                        ),
                        const SizedBox(width: 8),
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

                /// ================= PROFILES LIST =================
                homeState.metrimonyProfiles.when(
                  loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                  error: (e, _) {
                    debugPrint('Error loading profiles: $e');

                    return SliverToBoxAdapter(child: Center(child: Text(e.toString())));
                  },
                  data: (profiles) {
                    final currentUserProfile = profiles.where((p) => p.profile.userId == user.uid).firstOrNull?.profile;
                    final myCity = currentUserProfile?.address.city.en.toLowerCase().trim() ?? '';

                    var filteredProfiles = profiles.where((viewModel) {
                      final profile = viewModel.profile;

                      // Don't show the current user's own profile in the matches list
                      if (profile.userId == user.uid) return false;

                      // If no state is selected, or if state matches
                      final stateMatch =
                          filter.state.isEmpty || (profile.address.state.en.toLowerCase().trim() == filter.state.toLowerCase().trim());

                      // If no city is selected, or if city matches
                      final cityMatch =
                          filter.city.isEmpty || (profile.address.city.en.toLowerCase().trim() == filter.city.toLowerCase().trim());

                      // If no religion is selected, or if religion matches
                      final religionMatch =
                          filter.religion.isEmpty ||
                          (profile.cultural.religion.en.toLowerCase().trim() == filter.religion.toLowerCase().trim());

                      // If no caste is selected, or if caste matches
                      final casteMatch =
                          filter.caste.isEmpty || (profile.cultural.caste.en.toLowerCase().trim() == filter.caste.toLowerCase().trim());

                      // Gender matching logic
                      bool genderMatch = true;
                      final filterGender = filter.gender;

                      if (filterGender.isNotEmpty && filterGender != AppLabels.allProfiles(context)) {
                        genderMatch = profile.identity.gender.en.toLowerCase() == filterGender.toLowerCase();
                      }

                      // "From my City" filter
                      bool cityFilterMatch = true;
                      if (filter.fromMyCity && myCity.isNotEmpty) {
                        cityFilterMatch = profile.address.city.en.toLowerCase().trim() == myCity;
                      }

                      return stateMatch && cityMatch && religionMatch && casteMatch && genderMatch && cityFilterMatch;
                    }).toList();

                    // "Just Joined" sorting: Sort by createdAt descending if enabled
                    if (filter.justJoined) {
                      filteredProfiles.sort((a, b) {
                        final dateA = a.user?.createdAt ?? DateTime(1900);
                        final dateB = b.user?.createdAt ?? DateTime(1900);
                        return dateB.compareTo(dateA); // Newest first
                      });
                    }

                    // Only show recommended profiles
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
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Column(
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
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final viewModel = visibleProfiles[index];
                          final profile = viewModel.profile;
                          final user = viewModel.user;
                          final agent = viewModel.agent;
                          final isHindi = Localizations.localeOf(context).languageCode == 'hi';
                          final displayName = user != null ? (isHindi ? user.fullName.hi : user.fullName.en) : 'N/A';

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
                          }.toList(); // Ensure unique URLs

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ProfileCard(
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
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.router.push(UserDetailRoute(uid: widget.uid)),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      width: double.infinity,
                      child: widget.images.isEmpty
                          ? Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, size: 80, color: Colors.grey),
                            )
                          : Stack(
                              children: [
                                PageView.builder(
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
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.1), Colors.transparent, Colors.black.withOpacity(0.7)],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
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
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "${widget.name}${widget.age > 0 ? ', ${widget.age}' : ''}",
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        if (widget.dob.year != 1900) ...[
                          const SizedBox(height: 4),
                          Text(
                            "DOB: ${DateFormat('dd MMM yyyy').format(widget.dob)}",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                        if (widget.height != "0.0 cm" || widget.location.isNotEmpty || widget.caste.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (widget.height != "0.0 cm") widget.height,
                              if (widget.location.isNotEmpty) widget.location,
                              if (widget.caste.isNotEmpty) widget.caste,
                            ].join(' • '),
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                        ],
                        if (widget.designation != null &&
                            widget.designation.toString().toLowerCase() != 'null' &&
                            widget.designation.toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.designation is BilingualValue
                                ? (Localizations.localeOf(context).languageCode == 'hi'
                                      ? (widget.designation as BilingualValue).hi
                                      : (widget.designation as BilingualValue).en)
                                : widget.designation.toString(),
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
