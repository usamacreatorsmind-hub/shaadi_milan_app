import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/metrimony_notifier.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/user_nofier.dart';
import 'package:shadi_milan/features/user/user_app/domain/repositories/user_recemmonded_repository.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/recemonded_profiles.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to fetch all matrimony profile view models
final allProfilesProvider = FutureProvider<List<MetrimonyProfileViewModel>>((
  ref,
) async {
  final datasource = ref.watch(metrimonyFirestoreDsProvider);
  final paymentsRepository = ref.watch(userPaymentsRepositoryProvider);
  final profilesData = await datasource.getAllMetrimonyProfiles();

  // Fetch all profile details in parallel for better performance
  final results = await Future.wait(
    profilesData.map((profile) async {
      try {
        final vm = await datasource.getMetrimonyProfileViewModel(
          profile['userId'],
        );

        if (vm == null) return null;

        // Basic validation
        if (!vm.user.isProfileCreated) return null;

        // Optional: If you only want to show matches who have paid
        if (vm.user.agentId.isNotEmpty) {
          final payment = await paymentsRepository.getUserPayment(
            userId: vm.user.uid,
            agentId: vm.user.agentId,
          );
          if (payment?.status.toUpperCase() != 'SUCCESS') return null;
        }

        return vm;
      } catch (e) {
        debugPrint('Error loading profile ${profile['userId']}: $e');
        return null;
      }
    }),
  );

  return results.whereType<MetrimonyProfileViewModel>().toList();
});

@RoutePage()
class ProfileMatchScreen extends ConsumerStatefulWidget {
  final MetrimonyProfileViewModel profile;
  const ProfileMatchScreen({super.key, required this.profile});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileMatchScreenState();
}

class _ProfileMatchScreenState extends ConsumerState<ProfileMatchScreen> {
  RecommendedProfiles? _recommendedProfiles;

