/*
Using Firebase as my backend.
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter/features/auth/domain/entities/app_user.dart';
import 'package:starter/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Login with Email & Password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = _mapToAppUser(userCredential.user);
      final hasMFA = await hasMFAEnrolled();
      return user.copyWith(hasMFA: hasMFA);
    } on FirebaseAuthMultiFactorException {
      rethrow; // handled outside when MFA is required
    } catch (e) {
      throw Exception('Login failed $e');
    }
  }

  // Register with Email & Password
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return _mapToAppUser(userCredential.user);
    } catch (e) {
      throw Exception('Registration failed $e');
    }
  }

  // Delete Account
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception("No user logged in");

      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete Account $e');
    }
  }

  // Get Current User
  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final hasMFA = await hasMFAEnrolled();
    return _mapToAppUser(firebaseUser).copyWith(hasMFA: hasMFA);
  }

  // Logout
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  // Password Reset
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox";
    } catch (e) {
      return "An error occurred $e";
    }
  }

  // MFA: Enroll phone number
  @override
  Future<void> enrollMFA({
    required String phoneNumber,
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      // final session = await getMultiFactorSession();
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);

      await firebaseAuth.currentUser!.multiFactor.enroll(
        assertion,
        displayName: 'Primary Phone',
      );
    } catch (e) {
      throw Exception('MFA enrollment failed $e');
    }
  }

  // MFA: Verify during login
  @override
  Future<void> verifyMFA({
    required MultiFactorResolver resolver,
    required String smsCode,
    required String verificationId,
    required int selectedHintIndex,
  }) async {
    try {
      // final hint = resolver.hints[selectedHintIndex] as PhoneMultiFactorInfo;
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);

      await resolver.resolveSignIn(assertion);
    } catch (e) {
      throw Exception('MFA verification failed $e');
    }
  }

  // MFA: Get enrolled phone numbers
  @override
  Future<List<String>> getMFAHints(MultiFactorResolver resolver) async {
    return resolver.hints
        .where((hint) => hint.factorId == "phone")
        .map((hint) => (hint as PhoneMultiFactorInfo).phoneNumber)
        .toList();
  }

  // MFA: Send enrollment code
  @override
  Future<void> sendEnrollmentCode({
    required String phoneNumber,
    required MultiFactorSession session,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto verification not typically used for MFA, but handle anyway
        onCodeSent('auto', null);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      multiFactorSession: session,
    );
  }

  // MFA: Send login code
  @override
  Future<void> sendLoginCode({
    required PhoneMultiFactorInfo hint,
    required MultiFactorSession session,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      multiFactorSession: session,
      multiFactorInfo: hint,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        onCodeSent('auto', null);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // MFA: Check if user has factors enrolled
  @override
  Future<bool> hasMFAEnrolled() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return false;

    final factors = await user.multiFactor.getEnrolledFactors();
    return factors.isNotEmpty;
  }

  @override
  Future<MultiFactorSession> getMultifactorSession() async {
    //
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');
    return await user.multiFactor.getSession();
  }

  // Map Firebase User -> AppUser entity
  AppUser _mapToAppUser(User? firebaseUser) {
    if (firebaseUser == null) {
      return AppUser(false, null, uid: '', email: '');
    }
    return AppUser(
      false, // will be updated by hasMFAEnrolled
      null,
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
    );
  }
}
