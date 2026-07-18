import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';

import '../../../../l10n/l10n_helper.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../../../user/user_app/domain/states/image_state.dart';
import '../../../../user/user_app/domain/states/metrimony_profile_view_model.dart';
import '../../../../user/user_app/domain/states/religion_state.dart';
import '../../../../user/user_app/domain/states/state_city.dart';
import '../../../../user/user_app/widgets/pdf_viewer_bottomsheet.dart';
import '../notifier/metrimony_notifier.dart';

@RoutePage()
class MetrimonyProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const MetrimonyProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewMetrimonyProfileScreenState();
}

class _ViewMetrimonyProfileScreenState
    extends ConsumerState<MetrimonyProfileScreen> {
  @override
  void initState() {
    super.initState();
    // If you want fresh data every time the screen is entered,
    // invalidate is fine. However, watch() will trigger the fetch
    // automatically if not already loaded. If you need a manual refresh,
    // consider adding a RefreshIndicator to the UI instead of
    // invalidating on every initState.
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationJsonProvider);
    final religionsAsync = ref.watch(religionsProvider);
    final profileAsync = ref.watch(
      matrimonyProfileViewModelProvider(widget.userId),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],

      bottomNavigationBar: profileAsync.maybeWhen(
        data: (profile) {
          if (profile == null) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                context.router.push(ProfileMatchRoute(profile: profile));
              },
              icon: const Icon(Icons.search),
              label: Text(context.l10n.matchProfiles),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
        orElse: () => const SizedBox(),
      ),

      appBar: AppBar(
        title: Text(context.l10n.matrimonyProfile),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                context.l10n.errorLoadingUser,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(
                    matrimonyProfileViewModelProvider(widget.userId),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(context.l10n.matrimonyProfileNotCreatedYet),
                ],
              ),
            );
          }

          String resolvedState = profile.address.state.en;
          String resolvedCity = profile.address.city.en;
          String resolvedReligion = profile.cultural.religion.en;
          String resolvedCaste = profile.cultural.caste.en;

          if (locationAsync.hasValue) {
            final states = locationAsync.value!;
            final stateObj = states
                .where((s) => s.name == profile.address.state)
                .firstOrNull;
            if (stateObj != null) {
              resolvedState = stateObj.name;
              final cityObj = stateObj.cities
                  .where(
                    (c) =>
                        c.id == profile.address.city ||
                        c.name == profile.address.city,
                  )
                  .firstOrNull;
              if (cityObj != null) {
                resolvedCity = cityObj.name;
              }
            }
          }

          if (religionsAsync.hasValue) {
            final religions = religionsAsync.value!;
            final religionObj = religions
                .where(
                  (r) =>
                      r.id == profile.cultural.religion ||
                      r.name == profile.cultural.religion,
                )
                .firstOrNull;
            if (religionObj != null) {
              resolvedReligion = religionObj.name;
              final casteObj = religionObj.castes
                  .where(
                    (c) =>
                        c.id == profile.cultural.caste ||
                        c.name == profile.cultural.caste,
                  )
                  .firstOrNull;
              if (casteObj != null) {
                resolvedCaste = casteObj.name;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Basic Info Card
                _UserInfoCard(profile: profile),
                const SizedBox(height: 16),

                // Identity Section
                _SectionCard(
                  title: context.l10n.identityInformation,
                  icon: Icons.person,
                  children: [
                    _InfoRow(
                      context.l10n.fullName,
                      profile.user.fullName,
                    ),
                    _InfoRow(
                      context.l10n.dateOfBirth,
                      profile.identity.dob.toLocal().toString().split(' ')[0],
                    ),
                    _InfoRow(
                      context.l10n.age,
                      context.l10n.yearsOld(profile.identity.age),
                    ),
                    _InfoRow(context.l10n.gender, profile.identity.gender),
                    _InfoRow(
                      context.l10n.aadharNumber,
                      profile.identity.aadhar,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Physical Section
                _SectionCard(
                  title: context.l10n.physicalInformation,
                  icon: Icons.accessibility,
                  children: [
                    _InfoRow(
                      context.l10n.height,
                      '${profile.physical.height} cm',
                    ),
                    _InfoRow(
                      context.l10n.weightKg,
                      '${profile.physical.weight} kg',
                    ),
                    _InfoRow(context.l10n.bodyType, profile.physical.bodyType),
                    _InfoRow(
                      context.l10n.complexion,
                      profile.physical.complexion,
                    ),
                    _InfoRow(
                      context.l10n.physicallyChallenged,
                      profile.physical.physicallyChallenged
                          ? context.l10n.yesLabel
                          : context.l10n.noLabel,
                    ),
                    if (profile.physical.disabilityDetails != null)
                      _InfoRow(
                        context.l10n.disabilityDetails,
                        profile.physical.disabilityDetails ?? '',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cultural Section
                _SectionCard(
                  title: context.l10n.culturalInformation,
                  icon: Icons.temple_hindu,
                  children: [
                    _InfoRow(context.l10n.religion, resolvedReligion),
                    _InfoRow(context.l10n.caste, resolvedCaste),
                    _InfoRow(
                      context.l10n.subCaste,
                      profile.cultural.subCaste as String,
                    ),
                    _InfoRow(
                      context.l10n.languages,
                      profile.cultural.languages.join(', '),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Education Section
                _SectionCard(
                  title: context.l10n.education,
                  icon: Icons.school,
                  children: [
                    _InfoRow(
                      context.l10n.isIlliterate,
                      profile.education.isIlletrate
                          ? context.l10n.yesLabel
                          : context.l10n.noLabel,
                    ),
                    if (!profile.education.isIlletrate &&
                        profile.education.education != null) ...[
                      _InfoRow(
                        context.l10n.course,
                        profile.education.education!.course  ,
                      ),
                      _InfoRow(
                        context.l10n.collegeUniversity,
                        profile.education.education!.college as String,
                      ),
                      _InfoRow(
                        context.l10n.passingYear,
                        '${profile.education.education!.passingYear}',
                      ),
                      _InfoRow(
                        context.l10n.percentage,
                        '${profile.education.education!.percentage}%',
                      ),
                    ],
                    if (profile.education.extraQualification != null &&
                        profile
                            .education
                            .extraQualification!
                            .qualifications
                            .isNotEmpty)
                      _InfoRow(
                        context.l10n.extraQualifications,
                        profile.education.extraQualification!.qualifications
                            .join(', '),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Employment Section
                _SectionCard(
                  title: context.l10n.employmentDetails,
                  icon: Icons.work,
                  children: [
                    _InfoRow(context.l10n.jobType, profile.employment.jobType),
                    if (profile.employment.company != null)
                      _InfoRow(
                        context.l10n.organization,
                        profile.employment.company,
                      ),
                    if (profile.employment.designation != null)
                      _InfoRow(
                        context.l10n.designation,
                        profile.employment.designation ?? '',
                      ),
                    if (profile.employment.annualIncome != null)
                      _InfoRow(
                        context.l10n.annualIncome,
                        '₹${profile.employment.annualIncome}',
                      ),
                    if (profile.employment.workLocation != null)
                      _InfoRow(
                        context.l10n.workLocation,
                        profile.employment.workLocation ?? '',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Family Section
                _SectionCard(
                  title: context.l10n.familyInformation,
                  icon: Icons.family_restroom,
                  children: [
                    _InfoRow(
                      context.l10n.fatherName,
                      profile.family.fatherName,
                    ),
                    _InfoRow(
                      context.l10n.motherName,
                      profile.family.motherName,
                    ),
                    _InfoRow(
                      context.l10n.numberOfBrothers,
                      '${profile.family.numberOfBrothers}',
                    ),
                    _InfoRow(
                      context.l10n.numberOfSisters,
                      '${profile.family.numberOfSisters}',
                    ),
                    _InfoRow(
                      context.l10n.familyType,
                      profile.family.familyType,
                    ),
                    _InfoRow(
                      context.l10n.familyStatus,
                      profile.family.familyStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Address Section
                _SectionCard(
                  title: context.l10n.address,
                  icon: Icons.location_on,
                  children: [
                    _InfoRow(
                      context.l10n.address,
                      profile.address.addressLine1,
                    ),
                    _InfoRow(context.l10n.post, profile.address.post),
                    _InfoRow(
                      context.l10n.policeStation,
                      profile.address.policeStation,
                    ),
                    _InfoRow(context.l10n.city, resolvedCity),
                    _InfoRow(context.l10n.state, resolvedState),
                    _InfoRow(context.l10n.pincode, profile.address.pincode),
                  ],
                ),

                const SizedBox(height: 16),
                if (profile.agentEntity != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _SectionCard(
                      title: context.l10n.agentInformation,
                      icon: Icons.support_agent,
                      children: [
                        _InfoRow(
                          context.l10n.agentName,
                          profile.agentEntity!.agentName,
                        ),
                        _InfoRow(
                          context.l10n.phone,
                          profile.agentEntity!.agentMobile,
                        ),
                        _InfoRow(
                          context.l10n.email,
                          profile.agentEntity!.agentEmail,
                        ),
                        _InfoRow(
                          context.l10n.license,
                          profile.agentEntity!.agentLicenseNumber,
                        ),
                        _InfoRow(
                          context.l10n.city,
                          profile.agentEntity!.agentCity,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Images Section with Tabs
                _ImagesTabSection(images: profile.images),

                // Agent Info if available
              ],
            ),
          );
        },
      ),
    );
  }
}

// User Info Card Widget
class _UserInfoCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;

  const _UserInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: 'user-avatar-${profile.user.uid}',
              child: CircleAvatar(
                radius: 40,
                backgroundImage: profile.images.primaryImageUrl.isNotEmpty
                    ? NetworkImage(profile.images.primaryImageUrl)
                    : const NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/fir-app-e3a53.firebasestorage.app/o/company_files%2Ficon-7797704_640.png?alt=media&token=90d1d7fc-9dd9-4ab9-8dfc-480646f5777f",
                      ),
                // onBackgroundImageError: (_, __) {},
                child: profile.images.primaryImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 1)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BilingualParser(
                    value: profile.user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.yearsOld(profile.identity.age),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    profile.user.phone,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

// Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final String? textToDisplay;

  const _InfoRow(this.label, this.value, {this.textToDisplay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: value is BilingualValue
                ? BilingualParser(value: value as BilingualValue)
                : Text(value?.toString() ?? ''),
          ),
        ],
      ),
    );
  }
}

// Images Tab Section Widget
class _ImagesTabSection extends StatelessWidget {
  final ProfileImages images;

  const _ImagesTabSection({required this.images});

  @override
  Widget build(BuildContext context) {
    // Collect all available images with their labels
    final List<MapEntry<String, String>> allImages = [];

    if (images.primaryImageUrl.isNotEmpty) {
      allImages.add(
        MapEntry(context.l10n.primaryPhoto, images.primaryImageUrl),
      );
    }
    if (images.profileImageUrl.isNotEmpty) {
      allImages.add(
        MapEntry(context.l10n.profilePhoto, images.profileImageUrl),
      );
    }
    if (images.imageWithAgentUrl.isNotEmpty) {
      allImages.add(
        MapEntry(context.l10n.photoWithAgent, images.imageWithAgentUrl),
      );
    }

    // Add all secondary images
    for (int i = 0; i < images.secondaryImageUrls.length; i++) {
      allImages.add(
        MapEntry(
          '${context.l10n.gallery} ${i + 1}',
          images.secondaryImageUrls[i],
        ),
      );
    }

    final hasAadhar = images.aadharCardUrl.isNotEmpty;

    if (allImages.isEmpty && !hasAadhar) {
      return const SizedBox.shrink();
    }

    final tabCount = allImages.length + (hasAadhar ? 1 : 0);

    return DefaultTabController(
      length: tabCount,
      key: ValueKey('tabs_$tabCount'),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.photosAndDocuments,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Tab Bar
              TabBar(
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: [
                  ...allImages.map((entry) => Tab(text: entry.key)),
                  if (images.aadharCardUrl.isNotEmpty)
                    Tab(text: context.l10n.aadharCard),
                ],
              ),

              // Tab Bar View
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    // Image tabs
                    ...allImages.map(
                      (entry) =>
                          _ImageViewer(imageUrl: entry.value, label: entry.key),
                    ),

                    // // Aadhar card tab
                    // if (images.aadharCardUrl.isNotEmpty)
                    _DocumentViewer(
                      documentUrl: images.aadharCardUrl,
                      label: context.l10n.aadharCard,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  final String label;

  const _ImageError({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 56,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              '${label} ${context.l10n.notAvailable}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Image Viewer Widget
class _ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _ImageViewer({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _ImageError(label: label);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openFullscreen(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,

                  /// ✅ LOADING (VERY IMPORTANT)
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },

                  /// ✅ ERROR HANDLING
                  errorBuilder: (_, __, ___) => _ImageError(label: label),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.tapToViewFullscreen,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// FULLSCREEN VIEW
  void _openFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Document Viewer Widget (for PDFs like Aadhar)
class _DocumentViewer extends StatelessWidget {
  final String documentUrl;
  final String label;

  const _DocumentViewer({required this.documentUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    if (documentUrl.isEmpty) {
      return _ImageError(label: label);
    }

    final isPdf = documentUrl.toLowerCase().endsWith('.pdf');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf : Icons.image,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openDocument(context, isPdf),
            icon: const Icon(Icons.open_in_new),
            label: Text(
              isPdf ? context.l10n.openPdf : context.l10n.viewDocument,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _shortFileName(documentUrl),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openDocument(BuildContext context, bool isPdf) {
    if (isPdf) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PdfViewerBottomsheet(
          source: documentUrl,
          title: label,
          isLocal: false,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Image.network(
            documentUrl,
            errorBuilder: (_, __, ___) => _ImageError(label: label),
          ),
        ),
      );
    }
  }

  String _shortFileName(String url) {
    final name = url.split('/').last;
    return name.length > 30 ? '...${name.substring(name.length - 30)}' : name;
  }
}
