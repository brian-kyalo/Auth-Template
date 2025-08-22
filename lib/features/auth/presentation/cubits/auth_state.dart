/*

Different Types of  State the Application could be in .

 */

import 'package:starter/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

//Initial
class Authinitial extends AuthState {}

//Auth Loading state
class AuthLoading extends AuthState {}

//Authenticated.
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

//Unauthenticated
class Unauthenticated extends AuthState {}

// Errors
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
