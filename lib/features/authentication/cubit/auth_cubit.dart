import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitialState());

  String? verificationID;

  void sendOTP(String phoneNumber) async {
    emit(AuthLoadingState());

    if (kIsWeb) {
      ConfirmationResult confirmationResult = await FirebaseAuth.instance
          .signInWithPhoneNumber(phoneNumber.toString());

      emit(AuthCodeSentState(confirmationResult: confirmationResult));
    } else {
      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, forceResendingToken) {
          verificationID = verificationId;
          emit(AuthCodeSentState(verificationId: verificationId));
        },
        verificationCompleted: (phoneAuthCredential) {
          signInWithPhone(phoneAuthCredential);
        },
        verificationFailed: (error) {
          emit(AuthErrorState(error.message.toString()));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          verificationID = verificationId;
        },
      );
    }
  }

  void verifyOTP(String otp,
      {ConfirmationResult? confirmationResult, String? verificationId}) async {
    emit(AuthLoadingState());

    if (confirmationResult != null) {
      signInWithPhoneWeb(otp, confirmationResult);
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationID!, smsCode: otp);
      signInWithPhone(credential);
    }
  }

  Future<void> signInWithPhoneWeb(String otp, ConfirmationResult confirmationResult) async {
    try {
      final cred = await confirmationResult.confirm(otp);

      if (cred.user != null) {
        emit(AuthLoggedInState(cred.user!));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(e.message.toString()));
    }
  }

  void signInWithPhone(AuthCredential credential) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        emit(AuthLoggedInState(userCredential.user!));
      }
    } on FirebaseAuthException catch (ex) {
      emit(AuthErrorState(ex.message.toString()));
    }
  }

  void signOut() async {
    emit(AuthLoggedOutState());
    _firebaseAuth.signOut();
  }
}
