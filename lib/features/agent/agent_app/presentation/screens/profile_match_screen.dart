import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/metrimony_notifier.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/user_nofier.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/user_recemmonded_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to fetch all matrimony profile view models
final allProfilesProvider = FutureProvider<List<MetrimonyProfileViewModel>>((
  ref,
) async {
  final datasource = ref.watch(metrimonyFirestoreDsProvider);
  final paymentsRepository = ref.watch(userPaymentsRepositoryProvider);
  final profilesData = await datasource.getAllMetrimonyProfiles();

  List<MetrimonyProfileViewModel> viewModels = [];
  for (var profile in profilesData) {
    try {
      final vm = await datasource.getMetrimonyProfileViewModel(
        profile['userId'],
      );
      if (!vm.user.isProfileCreated || vm.user.agentId.isEmpty) {
        continue;
      }

      final payment = await paymentsRepository.getUserPayment(
        userId: vm.user.uid,
        agentId: vm.user.agentId,
      );

      if (payment?.status.toUpperCase() == 'SUCCESS') {
        viewModels.add(vm);
      }
    } catch (e) {
      debugPrint('Error loading profile for match: $e');
    }
  }
  return viewModels;
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
  String _normalize(String value) => value.trim().toLowerCase();

  String _regionKey(MetrimonyProfileViewModel profile) {
    final state = _normalize(profile.address.state);
    if (state.isNotEmpty) return state;

    return _normalize(profile.address.city);
  }

  @override
  Widget build(BuildContext context) {
    final allProfilesAsync = ref.watch(allProfilesProvider);
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
                  final sameCaste =
                      sourceCaste.isNotEmpty &&
                      _normalize(p.cultural.caste) == sourceCaste;
                  final sameRegion =
                      sourceRegion.isNotEmpty && _regionKey(p) == sourceRegion;

                  return p.identity.gender.toLowerCase() == targetGender &&
                      p.user.isProfileCreated &&
                      p.user.uid != widget.profile.user.uid &&
                      sameCaste &&
                      sameRegion;
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              match.images.primaryImageUrl.isNotEmpty
                              ? NetworkImage(match.images.primaryImageUrl)
                              : null,
                          child: match.images.primaryImageUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          match.user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${match.identity.age} yrs • ${match.cultural.religion} • ${match.cultural.caste} • ${match.address.city}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final flag = UserRecemmondedRepository()
                              .updateRecommendedProfiles(
                                gender: widget.profile.userProfile.gender,
                                name: widget.profile.userProfile.fullName,
                                phone: widget.profile.userProfile.phone,
                                profileIds: [match.user.uid],
                                uid: widget.profile.user.uid,
                              );
                          debugPrint(
                            'Update recommended profiles result: $flag',
                          );
                          // show snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                await flag
                                    ? 'Recommended profile updated successfully!'
                                    : 'Failed to update recommended profile.',
                              ),
                              backgroundColor: await flag
                                  ? Colors.green
                                  : Colors.red,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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
}
