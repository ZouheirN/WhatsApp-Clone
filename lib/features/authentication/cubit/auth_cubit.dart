import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitialState());

  String? verificationID;

  void sendOTP(String phoneNumber) async {
    emit(AuthLoadingState());

    if (kIsWeb) {
      ConfirmationResult confirmationResult = await FirebaseAuth.instance
          .signInWithPhoneNumber(phoneNumber.toString());

      emit(AuthCodeSentState(confirmationResult: confirmationResult));
    } else {
      _auth.verifyPhoneNumber(
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

  Future<void> signInWithPhoneWeb(
      String otp, ConfirmationResult confirmationResult) async {
    try {
      final userCredential = await confirmationResult.confirm(otp);

      if (userCredential.user != null) {
        await saveUserInfo(userCredential);
        emit(AuthLoggedInState(userCredential.user!));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(e.message.toString()));
    }
  }

  void signInWithPhone(AuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await saveUserInfo(userCredential);
        emit(AuthLoggedInState(userCredential.user!));
      }
    } on FirebaseAuthException catch (ex) {
      emit(AuthErrorState(ex.message.toString()));
    }
  }

  Future<void> saveUserInfo(UserCredential userCredential) async {
    await _firestore
        .collection('users')
        .doc(
          userCredential.user!.uid,
        )
        .set({
      'uid': userCredential.user!.uid,
      'phone': userCredential.user!.phoneNumber,
      'profilePic': 'https://ui-avatars.com/api/?name=John+Doe',
    });
  }

  void signOut() async {
    emit(AuthLoggedOutState());
    _auth.signOut();
  }
}
