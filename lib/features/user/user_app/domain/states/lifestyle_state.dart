class LifestyleProfile {
  final String diet;
  final List<String> hobbies;
  final List<String> interests;
  final List<String> music;
  final List<String> movies;
  final List<String> sports;
  final String fitness;

  LifestyleProfile({
    required this.diet,

    required this.hobbies,
    required this.interests,
    required this.music,
    required this.movies,
    required this.sports,
    required this.fitness,
  });

  Map<String, dynamic> toMap() {
    return {
      'diet': diet,
      'hobbies': hobbies,
      'interests': interests,
      'music': music,
      'movies': movies,
      'sports': sports,
      'fitness': fitness,
    };
  }

  factory LifestyleProfile.fromMap(Map<String, dynamic> map) {
    return LifestyleProfile(
      diet: map['diet'] ?? '',
      hobbies: List<String>.from(map['hobbies'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      music: List<String>.from(map['music'] ?? []),
      movies: List<String>.from(map['movies'] ?? []),
      sports: List<String>.from(map['sports'] ?? []),
      fitness: map['fitness'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LifestyleProfile(diet: $diet, hobbies: $hobbies, interests: $interests, music: $music, movies: $movies, sports: $sports, fitness: $fitness)';
  }

  LifestyleProfile copyWith({
    String? diet,
    List<String>? hobbies,
    List<String>? interests,
    List<String>? music,
    List<String>? movies,
    List<String>? sports,
    String? fitness,
  }) {
    return LifestyleProfile(
      diet: diet ?? this.diet,
      hobbies: hobbies ?? this.hobbies,
      interests: interests ?? this.interests,
      music: music ?? this.music,
      movies: movies ?? this.movies,
      sports: sports ?? this.sports,
      fitness: fitness ?? this.fitness,
    );
  }

  factory LifestyleProfile.empty() {
    return LifestyleProfile(
      diet: '',
      hobbies: [],
      interests: [],
      music: [],
      movies: [],
      sports: [],
      fitness: '',
    );
  }
}

class LifestyleState {
  final LifestyleProfile? lifestyle;
  final bool isLoading;
  final String? error;

  const LifestyleState({this.lifestyle, this.isLoading = false, this.error});

  LifestyleState copyWith({
    LifestyleProfile? lifestyle,
    bool? isLoading,
    String? error,
  }) {
    return LifestyleState(
      lifestyle: lifestyle ?? this.lifestyle,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = LifestyleState(
    lifestyle: null,
    isLoading: false,
    error: null,
  );
}