  // ── Search ───────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _normalize(String value) => value.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _loadExistingRecommendations();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRecommendations() async {
    try {
      final repo = ref.read(userRecemmondedRepositoryProvider);
      final existing = await repo.fetchRecommendedProfiles(
        widget.profile.user.uid,
      );
      setState(() {
        _recommendedProfiles = existing;
      });
    } catch (e) {
      debugPrint('No existing recommendations found: $e');
      setState(() {
        _recommendedProfiles = RecommendedProfiles(
          userId: widget.profile.user.uid,
          name: widget.profile.user.fullName,
          phone: widget.profile.user.phone,
          gender: widget.profile.identity.gender,
          ids: [],
        );
      });
    }
  }

  Future<void> _recommendProfile(MetrimonyProfileViewModel match) async {
    if (_recommendedProfiles!.ids.contains(match.user.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile already recommended!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final repo = ref.read(userRecemmondedRepositoryProvider);

    // Perform mutual recommendation using the repository's batch update method
    final success = await repo.updateMutualRecommendedProfiles(
      sourceUid: widget.profile.user.uid,
      sourceName: widget.profile.user.fullName,
      sourcePhone: widget.profile.user.phone,
      sourceGender: widget.profile.identity.gender,
      targetUid: match.user.uid,
      targetName: match.user.fullName,
      targetPhone: match.user.phone,
      targetGender: match.identity.gender,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _recommendedProfiles!.ids.add(match.user.uid);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile Recommended Successfully'
                : 'Failed to Recommend Profile',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeRecommendation(MetrimonyProfileViewModel match) async {
    final repo = ref.read(userRecemmondedRepositoryProvider);

    // Perform mutual recommendation removal using the repository's batch update method
    final success = await repo.removeMutualRecommendedProfiles(
      sourceUid: widget.profile.user.uid,
      targetUid: match.user.uid,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _recommendedProfiles!.ids.remove(match.user.uid);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Recommendation Removed Successfully'
                : 'Failed to Remove Recommendation',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProfilesAsync = ref.watch(allProfilesProvider);

    // Prevent LateInitializationError by checking if data is loaded
    if (_recommendedProfiles == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final sourceGender = widget.profile.identity.gender.toLowerCase();
    final targetGender = sourceGender == 'male' ? 'female' : 'male';
    final sourceReligion = _normalize(widget.profile.cultural.religion);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Matches'),
        backgroundColor: theme.primaryColor,
        // foregroundColor: theme.colorScheme.onPrimary,
        // ── SEARCH BAR pinned inside AppBar bottom ──────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name, caste, religion, city…',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: allProfilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profiles) {
          // ── 1. Caste / region filter (existing logic) ──────
          final matches = profiles.where((p) {
            final isOppositeGender =
                p.identity.gender.toLowerCase() == targetGender;
            final isNotSelf = p.user.uid != widget.profile.user.uid;
            if (!isOppositeGender || !isNotSelf) return false;

            final sameReligion =
                sourceReligion.isNotEmpty &&
                _normalize(p.cultural.religion) == sourceReligion;

            return sameReligion;
          }).toList();

          // ── 2. Search filter ────────────────────────────────
          final q = _normalize(_searchQuery);
          final filtered = q.isEmpty
              ? matches
              : matches.where((p) {
                  return _normalize(p.user.fullName).contains(q) ||
                      // _normalize(p.cultural.caste).contains(q) ||
                      _normalize(p.cultural.religion).contains(q) ||
                      _normalize(p.address.city).contains(q) ||
                      _normalize(p.address.state).contains(q);
                }).toList();

          if (matches.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No matching profiles found for the same religion.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 56,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No results for "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _searchController.clear(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear search'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── count bar ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Matches for ${widget.profile.user.fullName}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        q.isEmpty
                            ? '${filtered.length} match${filtered.length != 1 ? 'es' : ''}'
                            : '${filtered.length} / ${matches.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final match = filtered[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          _recommendedProfiles!.ids.contains(match.user.uid)
                          ? _removeRecommendation(match)
                          : _recommendProfile(match),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// IMAGE
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: SizedBox(
                                height: 240,
                                width: double.infinity,
                                child: match.images.primaryImageUrl.isNotEmpty
                                    ? Image.network(
                                        match.images.primaryImageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          size: 80,
                                        ),
                                      ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// NAME + VERIFIED
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          match.user.fullName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      if (_recommendedProfiles!.ids.contains(
                                        match.user.uid,
                                      ))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Recommended',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  /// DETAILS
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _infoChip(
                                        Icons.cake,
                                        '${match.identity.age} Years',
                                      ),

                                      _infoChip(
                                        Icons.temple_hindu,
                                        match.cultural.religion,
                                      ),

                                      _infoChip(
                                        Icons.people,
                                        match.cultural.caste,
                                      ),

                                      _infoChip(
                                        Icons.location_on,
                                        match.address.city,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  /// BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _recommendedProfiles!.ids.contains(
                                            match.user.uid,
                                          )
                                          ? _removeRecommendation(match)
                                          : _recommendProfile(match),
                                      icon: Icon(
                                        _recommendedProfiles!.ids.contains(
                                              match.user.uid,
                                            )
                                            ? Icons.favorite_border
                                            : Icons.favorite,
                                      ),
                                      label: Text(
                                        _recommendedProfiles!.ids.contains(
                                              match.user.uid,
                                            )
                                            ? 'Remove Recommendation'
                                            : 'Recommend Profile',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _recommendedProfiles!.ids.contains(
                                              match.user.uid,
                                            )
                                            ? Colors.red.shade400
                                            : theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.pushRoute(
                                        ViewUserRoute(
                                          userId: match.user.uid,
                                          showMatchButton: false,
                                        ),
                                      ),
                                      icon: const Icon(Icons.person_outline),
                                      label: const Text('View Full Profile'),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
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
            ],
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
