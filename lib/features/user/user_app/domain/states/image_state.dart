class ProfileImages {
  final String primaryImageUrl;
  final List<String> secondaryImageUrls;
  final String aadharCardUrl;

  const ProfileImages({
    required this.primaryImageUrl,
    required this.secondaryImageUrls,
    required this.aadharCardUrl,
  });

  factory ProfileImages.empty() {
    return const ProfileImages(
      primaryImageUrl: '',

      aadharCardUrl: '',

      secondaryImageUrls: [],
    );
  }

  ProfileImages copyWith({
    String? primaryImageUrl,
    List<String>? secondaryImageUrls,
    String? aadharCardUrl,
  }) {
    return ProfileImages(
      aadharCardUrl: aadharCardUrl ?? this.aadharCardUrl,

      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      secondaryImageUrls: secondaryImageUrls ?? this.secondaryImageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryImageUrl': primaryImageUrl,
      'aadharCardUrl': aadharCardUrl,

      'secondaryImageUrls': secondaryImageUrls,
    };
  }

  factory ProfileImages.fromMap(Map<String, dynamic> map) {
    return ProfileImages(
      aadharCardUrl: map['aadharCardUrl'] ?? '',

      primaryImageUrl: map['primaryImageUrl'] ?? '',
      secondaryImageUrls: List<String>.from(map['secondaryImageUrls'] ?? []),
    );
  }

  @override
  String toString() =>
      'ProfileImages(primary: $primaryImageUrl, gallery: $secondaryImageUrls , aadhar: $aadharCardUrl)';
}

class ImagesState {
  final String? primaryImage;
  final List<String> secondaryImages;
  final String? aadharPdfPath;

  const ImagesState({
    this.primaryImage,
    this.aadharPdfPath,

    this.secondaryImages = const [],
  });

  factory ImagesState.initial() => const ImagesState();

  ImagesState copyWith({
    String? primaryImage,
    List<String>? secondaryImages,
    String? aadharPdfPath,
  }) {
    return ImagesState(
      primaryImage: primaryImage ?? this.primaryImage,
      aadharPdfPath: aadharPdfPath ?? this.aadharPdfPath,
      secondaryImages: secondaryImages ?? this.secondaryImages,
    );
  }
}
