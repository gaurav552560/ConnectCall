import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance;

  // Email registration
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email login
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Phone OTP
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId)
    onCodeSent,
    required void Function(FirebaseAuthException error)
    onVerificationFailed,
    int? forceResendingToken,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (
          PhoneAuthCredential credential,
          ) async {},
      verificationFailed: (
          FirebaseAuthException error,
          ) {
        print('PHONE AUTH ERROR: ${error.code}');
        print(
          'PHONE AUTH MESSAGE: ${error.message}',
        );

        onVerificationFailed(error);
      },
      codeSent: (
          String verificationId,
          int? resendToken,
          ) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (
          String verificationId,
          ) {},
    );
  }

  // Verify phone OTP
  Future<UserCredential> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential =
    PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await _firebaseAuth.signInWithCredential(
      credential,
    );
  }

  // Reset email password
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email,
    );
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}