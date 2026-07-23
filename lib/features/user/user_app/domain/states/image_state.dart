class ProfileImages {
  final String primaryImageUrl;
  final List<String> secondaryImageUrls;
  final String aadharCardUrl;
  final String imageWithAgentUrl;
  final String profileImageUrl;
  final String bioDataUrl;

  const ProfileImages({
    required this.primaryImageUrl,
    required this.secondaryImageUrls,
    required this.aadharCardUrl,
    required this.imageWithAgentUrl,
    required this.profileImageUrl,
    required this.bioDataUrl,
  });

  factory ProfileImages.empty() {
    return const ProfileImages(
      imageWithAgentUrl: '',

      primaryImageUrl: '',
      profileImageUrl: '',

      aadharCardUrl: '',
      bioDataUrl: '',

      secondaryImageUrls: [],
    );
  }

  ProfileImages copyWith({
    String? primaryImageUrl,
    List<String>? secondaryImageUrls,
    String? imageWithAgentUrl,
    String? aadharCardUrl,
    String? profileImageUrl,
    String? bioDataUrl,
  }) {
    return ProfileImages(
      imageWithAgentUrl: imageWithAgentUrl ?? this.imageWithAgentUrl,
      aadharCardUrl: aadharCardUrl ?? this.aadharCardUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      secondaryImageUrls: secondaryImageUrls ?? this.secondaryImageUrls,
      bioDataUrl: bioDataUrl ?? this.bioDataUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryImageUrl': primaryImageUrl,
      'aadharCardUrl': aadharCardUrl,
      'imageWithAgentUrl': imageWithAgentUrl,
      'secondaryImageUrls': secondaryImageUrls,
      'profileImageUrl': profileImageUrl,
      'bioDataUrl': bioDataUrl,
    };
  }

  factory ProfileImages.fromMap(Map<String, dynamic> map) {
    return ProfileImages(
      profileImageUrl: map['profileImageUrl'] ?? '',
      aadharCardUrl: map['aadharCardUrl'] ?? '',
      imageWithAgentUrl: map['imageWithAgentUrl'] ?? '',
      bioDataUrl: map['bioDataUrl'] ?? '',

      primaryImageUrl: map['primaryImageUrl'] ?? '',
      secondaryImageUrls: List<String>.from(map['secondaryImageUrls'] ?? []),
    );
  }

  @override
  String toString() =>
      'ProfileImages(primary: $primaryImageUrl, profile: $profileImageUrl,    gallery: $secondaryImageUrls , imageWithAgent: $imageWithAgentUrl, aadharCard: $aadharCardUrl, bioData: $bioDataUrl)';
}

class ImagesState {
  final String? primaryImage;
  final List<String> secondaryImages;
  final String? aadharPdfPath;
  final String? imageWithAgentUrl;
  final String? bioDataPath;

  final String? profileImage;

  const ImagesState({
    this.profileImage,
    this.primaryImage,
    this.aadharPdfPath,
    this.imageWithAgentUrl,
    this.bioDataPath,

    this.secondaryImages = const [],
  });

  factory ImagesState.initial() => const ImagesState();

  ImagesState copyWith({
    String? primaryImage,
    String? profileImage,
    List<String>? secondaryImages,
    String? imageWithAgentUrl,
    String? aadharPdfPath,
    String? bioDataPath,
  }) {
    return ImagesState(
      profileImage: profileImage ?? this.profileImage,

      imageWithAgentUrl: imageWithAgentUrl ?? this.imageWithAgentUrl,
      primaryImage: primaryImage ?? this.primaryImage,
      aadharPdfPath: aadharPdfPath ?? this.aadharPdfPath,
      secondaryImages: secondaryImages ?? this.secondaryImages,
      bioDataPath: bioDataPath ?? this.bioDataPath,
    );
  }
}
