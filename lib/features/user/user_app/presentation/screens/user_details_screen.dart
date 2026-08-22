import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import 'package:shadi_milan/features/auth/domain/states/user_state.dart';
import 'package:shadi_milan/features/auth/presentation/providers/auth_providers.dart';
import 'package:shadi_milan/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart' show agentFirestoreDsProvider;
import 'package:shadi_milan/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:shadi_milan/features/user/user_app/widgets/agent_bottom_sheet.dart';
import 'package:shadi_milan/features/user/user_app/presentation/widgets/premium_upgrade_bottom_sheet.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/carousel_slider.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../../user_razorpay/domain/states/payment.dart';
import '../../../user_razorpay/presentation/notifier/payment_notifier.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/image_state.dart';
import '../../domain/states/metrimony_state.dart';

// read profile from firebase

final matrimonyProfileProvider = FutureProvider.family<MatrimonyProfileViewModel, String>((ref, uid) async {
  final matrimonyProfile = await ref.watch(matrimonyRepositoryProvider).getMatrimonyProfile(uid);

  //  get user data using repository

  final userRepo = ref.watch(userRepositoryProvider);
  final user = await userRepo.fetchUser(uid);

  AgentEntity? agent;
  if (user.agentId.isNotEmpty) {
    agent = await ref.watch(agentFirestoreDsProvider).fetchAgentByUid(user.agentId);
  }
  return MatrimonyProfileViewModel(profile: matrimonyProfile, user: user, agent: agent);
});

@RoutePage()
class UserDetailScreen extends ConsumerStatefulWidget {
  final String uid;

