import 'package:flutter_riverpod/legacy.dart';

import '../../../../../app/router/app_router.dart';
import '../../domain/states/state_city.dart';
import '../controllers/home_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

/// =======================
/// LOCATION STATE
/// =======================
class LocationState {
  final String state;
  final String city;

  const LocationState({required this.state, required this.city});

  LocationState copyWith({String? state, String? city}) {
    return LocationState(state: state ?? this.state, city: city ?? this.city);
  }
}

/// =======================
/// LOCATION PROVIDER
/// =======================
final locationProvider =
    StateNotifierProvider<LocationController, LocationState>(
      (ref) => LocationController(),
    );

class LocationController extends StateNotifier<LocationState> {
  LocationController()
    : super(const LocationState(state: 'Maharashtra', city: 'Mumbai'));

  void updateState(String value) {
    // reset city when state changes
    state = state.copyWith(state: value, city: '');
  }

  void updateCity(String value) {
    state = state.copyWith(city: value);
  }
}

/// =======================
/// USER HOME SCREEN
/// =======================
@RoutePage()
class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(userHomeControllerProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// ================= APP BAR =================
          SliverAppBar(
            pinned: true,

            snap: false,
            stretch: true,
            elevation: 0,
            toolbarHeight: 88,
            titleSpacing: 0,

            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.pink.shade50.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            title: Row(
              children: [
                // 🌸 Glowing logo
                SizedBox(
                  height: 100,
                  width: 100,

                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.favorite, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 🌹 Brand typography
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Colors.pinkAccent,
                        ],
                      ).createShader(bounds),

                      child: const Text(
                        'Arvika Marriage Bureau',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Find your perfect match',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.pinkAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

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
                            child: Text(
                              location.city.isEmpty
                                  ? location.state
                                  : '${location.city}, ${location.state}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (_, __, ___) => const FilterRightSheet(),
                        transitionBuilder: (_, animation, __, child) {
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

          /// ================= PROFILES LIST =================
          homeState.metrimonyProfiles.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) {
              print('Error loading profiles: $e');

              print(e);

              return SliverToBoxAdapter(
                child: Center(child: Text(e.toString())),
              );
            },
            data: (profiles) {
              final filteredProfiles = profiles.where((profile) {
                // If no state is selected, or if state matches
                final stateMatch =
                    location.state.isEmpty ||
                    (profile.address?.state == location.state);
                // If no city is selected, or if city matches
                final cityMatch =
                    location.city.isEmpty ||
                    (profile.address?.city == location.city);
                return stateMatch && cityMatch;
              }).toList();

              if (filteredProfiles.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No profiles match your filter.'),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final profile = filteredProfiles[index];
                  debugPrint(profile.images?.secondaryImageUrls.toString());
                  debugPrint(profile.images?.primaryImageUrl.toString());
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    // child: ProfileCard(
                    //   uid: profile.user?.uid ?? "",

                    //   name: profile.user?.fullName ?? "N/A",
                    //   age: profile.identity?.age ?? 0,
                    //   designation: profile.employment?.designation ?? "N/A",
                    //   imageUrl: profile.images?.primaryImageUrl ?? "",
                    // ),
                  );
                }, childCount: filteredProfiles.length),
              );
            },
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
    final location = ref.watch(locationProvider);
    final locationAsync = ref.watch(locationJsonProvider);

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: locationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (states) {
              /// All state names from JSON
              final stateNames = states.map((e) => e.name).toList();

              /// Selected state object
              final selectedState = states.firstWhere(
                (s) => s.name == location.state,
                orElse: () => StateCityModel(name: '', cities: []),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),

                  /// ================= STATE DROPDOWN =================
                  _buildDropdown(
                    title: 'State',
                    value: location.state,
                    items: stateNames,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(locationProvider.notifier).updateState(val);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  /// ================= CITY DROPDOWN =================
                  _buildDropdown(
                    title: 'City',
                    value: location.city.isEmpty ? null : location.city,
                    items: selectedState.cities,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(locationProvider.notifier).updateCity(val);
                      }
                    },
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              );
            },
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
          value: value,
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
    return Container(
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
      child: GestureDetector(
        onTap: () {
          context.router.push(UserDetailRoute(uid: uid));
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
                bottom: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                height: MediaQuery.of(context).size.height * 0.55,
                width: double.infinity,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$age years', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 4),

                  Text(designation, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.router.push(UserDetailRoute(uid: uid));
                      },
                      child: const Text('View Profile'),
                    ),
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
