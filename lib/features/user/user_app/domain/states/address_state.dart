class AddressProfile {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  AddressProfile({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }

  factory AddressProfile.fromMap(Map<String, dynamic> map) {
    return AddressProfile(
      addressLine1: map['addressLine1'] as String,
      addressLine2: map['addressLine2'] as String?,
      city: map['city'] as String,
      state: map['state'] as String,
      pincode: map['pincode'] as String,
      country: map['country'] as String,
    );
  }

  @override
  String toString() {
    return 'AddressProfile(addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, state: $state, pincode: $pincode, country: $country)';
  }

  AddressProfile copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? country,
  }) {
    return AddressProfile(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
    );
  }

  factory AddressProfile.empty() {
    return AddressProfile(
      addressLine1: '',
      addressLine2: '',
      city: '',
      state: '',
      pincode: '',
      country: '',
    );
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
