/*

Different Types of  State the Application could be in .

 */

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter/features/auth/domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

//Initial
class Authinitial extends AuthState {}

//Auth Loading state
class AuthLoading extends AuthState {}

//Unauthenticated
class Unauthenticated extends AuthState {}

//Authenticated.
class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

//MFA Registration
class MFARegistrationRequired extends AuthState {
  final AppUser user;

  const MFARegistrationRequired(this.user);

  @override
  List<Object?> get props => [user];
}

//MFA Registration
class MFAVerificationRequired extends AuthState {
  final MultiFactorResolver resolver;
  final List<String> hints; //Phone Numbers

  const MFAVerificationRequired({required this.resolver, required this.hints});

  @override
  List<Object?> get props => [resolver, hints];
}

// Errors
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
