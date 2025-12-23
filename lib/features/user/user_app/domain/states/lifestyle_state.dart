class LifestyleProfile {
  final String diet;
  final String smoke;
  final String drink;
  final String hobbies;
  final String interests;
  final String music;
  final String movies;
  final String sports;
  final String fitness;

  LifestyleProfile({
    required this.diet,
    required this.smoke,
    required this.drink,
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
      'smoke': smoke,
      'drink': drink,
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
      diet: map['diet'] as String,
      smoke: map['smoke'] as String,
      drink: map['drink'] as String,
      hobbies: map['hobbies'] as String,
      interests: map['interests'] as String,
      music: map['music'] as String,
      movies: map['movies'] as String,
      sports: map['sports'] as String,
      fitness: map['fitness'] as String,
    );
  }

  @override
  String toString() {
    return 'LifestyleProfile(diet: $diet, smoke: $smoke, drink: $drink, hobbies: $hobbies, interests: $interests, music: $music, movies: $movies, sports: $sports, fitness: $fitness)';
  }

  LifestyleProfile copyWith({
    String? diet,
    String? smoke,
    String? drink,
    String? hobbies,
    String? interests,
    String? music,
    String? movies,
    String? sports,
    String? fitness,
  }) {
    return LifestyleProfile(
      diet: diet ?? this.diet,
      smoke: smoke ?? this.smoke,
      drink: drink ?? this.drink,
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
      smoke: '',
      drink: '',
      hobbies: '',
      interests: '',
      music: '',
      movies: '',
      sports: '',
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
