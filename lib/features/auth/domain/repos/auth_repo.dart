/*
All Auth operations for this application.
*/

import 'package:firebase_auth/firebase_auth.dart';

import '../entities/app_user.dart';

abstract class AuthRepo {
  Future<MultiFactorSession> getMultifactorSession();
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  );
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<String> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();

  // MFA Methods
  Future<void> enrollMFA({
    required String phoneNumber,
    required String smsCode,
    required String verificationId,
  });

  Future<void> verifyMFA({
    required MultiFactorResolver resolver,
    required String smsCode,
    required String verificationId,
    required int selectedHintIndex,
  });

  Future<List<String>> getMFAHints(
    MultiFactorResolver resolver,
  ); // Return Phone Numbers
  Future<void> sendEnrollmentCode({
    required String phoneNumber,
    required MultiFactorSession session,
    required void Function(String verificationId, int? forceResendingToken)
    onCodeSent,
    required void Function(String) onError,
  });
  Future<void> sendLoginCode({
    required PhoneMultiFactorInfo hint,
    required MultiFactorSession session,
    required void Function(String verificationId, int? forceResendingToken)
    onCodeSent,
    required void Function(String) onError,
  });
  Future<bool> hasMFAEnrolled();
}
