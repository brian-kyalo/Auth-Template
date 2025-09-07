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
      //
      final user = await authRepo.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      if (_currentUser != null) {
        emit(MFARegistrationRequired(_currentUser!));
      }
    }
  }

  Future<void> verifyMFA(
    String smsCode,
    String verificationId,
    int selectedHintIndex,
  ) async {
    if (state is! MFAVerificationRequired) return;

    // Store the MFA state before emitting AuthLoading
    final mfaState = state as MFAVerificationRequired;
    emit(AuthLoading());
    try {
      await authRepo.verifyMFA(
        resolver: mfaState.resolver,
        smsCode: smsCode,
        verificationId: verificationId,
        selectedHintIndex: selectedHintIndex,
      );
      // After a successful MFA verification, get the updated user
      final user = await authRepo.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      //
      emit(
        MFAVerificationRequired(
          resolver: mfaState.resolver,
          hints: mfaState.hints,
        ),
      );
    }
  }

  Future<void> sendEnrollmentCode(
    String phoneNumber, {
    required void Function(String, int? resendToken) onCodeSent,
    required void Function(String) onError,
  }) async {
    try {
      final currentUser = await authRepo.getCurrentUser();
      if (currentUser == null) {
        onError('No User Signed in.');
        return;
      }
      //
      final session = await authRepo.getMultifactorSession();
      await authRepo.sendEnrollmentCode(
        phoneNumber: phoneNumber,
        session: session,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      onError('Failed to send enrollment code: ${e.toString()}');
    }
  }

  void returnToAuth() {
    emit(Unauthenticated());
  }

  Future<void> sendLoginCode(
    int selectedHintIndex, {
    required void Function(String, int? resendToken) onCodeSent,
    required void Function(String) onError,
  }) async {
    if (state is! MFAVerificationRequired) {
      onError('Invalid state for sending login code');
      return;
    }

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
