class ProfileImages {
  final String primaryImageUrl;
  final List<String> secondaryImageUrls;
  final String aadharCardUrl;
  final String imageWithAgentUrl;
  final String profileImageUrl;

  const ProfileImages({
    required this.primaryImageUrl,
    required this.secondaryImageUrls,
    required this.aadharCardUrl,
    required this.imageWithAgentUrl,
    required this.profileImageUrl,
  });

  factory ProfileImages.empty() {
    return const ProfileImages(
      imageWithAgentUrl: '',

      primaryImageUrl: '',
      profileImageUrl: '',

      aadharCardUrl: '',

      secondaryImageUrls: [],
    );
  }

  ProfileImages copyWith({
    String? primaryImageUrl,
    List<String>? secondaryImageUrls,
    String? imageWithAgentUrl,
    String? aadharCardUrl,
    String? profileImageUrl,
  }) {
    return ProfileImages(
      imageWithAgentUrl: imageWithAgentUrl ?? this.imageWithAgentUrl,
      aadharCardUrl: aadharCardUrl ?? this.aadharCardUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      secondaryImageUrls: secondaryImageUrls ?? this.secondaryImageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryImageUrl': primaryImageUrl,
      'aadharCardUrl': aadharCardUrl,
      'imageWithAgentUrl': imageWithAgentUrl,
      'secondaryImageUrls': secondaryImageUrls,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory ProfileImages.fromMap(Map<String, dynamic> map) {
    return ProfileImages(
      profileImageUrl: map['profileImageUrl'] ?? '',
      aadharCardUrl: map['aadharCardUrl'] ?? '',
      imageWithAgentUrl: map['imageWithAgentUrl'] ?? '',

      primaryImageUrl: map['primaryImageUrl'] ?? '',
      secondaryImageUrls: List<String>.from(map['secondaryImageUrls'] ?? []),
    );
  }

  @override
  String toString() =>
      'ProfileImages(primary: $primaryImageUrl, profile: $profileImageUrl,    gallery: $secondaryImageUrls , imageWithAgent: $imageWithAgentUrl, aadharCard: $aadharCardUrl)';
}

class ImagesState {
  final String? primaryImage;
  final List<String> secondaryImages;
  final String? aadharPdfPath;
  final String? imageWithAgentUrl;

  final String? profileImage;

  const ImagesState({
    this.profileImage,
    this.primaryImage,
    this.aadharPdfPath,
    this.imageWithAgentUrl,

    this.secondaryImages = const [],
  });

  factory ImagesState.initial() => const ImagesState();

  ImagesState copyWith({
    String? primaryImage,
    String? profileImage,
    List<String>? secondaryImages,
    String? imageWithAgentUrl,
    String? aadharPdfPath,
  }) {
    return ImagesState(
      profileImage: profileImage ?? this.profileImage,

      imageWithAgentUrl: imageWithAgentUrl ?? this.imageWithAgentUrl,
      primaryImage: primaryImage ?? this.primaryImage,
      aadharPdfPath: aadharPdfPath ?? this.aadharPdfPath,
      secondaryImages: secondaryImages ?? this.secondaryImages,
    );
  }
}
