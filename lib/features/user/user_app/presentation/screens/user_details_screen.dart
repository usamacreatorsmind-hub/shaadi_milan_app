import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart'
    show agentFirestoreDsProvider;
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/agent_bottom_sheet.dart';
import 'package:arvika_marriage_bureau/features/user/user_auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../../app/custom/custom_widgets/carousel_slider.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/agent_state.dart';
import '../../domain/states/metrimony_state.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// read profile from firebase

final matrimonyProfileProvider =
    FutureProvider.family<MatrimonyProfileViewModel, String>((ref, uid) async {
      final matrimonyProfile = await ref
          .watch(matrimonyRepositoryProvider)
          .getMatrimonyProfile(uid);

      //  get user data using repository

      final userRepo = ref.watch(userRepositoryProvider);
      final user = await userRepo.fetchUser(uid);
      print("user");
      print(user.toString());

      AgentProfile? agent;
      if (matrimonyProfile.agentId.isNotEmpty) {
        agent = await ref
            .watch(agentFirestoreDsProvider)
            .fetchAgentByUid(matrimonyProfile.agentId);
      }
      print(agent);
      print(agent);
      return MatrimonyProfileViewModel(
        profile: matrimonyProfile,
        user: user,
        agent: agent,
      );
    });

@RoutePage()
class UserDetailScreen extends ConsumerStatefulWidget {
  final String uid;
  const UserDetailScreen({super.key, required this.uid});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull(
        'subject=Regarding Matrimony Profile&body=Hello Agent,',
      ),
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No email app found')));
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(matrimonyProfileProvider(widget.uid));

