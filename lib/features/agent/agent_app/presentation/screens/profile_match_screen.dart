import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/metrimony_notifier.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/user_nofier.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/user_recemmonded_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/recemonded_profiles.dart';
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
  String _normalize(String value) => value.trim().toLowerCase();

  String _regionKey(MetrimonyProfileViewModel profile) {
    final state = _normalize(profile.address.state);
    if (state.isNotEmpty) return state;

    return _normalize(profile.address.city);
  }

  @override
  void initState() {
    super.initState();
    _loadExistingRecommendations();
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
    final sourceCaste = _normalize(widget.profile.cultural.caste);
    final sourceRegion = _regionKey(widget.profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Matches'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Showing matches for ${widget.profile.user.fullName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: allProfilesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (profiles) {
                final matches = profiles.where((p) {
                  // Basic requirements
                  final isOppositeGender =
                      p.identity.gender.toLowerCase() == targetGender;
                  final isNotSelf = p.user.uid != widget.profile.user.uid;

                  if (!isOppositeGender || !isNotSelf) return false;

                  // Loosen filters: Match if same caste OR same region
                  final sameCaste =
                      sourceCaste.isNotEmpty &&
                      _normalize(p.cultural.caste) == sourceCaste;
                  final sameRegion =
                      sourceRegion.isNotEmpty && _regionKey(p) == sourceRegion;

                  // Return true if it's a potential match (you can adjust priority later)
                  return sameCaste || sameRegion;
                }).toList();

                if (matches.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching profiles found for the same caste and region.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        if (_recommendedProfiles!.ids.contains(
                          match.user.uid,
                        )) {
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

                        final repo = ref.read(
                          userRecemmondedRepositoryProvider,
                        );

                        final success = await repo.updateRecommendedProfiles(
                          gender: widget.profile.identity.gender,
                          name: widget.profile.user.fullName,
                          phone: widget.profile.user.phone,
                          profileIds: [match.user.uid],
                          uid: widget.profile.user.uid,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Recommended profile updated successfully!'
                                    : 'Failed to update recommended profile.',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
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
                                      onPressed:
                                          _recommendedProfiles!.ids.contains(
                                            match.user.uid,
                                          )
                                          ? null
                                          : () async {
                                              final repo = ref.read(
                                                userRecemmondedRepositoryProvider,
                                              );

                                              final success = await repo
                                                  .updateRecommendedProfiles(
                                                    gender: widget
                                                        .profile
                                                        .identity
                                                        .gender,
                                                    name: widget
                                                        .profile
                                                        .user
                                                        .fullName,
                                                    phone: widget
                                                        .profile
                                                        .user
                                                        .phone,
                                                    profileIds: [
                                                      match.user.uid,
                                                    ],
                                                    uid:
                                                        widget.profile.user.uid,
                                                  );

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      success
                                                          ? 'Profile Recommended Successfully'
                                                          : 'Failed to Recommend Profile',
                                                    ),
                                                    backgroundColor: success
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                      icon: const Icon(Icons.favorite),
                                      label: Text(
                                        _recommendedProfiles!.ids.contains(
                                              match.user.uid,
                                            )
                                            ? 'Already Recommended'
                                            : 'Recommend Profile',
                                      ),
                                      style: ElevatedButton.styleFrom(
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

                                  SizedBox(
                                    height: 12,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.pushRoute(
                                          UserProfileRoute(
                                            userId: match.user.uid,
                                          ),
                                        );
                                      },
                                      child: const Text('View Full Profile'),
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
                );
              },
            ),
          ),
        ],
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
