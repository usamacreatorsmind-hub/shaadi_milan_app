import 'package:arvika_marriage_bureau/core/filters/home_filter_controller.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../../app/router/app_router.dart';
import '../../domain/states/religion_state.dart';
import '../../domain/states/state_city.dart';
import '../controllers/home_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';



/// =======================
/// USER HOME SCREEN
/// =======================
@RoutePage()
class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final filter = ref.watch(homeFilterProvider);

    String filterText = '';
    if (filter.city.isNotEmpty) {
      filterText = '${filter.city}, ${filter.state}';
    } else if (filter.state.isNotEmpty) {
      filterText = filter.state;
    }

    if (filter.religion.isNotEmpty) {
      if (filterText.isNotEmpty) filterText += ' • ';
      filterText += filter.religion;
      if (filter.caste.isNotEmpty) {
        filterText += ' (${filter.caste})';
      }
    }

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
                            child: Marquee(
                              pauseDuration: Duration(milliseconds: 500),
                              velocity: 50,

                              filterText.isEmpty ? 'All Profiles' : filterText,
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

                return stateMatch && cityMatch && religionMatch && casteMatch;
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
                  final viewModel = filteredProfiles[index];
                  final profile = viewModel.profile;
                  final user = viewModel.user;

                  debugPrint(profile.images.secondaryImageUrls.toString());
                  debugPrint(profile.images.primaryImageUrl.toString());
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ProfileCard(
                      uid: profile.userId,
                      name: user?.fullName ?? 'N/A',
                      age: profile.identity.age ?? 0,
                      designation: profile.employment.designation ?? "N/A",
                      imageUrl: profile.images.primaryImageUrl ?? "",
                    ),
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
/// MARQUEE WIDGET
/// =======================
class Marquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pauseDuration;
  final double velocity;

  const Marquee(
    this.text, {
    super.key,
    required this.style,
    this.pauseDuration = const Duration(seconds: 2),
    this.velocity = 30.0, // pixels per second
  });

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());
  }

  @override
  void didUpdateWidget(Marquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // When text changes, reset and the loop will restart with new dimensions.
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll() async {
    while (!_isDisposed) {
      // Wait for controller to be attached
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      // Only scroll if there's overflow
      if (_scrollController.position.maxScrollExtent > 0) {
        final scrollDuration = Duration(
          milliseconds:
              (_scrollController.position.maxScrollExtent /
                      widget.velocity *
                      1000)
                  .toInt(),
        );

        await Future.delayed(widget.pauseDuration);
        if (_isDisposed) break;

        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: scrollDuration,
          curve: Curves.linear,
        );
        if (_isDisposed) break;

        await Future.delayed(widget.pauseDuration);
        if (_isDisposed) break;

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        softWrap: false,
        maxLines: 1,
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
              child: imageUrl.isEmpty
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 60),
                    )
                  : Image.network(
                      imageUrl,
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: double.infinity,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        width: double.infinity,
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
