import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum AgentDesignation {
  staff('staff', 'Staff'),
  fieldManager('field_manager', 'Field Manager'),
  areaManager('area_manager', 'Area Manager');

  final String value;
  final String label;
  const AgentDesignation(this.value, this.label);

  static AgentDesignation fromString(String? value) {
    return AgentDesignation.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AgentDesignation.staff,
    );
  }
}

class AgentEntity {
  // 🔹 Auth / Role
  final String uid;
  final String role;
  final String agentEmail;

  // 🔹 Staff Identity
  final String agentId;
  final String agentName;
  final String agentAadhar;
  final String agentLicenseNumber;
  final String agentMobile;
  final AgentDesignation designation;

  // 🔹 Address
  final String agentAddress;
  final String agentCity;
  final String agentState;
  final String agentPincode;

  // 🔹 Status
  final bool isApproved;
  final bool isRejected;

  // 🔹 Meta
  final DateTime registrationDate;
  final String profileImageUrl;
  final String primaryImageUrl;
  final String aadharUrl;

  const AgentEntity({
    required this.uid,
    required this.role,
    required this.agentEmail,
    required this.agentId,
    required this.agentName,
    required this.agentAadhar,
    required this.agentLicenseNumber,
    required this.agentMobile,
    required this.designation,
    required this.agentAddress,
    required this.agentCity,
    required this.agentState,
    required this.agentPincode,
    required this.isApproved,
    required this.isRejected,
    required this.registrationDate,
    required this.profileImageUrl,
    required this.primaryImageUrl,
    required this.aadharUrl,
  });

  /// ---------------- EMPTY ----------------
  factory AgentEntity.empty() {
    return AgentEntity(
      uid: '',
      role: '',
      agentEmail: '',
      agentId: '',
      agentName: '',
      agentAadhar: '',
      agentLicenseNumber: '',
      agentMobile: '',
      designation: AgentDesignation.staff,
      agentAddress: '',
      agentCity: '',
      agentState: '',
      agentPincode: '',
      isApproved: false,
      isRejected: false,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(0),
      profileImageUrl: "",
      primaryImageUrl: "",
      aadharUrl: "",
    );
  }

