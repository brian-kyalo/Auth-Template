import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final bool hasMFA; // Track if MFA is enrolled.
  final List<String>? mfaPhoneNo; //Store enrollled phone numbers

  // Constructor
  const AppUser(
    this.hasMFA,
    this.mfaPhoneNo, {
    required this.uid,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, email, hasMFA, mfaPhoneNo];

  // Convert AppUser to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'hasMFA': hasMFA,
      'mfaPhoneNo': mfaPhoneNo,
    };
  }

  // Convert JSON back to AppUser
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      json['hasMFA'] ?? false,
      json['mfaPhoneNo'] != null ? List<String>.from(json['mfaPhoneNo']) : null,
      uid: json['uid'],
      email: json['email'],
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    bool? hasMFA,
    List<String>? mfaPhoneNo,
  }) {
    return AppUser(
      hasMFA ?? this.hasMFA,
      mfaPhoneNo ?? this.mfaPhoneNo,
      uid: uid ?? this.uid,
      email: email ?? this.email,
    );
  }
}
