class ProfileImages {
  final String primaryImageUrl;
  final List<String> secondaryImageUrls;

  const ProfileImages({
    required this.primaryImageUrl,
    required this.secondaryImageUrls,
  });

  factory ProfileImages.empty() {
    return const ProfileImages(primaryImageUrl: '', secondaryImageUrls: []);
  }

  ProfileImages copyWith({
    String? primaryImageUrl,
    List<String>? secondaryImageUrls,
  }) {
    return ProfileImages(
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      secondaryImageUrls: secondaryImageUrls ?? this.secondaryImageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrls': secondaryImageUrls,
    };
  }

  factory ProfileImages.fromMap(Map<String, dynamic> map) {
    return ProfileImages(
      primaryImageUrl: map['primaryImageUrl'] ?? '',
      secondaryImageUrls: List<String>.from(map['secondaryImageUrls'] ?? []),
    );
  }

  @override
  String toString() =>
      'ProfileImages(primary: $primaryImageUrl, gallery: $secondaryImageUrls)';
}

class ImagesState {
  final String? primaryImage;
  final List<String> secondaryImages;

  const ImagesState({this.primaryImage, this.secondaryImages = const []});

  factory ImagesState.initial() => const ImagesState();

  ImagesState copyWith({String? primaryImage, List<String>? secondaryImages}) {
    return ImagesState(
      primaryImage: primaryImage ?? this.primaryImage,
      secondaryImages: secondaryImages ?? this.secondaryImages,
    );
  }
}