  const UserDetailScreen({super.key, required this.uid});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  List<String> _buildDisplayImages(ProfileImages profileImages) {
    final rawImages = <String>[
      profileImages.primaryImageUrl,
      ...profileImages.secondaryImageUrls,
      profileImages.profileImageUrl,
      profileImages.imageWithAgentUrl,
    ];

    final unique = <String>{};
    final cleaned = <String>[];
    for (final url in rawImages) {
      if (url.trim().isEmpty) continue;
      if (unique.add(url)) cleaned.add(url);
    }

    if (cleaned.isEmpty) {
      return [];
    }

    return cleaned;
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email, query: Uri.encodeFull('subject=Regarding Matrimony Profile&body=Hello Agent,'));

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email app found')));
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $phoneNumber')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(matrimonyProfileProvider(widget.uid));
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    String bText(BilingualValue val) {
      final text = isHindi ? val.hi : val.en;
      return text.isEmpty ? 'N/A' : text;
    }

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stackTrace) => Center(child: Text('Error: $err')),
        data: (viewModel) {
          final profile = viewModel.profile;
          final List<String> images = _buildDisplayImages(profile.images);

          return Stack(
            children: [
              NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.height * 0.65,
                      backgroundColor: Colors.black,
                      leading: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: 'user-image-${widget.uid}',
                              child: CustomCarouselSlider(imageUrls: images, height: MediaQuery.of(context).size.height * 0.65),
                            ),
                            const Positioned.fill(
                              child: IgnorePointer(
                                ignoring: true,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black38, Colors.transparent, Colors.transparent, Colors.black87],
                                      stops: [0.0, 0.2, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Removed redundant Wishlist Button on Image to match design
                            Positioned(
                              bottom: 24,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      BilingualParser(
                                        value: viewModel.user?.fullName ?? BilingualValue.empty(),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                                        ),
                                      ),
                                      Text(
                                        ', ${profile.identity.age}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final paymentState = ref.watch(paymentNotifierProvider(widget.uid));
                                          if (paymentState.status == PayStatus.success) {
                                            return const Icon(Icons.verified, color: Colors.blue, size: 24);
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${profile.physical.height} cm • ${bText(profile.cultural.caste)} • ${bText(profile.employment.designation ?? BilingualValue.empty())}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${bText(profile.address.city)}, ${bText(profile.address.state)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildStatusBadge(
                                        context,
                                        label: _timeAgo(viewModel.user?.lastSeen),
                                        icon: Icons.circle,
                                        iconColor: Colors.green,
                                        backgroundColor: Colors.black.withOpacity(0.3),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatusBadge(
                                        context,
                                        label: "You & Her",
                                        icon: Icons.people,
                                        iconColor: Colors.red,
                                        backgroundColor: Colors.black.withOpacity(0.3),
                                        textColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  _buildHighlightCard(
                                    context,
                                    Icons.height,
                                    AppLabels.height(context),
                                    _formatHeight(profile.physical.height.round()),
                                  ),
                                  _buildHighlightCard(
                                    context,
                                    Icons.temple_hindu,
                                    AppLabels.religion(context),
                                    bText(profile.cultural.religion),
                                  ),
                                  _buildHighlightCard(context, Icons.group, AppLabels.caste(context), bText(profile.cultural.caste)),
                                  _buildHighlightCard(context, Icons.work, AppLabels.jobType(context), bText(profile.employment.jobType)),
                                  if (profile.employment.annualIncome != null && bText(profile.employment.annualIncome!) != 'N/A')
                                    _buildHighlightCard(
                                      context,
                                      Icons.currency_rupee,
                                      AppLabels.annualIncome(context),
                                      bText(profile.employment.annualIncome!),
                                    ),
                                  _buildHighlightCard(
                                    context,
                                    Icons.school,
                                    AppLabels.education(context),
                                    profile.education.isIlletrate == true
                                        ? AppLabels.illiterate(context)
                                        : bText(profile.education.education?.course ?? BilingualValue.empty()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // 1️⃣ BASIC INFO
                      _InfoCard(
                        title: AppLabels.basicInformation(context),
                        icon: Icons.person,
                        children: [
                          _InfoTile(label: AppLabels.gender(context), icon: Icons.person_outline, bilingualValue: profile.identity.gender),
                          _InfoTile(
                            label: AppLabels.age(context),
                            icon: Icons.cake_outlined,
                            value: AppLabels.ageYears(context, profile.identity.age),
                          ),
                          _InfoTile(
                            label: AppLabels.dateOfBirth(context),
                            icon: Icons.calendar_today_outlined,
                            value: DateFormat('dd-MM-yyyy').format(profile.identity.dob),
                          ),
                        ],
                      ),

                      // 2️⃣ PHYSICAL & ADDRESS
                      _InfoCard(
                        title: AppLabels.physical(context),
                        icon: Icons.accessibility,
                        children: [
                          _InfoTile(
                            label: AppLabels.height(context),
                            icon: Icons.height,
                            value: _formatHeight(profile.physical.height.round()),
                          ),
                          _InfoTile(label: AppLabels.weightKg(context), icon: Icons.scale, value: "${profile.physical.weight.round()} kg"),
                          _InfoTile(
                            label: AppLabels.selectBodyType(context),
                            icon: Icons.accessibility_new,
                            bilingualValue: profile.physical.bodyType,
                          ),
                          if (profile.physical.physicallyChallenged)
                            _InfoTile(
                              label: AppLabels.disability(context),
                              icon: Icons.accessible,
                              value: AppLabels.yesLabel(context),
                              bilingualValue: profile.physical.disabilityDetails,
                            ),
                        ],
                      ),

                      _InfoCard(
                        title: AppLabels.address(context),
                        icon: Icons.location_on,
                        children: [
                          _InfoTile(
                            label: AppLabels.city(context),
                            icon: Icons.location_city_outlined,
                            bilingualValue: profile.address.city,
                          ),
                          _InfoTile(label: AppLabels.state(context), icon: Icons.map_outlined, bilingualValue: profile.address.state),
                        ],
                      ),

                      // 3️⃣ EDUCATION & CAREER
                      _InfoCard(
                        title: AppLabels.employment(context),
                        icon: Icons.work,
                        isHighlighted: true,
                        children: [
                          _InfoTile(
                            label: AppLabels.jobType(context),
                            icon: Icons.work_outline,
                            bilingualValue: profile.employment.jobType,
                          ),
                          if (profile.employment.jobType.en != "Not Working" && profile.employment.jobType.hi != "Not Working") ...[
                            _InfoTile(
                              label: AppLabels.organization(context),
                              icon: Icons.business,
                              bilingualValue: profile.employment.company,
                            ),
                            _InfoTile(
                              label: AppLabels.designation(context),
                              icon: Icons.work_history,
                              bilingualValue: profile.employment.designation,
                            ),
                            _InfoTile(
                              label: AppLabels.annualIncome(context),
                              icon: Icons.attach_money,
                              bilingualValue: profile.employment.annualIncome,
                            ),
                            _InfoTile(
                              label: AppLabels.workLocation(context),
                              icon: Icons.location_city_outlined,
                              bilingualValue: profile.employment.workLocation,
                            ),
                          ],
                        ],
                      ),

                      if (profile.education.isIlletrate == true) ...[
                        _InfoCard(
                          title: AppLabels.education(context),
                          icon: Icons.school_outlined,
                          children: [
                            _InfoTile(
                              label: AppLabels.educationStatus(context),
                              icon: Icons.info_outline,
                              value: AppLabels.illiterate(context),
                            ),
                          ],
                        ),
                      ] else if (profile.education.education != null ||
                          (profile.education.extraQualification?.qualifications.isNotEmpty ?? false)) ...[
                        _InfoCard(
                          title: AppLabels.education(context),
                          icon: Icons.school_outlined,
                          children: [
                            if (profile.education.education != null) ...[
                              _InfoTile(
                                label: AppLabels.college(context),
                                icon: Icons.account_balance,
                                bilingualValue: profile.education.education!.college,
                              ),
                              _InfoTile(
                                label: AppLabels.course(context),
                                icon: Icons.menu_book,
                                bilingualValue: profile.education.education!.course,
                              ),
                            ],

                            if (profile.education.extraQualification?.qualifications.isNotEmpty ?? false)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLabels.additionalCourses(context),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: profile.education.extraQualification!.qualifications
                                          .map(
                                            (course) => Chip(
                                              label: BilingualParser(value: course, style: const TextStyle(fontSize: 12)),
                                              backgroundColor: theme.primaryColor.withOpacity(0.05),
                                              side: BorderSide(color: theme.primaryColor.withOpacity(0.1)),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],

                      // 4️⃣ FAMILY & CULTURE
                      _InfoCard(
                        title: AppLabels.familyDetails(context),
                        icon: Icons.family_restroom,
                        children: [
                          _InfoTile(
                            label: AppLabels.father(context),
                            icon: Icons.person_outline,
                            bilingualValue: profile.family.fatherName,
                          ),
                          _InfoTile(
                            label: AppLabels.mother(context),
                            icon: Icons.person_outline,
                            bilingualValue: profile.family.motherName,
                          ),
                          _InfoTile(
                            label: AppLabels.familyType(context),
                            icon: Icons.family_restroom,
                            bilingualValue: profile.family.familyType,
                          ),
                          _InfoTile(
                            label: AppLabels.numberOfBrothers(context),
                            icon: Icons.people_outline,
                            value: profile.family.numberOfBrothers.toString(),
                          ),
                          _InfoTile(
                            label: AppLabels.numberOfSisters(context),
                            icon: Icons.people_outline,
                            value: profile.family.numberOfSisters.toString(),
                          ),
                        ],
                      ),

                      _InfoCard(
                        title: AppLabels.cultural(context),
                        icon: Icons.temple_hindu,
                        children: [
                          _InfoTile(
                            label: AppLabels.religion(context),
                            icon: Icons.temple_hindu,
                            bilingualValue: profile.cultural.religion,
                          ),
                          _InfoTile(label: AppLabels.caste(context), icon: Icons.group, bilingualValue: profile.cultural.caste),
                          _InfoTile(
                            label: AppLabels.languagesKnown(context),
                            icon: Icons.language,
                            value: profile.cultural.languages.map((l) => isHindi ? l.hi : l.en).join(', '),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    children: [
                      // 1. Chat Button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.chat_bubble_rounded,
                          label: "Chat",
                          backgroundColor: Colors.teal,
                          onTap: () {
                            final currentUserId = ref.read(authRepositoryProvider).currentUser?.uid;
                            if (currentUserId == null) return;
                            final paymentState = ref.read(paymentNotifierProvider(currentUserId));

                            if (paymentState.status == PayStatus.success) {
                              context.pushRoute(UserChatRoomRoute(peerId: viewModel.user!.uid));
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
                      ),

                      // 2. Wishlist Button
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final currentUserId = ref.watch(authRepositoryProvider).currentUser?.uid;
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
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from Wishlist')));
                                      }
                                    } else {
                                      final currentUserData = await ref.read(userRepositoryProvider).fetchUser(currentUserId);
                                      final agentId = viewModel.user?.agentId ?? '';

                                      final wishListItem = WishlistEntity(
                                        senderId: currentUserId,
                                        receiverId: widget.uid,
                                        receiverAgent: agentId,
                                        senderAgent: currentUserData.agentId,
                                        status: "pending",
                                        updatedAt: DateTime.now(),
                                      );

                                      await wishlistRepo.addWishlist(wishListItem);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Wishlist')));
                                      }
                                    }
                                  },
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),

                      // 3. Call/Agent Button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.support_agent,
                          label: AppLabels.contactAgent(context),
                          backgroundColor: theme.primaryColor,
                          onTap: () {
                            if (viewModel.user!.agentId.isEmpty) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: 40.h,
                                    width: double.infinity,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          Text(
                                            AppLabels.noAgentAssociated(context),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            AppLabels.contactAdminDetails(context),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => _makePhoneCall("+919876543210"),
                                                    icon: const Icon(Icons.call),
                                                    label: Text(AppLabels.phone(context)),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Theme.of(context).primaryColor,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => _sendEmail(AppConstants.grievanceEmail),
                                                    icon: const Icon(Icons.email),
                                                    label: Text(AppLabels.mail(context)),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Theme.of(context).primaryColor,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              );
                            } else {
                              showAgentBottomSheet(context, viewModel.agent ?? AgentEntity.empty());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showAgentBottomSheet(BuildContext context, AgentEntity agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AgentBottomSheet(agent: agent),
    );
  }

  Widget _buildHighlightCard(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      label: Text(text, style: TextStyle(color: Theme.of(context).primaryColor)),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatHeight(int cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return '$cm cm ($feet\'$inches")';
  }

  Widget _buildStatusBadge(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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

// ================= HELPERS =================

class TabWidget extends StatelessWidget {
  final String label;
  final IconData icon;

  const TabWidget({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: SizedBox(
        height: 32,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isHighlighted;

  const _InfoCard({required this.title, required this.icon, required this.children, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? theme.primaryColor.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isHighlighted ? theme.primaryColor.withValues(alpha: 0.1) : Colors.transparent, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isHighlighted ? theme.primaryColor : Colors.black87),
                ),
                if (isHighlighted) ...[
                  const Spacer(),
                  Icon(Icons.auto_awesome_rounded, color: theme.primaryColor.withValues(alpha: 0.4), size: 18),
                ],
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final BilingualValue? bilingualValue;
  final IconData icon;
  final String? value;

  const _InfoTile({required this.label, this.value, this.bilingualValue, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600], fontSize: 14),
              ),
            ),
            Expanded(
              flex: 3,
              child: bilingualValue != null
                  ? BilingualParser(
                      value: bilingualValue!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
                    )
                  : Text(
                      value ?? 'N/A',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