  /// ---------------- MAP ----------------
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'agentEmail': agentEmail,
      'agentId': agentId,
      'agentName': agentName,
      'agentAadhar': agentAadhar,
      'agentLicenseNumber': agentLicenseNumber,
      'agentMobile': agentMobile,
      'designation': designation.value,
      'agentAddress': agentAddress,
      'agentCity': agentCity,
      'agentState': agentState,
      'agentPincode': agentPincode,
      'isApproved': isApproved,
      'isRejected': isRejected,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'profileImageUrl': profileImageUrl,
      'primaryImageUrl': primaryImageUrl,
      'aadharUrl': aadharUrl,
    };
  }

  factory AgentEntity.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AgentEntity.empty();

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return AgentEntity(
      uid: map['uid'] ?? '',
      role: map['role'] ?? '',
      agentEmail: map['agentEmail'] ?? '',
      agentId: map['agentId'] ?? '',
      agentName: map['agentName'] ?? '',
      agentAadhar: map['agentAadhar'] ?? '',
      agentLicenseNumber: map['agentLicenseNumber'] ?? '',
      agentMobile: map['agentMobile'] ?? '',
      designation: AgentDesignation.fromString(map['designation']),
      agentAddress: map['agentAddress'] ?? '',
      agentCity: map['agentCity'] ?? '',
      agentState: map['agentState'] ?? '',
      agentPincode: map['agentPincode'] ?? '',
      isApproved: map['isApproved'] ?? false,
      isRejected: map['isRejected'] ?? false,
      registrationDate: parseDate(map['registrationDate']),
      profileImageUrl: map['profileImageUrl'] ?? '',
      primaryImageUrl: map['primaryImageUrl'] ?? '',
      aadharUrl: map['aadharUrl'] ?? '',
    );
  }

  /// ---------------- JSON ----------------
  String toJson() => json.encode(toMap());

  factory AgentEntity.fromJson(String source) =>
      AgentEntity.fromMap(json.decode(source));

  /// ---------------- COPY WITH ----------------
  AgentEntity copyWith({
    String? uid,
    String? role,
    String? agentEmail,
    String? agentId,
    String? agentName,
    String? agentAadhar,
    String? agentLicenseNumber,
    String? agentMobile,
    AgentDesignation? designation,
    String? agentAddress,
    String? agentCity,
    String? agentState,
    String? agentPincode,
    bool? isApproved,
    bool? isRejected,
    DateTime? registrationDate,
    String? profileImageUrl,
    String? primaryImageUrl,
    String? aadharUrl,
  }) {
    return AgentEntity(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      agentEmail: agentEmail ?? this.agentEmail,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentAadhar: agentAadhar ?? this.agentAadhar,
      agentLicenseNumber: agentLicenseNumber ?? this.agentLicenseNumber,
      agentMobile: agentMobile ?? this.agentMobile,
      designation: designation ?? this.designation,
      agentAddress: agentAddress ?? this.agentAddress,
      agentCity: agentCity ?? this.agentCity,
      agentState: agentState ?? this.agentState,
      agentPincode: agentPincode ?? this.agentPincode,
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
      registrationDate: registrationDate ?? this.registrationDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      aadharUrl: aadharUrl ?? this.aadharUrl,
    );
  }

  /// ---------------- COMPENSATION LOGIC ----------------
  bool get isEligibleForCommission {
    // Staff always gets commission as per "Salary + Commission"
    if (designation == AgentDesignation.staff) return true;

    // For Managers, commission starts after 3 months (approx 90 days)
    final threeMonthsAfterJoining = registrationDate.add(const Duration(days: 90));
    return DateTime.now().isAfter(threeMonthsAfterJoining);
  }

  double get commissionRate {
    switch (designation) {
      case AgentDesignation.staff:
        // Staff commission not explicitly specified in %, using a placeholder or default if needed
        return 0.05; // Example: 5%
      case AgentDesignation.fieldManager:
        return isEligibleForCommission ? 0.20 : 0.0;
      case AgentDesignation.areaManager:
        return isEligibleForCommission ? 0.05 : 0.0;
    }
  }

  double calculateCommission(double totalRevenue) {
    return totalRevenue * commissionRate;
  }

  /// ---------------- OVERRIDES ----------------
  @override
  String toString() {
    return 'AgentEntity(agentId: $agentId, name: $agentName, designation: ${designation.label}, approved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgentEntity &&
        other.uid == uid &&
        other.role == role &&
        other.agentEmail == agentEmail &&
        other.agentId == agentId &&
        other.agentName == agentName &&
        other.agentAadhar == agentAadhar &&
        other.agentLicenseNumber == agentLicenseNumber &&
        other.agentMobile == agentMobile &&
        other.designation == designation &&
        other.agentAddress == agentAddress &&
        other.agentCity == agentCity &&
        other.agentState == agentState &&
        other.agentPincode == agentPincode &&
        other.isApproved == isApproved &&
        other.isRejected == isRejected &&
        other.registrationDate == registrationDate &&
        other.profileImageUrl == profileImageUrl &&
        other.primaryImageUrl == primaryImageUrl &&
        other.aadharUrl == aadharUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        role.hashCode ^
        agentEmail.hashCode ^
        agentId.hashCode ^
        agentName.hashCode ^
        agentAadhar.hashCode ^
        agentLicenseNumber.hashCode ^
        agentMobile.hashCode ^
        designation.hashCode ^
        agentAddress.hashCode ^
        agentCity.hashCode ^
        agentState.hashCode ^
        agentPincode.hashCode ^
        isApproved.hashCode ^
        isRejected.hashCode ^
        registrationDate.hashCode ^
        profileImageUrl.hashCode ^
        primaryImageUrl.hashCode ^
        aadharUrl.hashCode;
  }
}


class AgentState {
  final AgentEntity? agentEntity;
  final bool isLoading;
  final String? error;

  const AgentState({this.agentEntity, this.isLoading = false, this.error});
  factory AgentState.initial() => const AgentState();

  AgentState copyWith({
    AgentEntity? agentEntity,
    bool? isLoading,
    String? error,
  }) {
    return AgentState(
      agentEntity: agentEntity ?? this.agentEntity,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
