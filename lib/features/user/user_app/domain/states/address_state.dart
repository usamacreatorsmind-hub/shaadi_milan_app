import '../../../../translitration/models/bilingual_value.dart';

class AddressProfile {
  final BilingualValue addressLine1;
  final BilingualValue post;
  final BilingualValue policeStation;
  final BilingualValue city;
  final BilingualValue state;
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
      'addressLine1': addressLine1.toMap(),
      'post': post.toMap(),
      'city': city.toMap(),
      'state': state.toMap(),
      'policeStation': policeStation.toMap(),
      'pincode': pincode,
    };
  }

  factory AddressProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    return AddressProfile(
      addressLine1: parseBilingual(map['addressLine1']),
      policeStation: parseBilingual(map['policeStation']),
      post: parseBilingual(map['post']),
      city: parseBilingual(map['city']),
      state: parseBilingual(map['state']),
      pincode: map['pincode']?.toString() ?? '',
    );
  }

  AddressProfile copyWith({
    BilingualValue? addressLine1,
    BilingualValue? post,
    BilingualValue? city,
    BilingualValue? state,
    BilingualValue? policeStation,
    String? pincode,
  }) {
    return AddressProfile(
      addressLine1: addressLine1 ?? this.addressLine1,
      post: post ?? this.post,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      policeStation: policeStation ?? this.policeStation,
    );
  }

  factory AddressProfile.empty() {
    return AddressProfile(
      addressLine1: BilingualValue.empty(),
      post: BilingualValue.empty(),
      city: BilingualValue.empty(),
      state: BilingualValue.empty(),
      policeStation: BilingualValue.empty(),
      pincode: '',
    );
  }

  @override
  String toString() {
    return 'AddressProfile(addressLine1: $addressLine1, post: $post, city: $city, state: $state, pincode: $pincode, policeStation: $policeStation)';
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
