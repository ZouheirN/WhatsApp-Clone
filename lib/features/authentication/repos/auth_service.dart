import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_clone/main.dart';

class RepositoryError {
  final String message;

  RepositoryError(this.message);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Either<RepositoryError, void>> verifyPhoneNumber(
    String phoneNumber,
    void Function(String, int?) codeSent,
    void Function(FirebaseAuthException) verificationFailed,
    void Function(String) codeAutoRetrievalTimeout,
  ) async {
    try {
      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );

      return const Right(null);
    } catch (e) {
      logger.e(e.toString());
      return Left(RepositoryError(e.toString()));
    }
  }

  Future<Either<RepositoryError, ConfirmationResult>> signInWithPhoneNumber(
    String phoneNumber,
  ) async {
    try {
      // Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
      ConfirmationResult confirmationResult = await FirebaseAuth.instance
          .signInWithPhoneNumber(phoneNumber.toString());

      return Right(confirmationResult);
    } catch (e) {
      logger.e(e.toString());
      return Left(RepositoryError(e.toString()));
    }
  }

  Future<Either<RepositoryError, void>> verifyOtp(
    String otp,
    ConfirmationResult confirmationResult,
  ) async {
    try {
      await confirmationResult.confirm(otp);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      logger.e(e);

      if (e.code == 'invalid-verification-code') {
        return Left(RepositoryError('Invalid OTP'));
      }

      return Left(RepositoryError(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(RepositoryError(e.toString()));
    }
  }

  Future<Either<RepositoryError, void>> createAndSignInWithCredential(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      logger.e(e);

      if (e.code == 'invalid-verification-code') {
        return Left(RepositoryError('Invalid OTP'));
      }

      return Left(RepositoryError(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(RepositoryError(e.toString()));
    }
  }
}
