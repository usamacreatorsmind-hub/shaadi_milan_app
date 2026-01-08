class AddressProfile {
  final String addressLine1;
  final String post;
  final String policeStation;
  final String city;
  final String state;
  final String pincode;

  AddressProfile({
    required this.addressLine1,
    required this.post,
    required this.city,
    required this.state,
    required this.policeStation,

    required this.pincode,
  });

  Map<String, dynamic> toMap() {
    return {
      'addressLine1': addressLine1,
      'post': post,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  factory AddressProfile.fromMap(Map<String, dynamic> map) {
    return AddressProfile(
      addressLine1: map['addressLine1'] ?? '',
      policeStation: map['policeStation'] ?? '',

      post: map['post'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
    );
  }

  AddressProfile copyWith({
    String? addressLine1,
    String? post,
    String? city,
    String? state,
    String? police_station,

    String? pincode,
    String? country,
  }) {
    return AddressProfile(
      addressLine1: addressLine1 ?? this.addressLine1,
      post: post ?? this.post,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,

      policeStation: police_station ?? policeStation,
    );
  }

  factory AddressProfile.empty() {
    return AddressProfile(
      addressLine1: '',
      post: '',
      city: '',
      state: '',
      policeStation: '',

      pincode: '',
    );
  }

  @override
  String toString() {
    return 'AddressProfile(addressLine1: $addressLine1, post: $post, city: $city, state: $state, pincode: $pincode, police_station: $policeStation)';
  }
}

class AddressState {
  final AddressProfile? address;
  final bool isLoading;
  final String? error;

  const AddressState({this.address, this.isLoading = false, this.error});

  AddressState copyWith({
    AddressProfile? address,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = AddressState(
    address: null,
    isLoading: false,
    error: null,
  );
}
