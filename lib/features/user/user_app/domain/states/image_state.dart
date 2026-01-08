class ProfileImages {
  final String primaryImageUrl;
  final List<String> secondaryImageUrls;
  final String aadharCardUrl;
  final String imageWithAgentUrl;

  const ProfileImages({
    required this.primaryImageUrl,
    required this.secondaryImageUrls,
    required this.aadharCardUrl,
    required this.imageWithAgentUrl,
  });

  factory ProfileImages.empty() {
    return const ProfileImages(
      imageWithAgentUrl: '',

      primaryImageUrl: '',

      aadharCardUrl: '',

      secondaryImageUrls: [],
    );
  }

  ProfileImages copyWith({
    String? primaryImageUrl,
    List<String>? secondaryImageUrls,
    String? imageWithAgentUrl,
    String? aadharCardUrl,
  }) {
    return ProfileImages(
      imageWithAgentUrl: imageWithAgentUrl ?? this.imageWithAgentUrl,
      aadharCardUrl: aadharCardUrl ?? this.aadharCardUrl,

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
    };
  }

  factory ProfileImages.fromMap(Map<String, dynamic> map) {
    return ProfileImages(
      aadharCardUrl: map['aadharCardUrl'] ?? '',
      imageWithAgentUrl: map['imageWithAgentUrl'] ?? '',

      primaryImageUrl: map['primaryImageUrl'] ?? '',
      secondaryImageUrls: List<String>.from(map['secondaryImageUrls'] ?? []),
    );
  }

  @override
  String toString() =>
      'ProfileImages(primary: $primaryImageUrl, gallery: $secondaryImageUrls , imageWithAgent: $imageWithAgentUrl, aadharCard: $aadharCardUrl)';
}

class ImagesState {
  final String? primaryImage;
  final List<String> secondaryImages;
  final String? aadharPdfPath;
  final String? imageWithAgentUrl;

  const ImagesState({
    this.primaryImage,
    this.aadharPdfPath,
    this.imageWithAgentUrl,

    this.secondaryImages = const [],
  });

  factory ImagesState.initial() => const ImagesState();

  ImagesState copyWith({
    String? primaryImage,
    List<String>? secondaryImages,
    String? imageWithAgentUrl,
    String? aadharPdfPath,
  }) {
    return ImagesState(
      imageWithAgentUrl: imageWithAgentUrl ?? this.imageWithAgentUrl,
      primaryImage: primaryImage ?? this.primaryImage,
      aadharPdfPath: aadharPdfPath ?? this.aadharPdfPath,
      secondaryImages: secondaryImages ?? this.secondaryImages,
    );
  }
}
