import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/metrimony_notifier.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/user_nofier.dart';
import 'package:shadi_milan/features/l10n/l10n_helper.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/domain/repositories/user_recemmonded_repository.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/metrimony_profile_view_model.dart';

import '../../../../user/user_app/domain/states/recemonded_profiles.dart';
import '../../../../user/user_app/domain/states/religion_state.dart';
import '../../../../user/user_app/domain/states/state_city.dart';

// Provider to fetch all matrimony profile view models
final allProfilesProvider = FutureProvider<List<MetrimonyProfileViewModel>>((ref) async {
  final datasource = ref.watch(metrimonyFirestoreDsProvider);
  final paymentsRepository = ref.watch(userPaymentsRepositoryProvider);
  final profilesData = await datasource.getAllMetrimonyProfiles();

  // Fetch all profile details in parallel for better performance
  final results = await Future.wait(
    profilesData.map((profile) async {
      try {
        final vm = await datasource.getMetrimonyProfileViewModel(profile['userId']);

        if (vm == null) return null;

        // Basic validation
        if (!vm.user.isProfileCreated) return null;

        // Optional: If you only want to show matches who have paid
        if (vm.user.agentId.isNotEmpty) {
          final payment = await paymentsRepository.getUserPayment(userId: vm.user.uid, agentId: vm.user.agentId);
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
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileMatchScreenState();
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
      final existing = await repo.fetchRecommendedProfiles(widget.profile.user.uid);
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
        SnackBar(
          content: Text(context.l10n.profileAlreadyRecommended),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
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
          content: Text(success ? context.l10n.profileRecommendedSuccessfully : context.l10n.failedToRecommendProfile),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeRecommendation(MetrimonyProfileViewModel match) async {
    final repo = ref.read(userRecemmondedRepositoryProvider);

    // Perform mutual recommendation removal using the repository's batch update method
    final success = await repo.removeMutualRecommendedProfiles(sourceUid: widget.profile.user.uid, targetUid: match.user.uid);

    if (mounted) {
      if (success) {
        setState(() {
          _recommendedProfiles!.ids.remove(match.user.uid);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? context.l10n.recommendationRemovedSuccessfully : context.l10n.failedToRemoveRecommendation),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProfilesAsync = ref.watch(allProfilesProvider);
    final locationAsync = ref.watch(locationJsonProvider);
    final religionsAsync = ref.watch(religionsProvider);

    // Prevent LateInitializationError by checking if data is loaded
    if (_recommendedProfiles == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final sourceGender = widget.profile.identity.gender.en.toLowerCase();
    final targetGender = sourceGender == 'male' ? 'female' : 'male';
    final sourceReligion = _normalize(widget.profile.cultural.religion.en);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.suggestedMatches),
        backgroundColor: theme.primaryColor,
        // foregroundColor: theme.colorScheme.onPrimary,
        // ── SEARCH BAR pinned inside AppBar bottom ──────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: context.l10n.searchMatchHint,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.8), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.white.withValues(alpha: 0.8)),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white, width: 1.5),
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
            final isOppositeGender = p.identity.gender.en.toLowerCase() == targetGender;
            final isNotSelf = p.user.uid != widget.profile.user.uid;
            if (!isOppositeGender || !isNotSelf) return false;

            final sameReligion = sourceReligion.isNotEmpty && _normalize(p.cultural.religion.en) == sourceReligion;

            return sameReligion;
          }).toList();

          // ── 2. Search filter ────────────────────────────────
          final q = _normalize(_searchQuery);
          final filtered = q.isEmpty
              ? matches
              : matches.where((p) {
                  return _normalize(p.user.fullName.en).contains(q) ||
                      // _normalize(p.cultural.caste.en).contains(q) ||
                      _normalize(p.cultural.religion.en).contains(q) ||
                      _normalize(p.address.city.en).contains(q) ||
                      _normalize(p.address.state.en).contains(q);
                }).toList();

          if (matches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.noMatchingReligionProfiles, textAlign: TextAlign.center),
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
                    Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.noResultsFor(_searchQuery),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _searchController.clear(),
                      icon: const Icon(Icons.clear),
                      label: Text(context.l10n.clearSearch),
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
                        context.l10n.matchesFor(widget.profile.user.fullName.en),
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        q.isEmpty
                            ? '${filtered.length} ${filtered.length != 1 ? context.l10n.matches : context.l10n.match}'
                            : '${filtered.length} / ${matches.length}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.primaryColor),
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

                    String resolvedCity = match.address.city.en;
                    String resolvedReligion = match.cultural.religion.en;
                    String resolvedCaste = match.cultural.caste.en;

                    if (locationAsync.hasValue) {
                      final states = locationAsync.value!;
                      final stateObj = states.where((s) => s.name == match.address.state).firstOrNull;
                      if (stateObj != null) {
                        final cityObj = stateObj.cities
                            .where((c) => c.id == match.address.city || c.name == match.address.city)
                            .firstOrNull;
                        if (cityObj != null) {
                          resolvedCity = cityObj.name;
                        }
                      }
                    }

                    if (religionsAsync.hasValue) {
                      final religions = religionsAsync.value!;
                      final religionObj = religions
                          .where((r) => r.id == match.cultural.religion || r.name == match.cultural.religion)
                          .firstOrNull;
                      if (religionObj != null) {
                        resolvedReligion = religionObj.name;
                        final casteObj = religionObj.castes
                            .where((c) => c.id == match.cultural.caste || c.name == match.cultural.caste)
                            .firstOrNull;
                        if (casteObj != null) {
                          resolvedCaste = casteObj.name;
                        }
                      }
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          _recommendedProfiles!.ids.contains(match.user.uid) ? _removeRecommendation(match) : _recommendProfile(match),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// IMAGE
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: SizedBox(
                                height: 240,
                                width: double.infinity,
                                child: match.images.primaryImageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: match.images.primaryImageUrl,
                                        fit: BoxFit.cover,
                                        memCacheWidth: 600,
                                        memCacheHeight: 600,
                                        maxWidthDiskCache: 800,
                                        maxHeightDiskCache: 800,
                                        fadeInDuration: const Duration(milliseconds: 200),
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey.shade100,
                                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                        ),
                                      )
                                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 80)),
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
                                      Expanded(child: BilingualParser(value: match.user.fullName)),

                                      if (_recommendedProfiles!.ids.contains(match.user.uid))
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(30)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                context.l10n.recommended,
                                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
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
                                      _infoChip(Icons.cake, '${match.identity.age} ${context.l10n.years}'),

                                      _infoChip(Icons.temple_hindu, resolvedReligion),

                                      _infoChip(Icons.people, resolvedCaste),

                                      _infoChip(Icons.location_on, resolvedCity),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  /// BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _recommendedProfiles!.ids.contains(match.user.uid)
                                          ? _removeRecommendation(match)
                                          : _recommendProfile(match),
                                      icon: Icon(
                                        _recommendedProfiles!.ids.contains(match.user.uid) ? Icons.favorite_border : Icons.favorite,
                                      ),
                                      label: Text(
                                        _recommendedProfiles!.ids.contains(match.user.uid)
                                            ? context.l10n.removeRecommendation
                                            : context.l10n.recommendProfile,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _recommendedProfiles!.ids.contains(match.user.uid)
                                            ? Colors.red.shade400
                                            : theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.pushRoute(ViewUserRoute(userId: match.user.uid, showMatchButton: false)),
                                      icon: const Icon(Icons.person_outline),
                                      label: Text(context.l10n.viewFullProfile),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
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
