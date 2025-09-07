/*
 * This is ressponsible for state management.
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/features/auth/domain/entities/app_user.dart';
import 'package:starter/features/auth/domain/repos/auth_repo.dart';
import 'package:starter/features/auth/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(Authinitial());

  //Get Current User.
  AppUser? get currentUser => _currentUser;

  //Check if user is authenticated
  void checkAuth() async {
    //Loading
    emit(AuthLoading());

    //Get Current User.
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  //Login with Email and Pass.
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
        if (user.hasMFA) {
          // MFA check should be handled by loginWithEmailPassword throwing exception
          emit(Authenticated(user)); // Will be overridden if MFA required
        } else {
          emit(Authenticated(user));
        }
      } else {
        emit(Unauthenticated());
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      final hints = await authRepo.getMFAHints(e.resolver);
      emit(MFAVerificationRequired(resolver: e.resolver, hints: hints));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //Register
  Future<void> register(String name, String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(
        name,
        email,
        password,
      );
      if (user != null) {
        _currentUser = user;
        emit(MFARegistrationRequired(user)); // Require MFA enrollment
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //LogOut Method
  Future<void> logOut() async {
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  //Forgot Password
  Future<String> forgotPassword(String email) async {
    try {
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  //Delete Acc.
  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> enrollMFA(
    String phoneNumber,
    String smsCode,
    String verificationId,
  ) async {
    try {
      emit(AuthLoading());
      await authRepo.enrollMFA(
        phoneNumber: phoneNumber,
        smsCode: smsCode,
        verificationId: verificationId,
      );
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(hasMFA: true);
        emit(Authenticated(_currentUser!));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyMFA(
    String smsCode,
    String verificationId,
    int selectedHintIndex,
  ) async {
    if (state is! MFAVerificationRequired) return;
    emit(AuthLoading());
    try {
      final mfaState = state as MFAVerificationRequired;
      await authRepo.verifyMFA(
        resolver: mfaState.resolver,
        smsCode: smsCode,
        verificationId: verificationId,
        selectedHintIndex: selectedHintIndex,
      );
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(hasMFA: true);
        emit(Authenticated(_currentUser!));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendEnrollmentCode(
    String phoneNumber, {
    required void Function(String, int? resendToken) onCodeSent,
    required void Function(String) onError,
  }) async {
    try {
      final session = await authRepo.getCurrentUser() != null
          ? await authRepo.getMultifactorSession()
          : throw Exception('No user');
      await authRepo.sendEnrollmentCode(
        phoneNumber: phoneNumber,
        session: session,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> sendLoginCode(
    int selectedHintIndex, {
    required void Function(String, int? resendToken) onCodeSent,
    required void Function(String) onError,
  }) async {
    if (state is! MFAVerificationRequired) return;
    try {
      final mfaState = state as MFAVerificationRequired;
      final hint =
          mfaState.resolver.hints[selectedHintIndex] as PhoneMultiFactorInfo;
      final session = mfaState.resolver.session;
      await authRepo.sendLoginCode(
        hint: hint,
        session: session,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      onError(e.toString());
    }
  }
}