    return Scaffold(
      body: profileAsync.when(
        loading: () {
          print(" this is error");
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stackTrace) {
          print(" this is error");
          return Center(child: Text('Error: $err'));
        },
        data: (viewModel) {
          print(" this is use data");
          print(viewModel);

          final profile = viewModel.profile;
          final List<String> images = [
            if (profile.images.primaryImageUrl.isNotEmpty)
              profile.images.primaryImageUrl
            else
              'https://via.placeholder.com/150',

            ...(profile.images.secondaryImageUrls ?? []),
            if (profile.images.imageWithAgentUrl.isNotEmpty)
              profile.images.imageWithAgentUrl,
          ];

          return Stack(
            children: [
              DefaultTabController(
                length: 4,
                child: NestedScrollView(
                  floatHeaderSlivers: true,

                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.50,
                        backgroundColor: Colors.black,
                        flexibleSpace: FlexibleSpaceBar(
                          background: CustomCarouselSlider(imageUrls: images),
                        ),
                      ),

                      /// 🔒 FIXED HEADER (NO COLLAPSE, NO JUMP)
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
                        // APPLY THEME COLOR HERE
                        backgroundColor: Theme.of(context).canvasColor,

                        elevation: 0,

                        // 🔑 IMPORTANT
                        toolbarHeight: 120,
                        centerTitle: true,
                        collapsedHeight: 120,

                        expandedHeight: 120,

                        titleSpacing: 0,
                        title: ProfileHeaderCard(viewModel: viewModel),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _infoChip(
                                      profile.employment.jobType ?? '',
                                      Icons.work_outline,
                                    ),

                                    _infoChip(
                                      "${profile.identity.age} yrs",
                                      Icons.cake_outlined,
                                    ),
                                    _infoChip(
                                      profile.identity.gender ?? '',
                                      Icons.person_outline,
                                    ),
                                    _infoChip(
                                      profile.address.city ?? '',
                                      Icons.location_on_outlined,
                                    ),

                                    _infoChip(
                                      profile.cultural.religion ?? '',
                                      Icons.temple_hindu,
                                    ),

                                    _infoChip(
                                      "${profile.physical.height} cm" ?? '',
                                      Icons.height_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            labelColor: Theme.of(context).primaryColor,
                            tabAlignment: TabAlignment.center,
                            isScrollable: true,
                            indicatorColor: Colors.transparent,
                            unselectedLabelColor: Colors.grey,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            dividerColor: Colors.transparent,

                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: [
                              TabWidget(
                                label: 'Basic Info',
                                icon: Icons.person,
                              ),

                              TabWidget(
                                label: 'Personal Details',
                                icon: Icons.accessibility_new,
                              ),
                              TabWidget(
                                label: 'Education & Career',
                                icon: Icons.school,
                              ),
                              TabWidget(
                                label: 'Family & Culture',
                                icon: Icons.family_restroom,
                              ),
                              // TabWidget(
                              //   label: 'Agent Details',
                              //   icon: Icons.support_agent,
                              // ),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      // 1️⃣ BASIC INFO
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            _InfoCard(
                              title: 'Basic Information',
                              icon: Icons.person,
                              children: [
                                _InfoTile(
                                  label: 'Gender',
                                  icon: Icons.person_outline,
                                  value: profile.identity.gender,
                                ),
                                _InfoTile(
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  value: '${profile.identity.age} years',
                                ),
                                _InfoTile(
                                  label: 'Date of Birth',
                                  icon: Icons.calendar_today_outlined,
                                  value: DateFormat(
                                    'dd-MM-yyyy',
                                  ).format(profile.identity.dob),
                                ),
                              ],
                            ),

                            _InfoCard(
                              title: 'About Me',
                              icon: Icons.description,
                              children: const [
                                Text(
                                  textAlign: TextAlign.justify,
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  "I am a simple, caring, and family-oriented person. "
                                  "I believe in mutual respect, honesty, and understanding "
                                  "in a relationship.",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2️⃣ PERSONAL DETAILS
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            _InfoCard(
                              title: 'Physical',
                              icon: Icons.accessibility,
                              children: [
                                _InfoTile(
                                  label: 'Height',
                                  icon: Icons.height,
                                  value: profile.physical.height,
                                ),
                                _InfoTile(
                                  label: 'Weight',
                                  icon: Icons.scale,
                                  value: profile.physical.weight.toString(),
                                ),
                                _InfoTile(
                                  label: 'Body Type',
                                  icon: Icons.accessibility_new,
                                  value: profile.physical.bodyType,
                                ),
                              ],
                            ),

                            _InfoCard(
                              title: 'Address',
                              icon: Icons.location_on,
                              children: [
                                // show addrress tile wise
                                _InfoTile(
                                  label: 'Place of residence',
                                  icon: Icons.location_on_outlined,
                                  value: profile.address.addressLine1,
                                ),
                                _InfoTile(
                                  label: 'Post Office',

                                  icon: Icons.local_post_office_outlined,

                                  value: profile.address.post,
                                ),

                                _InfoTile(
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                  value: profile.address.city,
                                ),
                                _InfoTile(
                                  label: 'Police Station',

                                  icon: Icons.local_police_outlined,

                                  value: profile.address.policeStation,
                                ),

                                _InfoTile(
                                  label: 'State',
                                  icon: Icons.map_outlined,
                                  value: profile.address.state,
                                ),

                                _InfoTile(
                                  label: 'Pin Code',
                                  icon: Icons.local_post_office_outlined,
                                  value: profile.address.pincode,
                                ),

                                SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 3️⃣ EDUCATION & CAREER
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            _InfoCard(
                              title: 'Employment',
                              icon: Icons.work,
                              children: [
                                _InfoTile(
                                  label: 'Job Type',
                                  icon: Icons.work_outline,
                                  value: profile.employment.jobType,
                                ),
                                _InfoTile(
                                  label: 'Company',
                                  icon: Icons.business,
                                  value: profile.employment.company,
                                ),
                                _InfoTile(
                                  label: 'Designation',
                                  icon: Icons.work_history,
                                  value: profile.employment.designation,
                                ),
                                _InfoTile(
                                  label: 'Income',
                                  icon: Icons.attach_money,
                                  value: profile.employment.annualIncome
                                      .toString(),
                                ),

                                _InfoTile(
                                  label: 'Work Location',
                                  icon: Icons.location_city_outlined,
                                  value: profile.employment.workLocation
                                      .toString(),
                                ),
                              ],
                            ),

                            // ================= EDUCATION SECTION =================
                            if (profile.education.isIlletrate == true) ...[
                              _InfoCard(
                                title: 'Education',
                                icon: Icons.school_outlined,
                                children: const [
                                  _InfoTile(
                                    label: 'Education Status',
                                    icon: Icons.info_outline,
                                    value: 'Illiterate',
                                  ),
                                ],
                              ),
                            ] else if (profile.education.education != null ||
                                (profile
                                        .education
                                        .extraQualification
                                        ?.qualifications
                                        .isNotEmpty ??
                                    false)) ...[
                              _InfoCard(
                                title: 'Education',
                                icon: Icons.school_outlined,
                                children: [
                                  if (profile.education.education != null) ...[
                                    _InfoTile(
                                      label: 'College',
                                      icon: Icons.account_balance,
                                      value:
                                          profile.education.education!.college,
                                    ),
                                    _InfoTile(
                                      label: 'Course',
                                      icon: Icons.menu_book,
                                      value:
                                          profile.education.education!.course,
                                    ),
                                    _InfoTile(
                                      label: 'Percentage',
                                      icon: Icons.percent,
                                      value: profile
                                          .education
                                          .education!
                                          .percentage
                                          .toString(),
                                    ),
                                    _InfoTile(
                                      label: 'Passing Year',
                                      icon: Icons.calendar_today,
                                      value: profile
                                          .education
                                          .education!
                                          .passingYear
                                          .toString(),
                                    ),
                                  ],

                                  if (profile
                                          .education
                                          .extraQualification
                                          ?.qualifications
                                          .isNotEmpty ??
                                      false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Additional Courses',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(
                                                255,
                                                24,
                                                22,
                                                22,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 4.0,
                                            children: profile
                                                .education
                                                .extraQualification!
                                                .qualifications
                                                .map(
                                                  (course) =>
                                                      Chip(label: Text(course)),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 4️⃣ FAMILY & CULTURE
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            _InfoCard(
                              title: 'Family',
                              icon: Icons.family_restroom,
                              children: [
                                _InfoTile(
                                  label: 'Father',
                                  icon: Icons.person_outline,
                                  value: profile.family.fatherName,
                                ),
                                _InfoTile(
                                  label: 'Mother',
                                  icon: Icons.person_outline,
                                  value: profile.family.motherName,
                                ),
                                _InfoTile(
                                  label: 'Family Type',
                                  icon: Icons.family_restroom,
                                  value: profile.family.familyType,
                                ),
                                _InfoTile(
                                  label: 'No. of Brother',
                                  icon: Icons.people_outline,
                                  value: profile.family.numberOfBrothers
                                      .toString(),
                                ),

                                _InfoTile(
                                  label: 'No. of Sister',
                                  icon: Icons.people_outline,
                                  value: profile.family.numberOfSisters
                                      .toString(),
                                ),
                              ],
                            ),

                            _InfoCard(
                              title: 'Cultural',
                              icon: Icons.temple_hindu,
                              children: [
                                _InfoTile(
                                  label: 'Religion',
                                  icon: Icons.temple_hindu,
                                  value: profile.cultural.religion,
                                ),
                                _InfoTile(
                                  label: 'Caste',
                                  icon: Icons.group,
                                  value: profile.cultural.caste,
                                ),

                                _InfoTile(
                                  label: 'Caste',
                                  icon: Icons.group,
                                  value: profile.cultural.subCaste,
                                ),

                                _InfoTile(
                                  label: 'Languages',
                                  icon: Icons.language,
                                  value: profile.cultural.languages.join(', '),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 5️⃣ AGENT / VERIFICATION
                      // SingleChildScrollView(
                      //   padding: const EdgeInsets.only(bottom: 100),
                      //   child: Column(
                      //     children: [
                      //       if (viewModel.agent != null)
                      //         _InfoCard(
                      //           title: 'Agent Details',
                      //           icon: Icons.support_agent,
                      //           children: [
                      //             _InfoTile(
                      //               label: 'Name',
                      //               icon: Icons.person_outline,
                      //               value: viewModel.agent!.agentName,
                      //             ),
                      //             _InfoTile(
                      //               label: 'Mobile',
                      //               icon: Icons.phone,
                      //               value: viewModel.agent!.agentMobile,
                      //             ),
                      //             _InfoTile(
                      //               label: 'Email',
                      //               icon: Icons.email_outlined,
                      //               value: viewModel.agent!.email,
                      //             ),

                      //             _InfoTile(
                      //               label: 'Agent ID',
                      //               icon: Icons.perm_identity,
                      //               value: viewModel.agent!.agentId,
                      //             ),

                      //             _InfoTile(
                      //               label: 'Registered Date',
                      //               icon: Icons.calendar_today_outlined,
                      //               value: DateFormat(
                      //                 'dd-MM-yyyy',
                      //               ).format(viewModel.agent!.registrationDate),
                      //             ),
                      //           ],
                      //         ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.favorite_border),

                            label: const Text('Add to Wishlist'),

                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              backgroundColor: Theme.of(context).canvasColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // add this user's id to user collection 's current id or user

                              // read user colleciton and then push id of current profile to current logged in user
                              // Get the current user's UID
                              final currentUserId = ref
                                  .read(authRepositoryProvider)
                                  .currentUser
                                  ?.uid;
                              final profileId = viewModel.user?.uid;

                              if (currentUserId != null && profileId != null) {
                                // Add the profile's UID to the current user's wishlist

                                ref
                                    .read(userRepositoryProvider)
                                    .addWishlist(currentUserId, profileId);

                                // Optionally, show a success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to wishlist!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                // Handle case where current user is not logged in
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Something went wrong. Please try again later.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Contact Agent'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              backgroundColor: Theme.of(context).canvasColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // create botton sheet here

                              showAgentBottomSheet(context, viewModel.agent!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showAgentBottomSheet(BuildContext context, AgentProfile agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AgentBottomSheet(agent: agent),
    );
  }

  Widget _infoTile(IconData icon, String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class TabWidget extends StatelessWidget {
  final String label;
  final IconData icon;

  const TabWidget({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: SizedBox(
        height: 32, // control tab height
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
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

// ================= HELPERS =================

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

Widget _infoChip(String value, IconData icon) {
  if (value.isEmpty || value == 'N/A') return const SizedBox.shrink();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.redAccent),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,

      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: BoxBorder.fromLTRB(
          left:
              // always apply them color
              BorderSide(color: Theme.of(context).primaryColor, width: 4),
        ),
        borderRadius: BorderRadius.circular(20),
        // gradient: LinearGradient(
        //   colors: [Colors.white, Colors.white.withOpacity(0.95)],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Icon(icon, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),

          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),

              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  final MatrimonyProfileViewModel viewModel;

  const ProfileHeaderCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = viewModel.profile;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        // apply same colors a sliveer app bar color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME + VERIFIED
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  viewModel.user?.fullName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,

                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // AGE + OCCUPATION
          Text(
            '${profile.identity.age ?? 'N/A'} yrs, ${profile.employment.designation ?? 'N/A'}',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 8),

          // LOCATION
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${profile.address.city ?? 'N/A'}, ${profile.address.state ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // // DIVIDER (VERY IMPORTANT FOR VISUAL SEPARATION)
          // Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
