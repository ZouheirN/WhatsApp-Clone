import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:whatsapp_clone/features/authentication/repos/auth_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<VerifyPhoneNumberEvent>(verifyPhoneNumberEvent);
    on<VerifyOtpEvent>(verifyOtpEvent);
  }

  FutureOr<void> verifyPhoneNumberEvent(
      VerifyPhoneNumberEvent event, Emitter<AuthenticationState> emit) async {
    emit(VerifyPhoneNumberLoadingState());

    if (kIsWeb) {
      final result =
          await AuthService().signInWithPhoneNumber(event.phoneNumber);

      result.fold(
        (l) {
          emit(VerifyPhoneNumberErrorState(l.message));
        },
        (r) {
          emit(VerifyPhoneNumberCodeSentState(
            confirmationResult: r,
          ));
        },
      );
    } else {
      // final result = await AuthService().verifyPhoneNumber(
      //   event.phoneNumber,
      //   (verificationId, forceResendingToken) async {
      //     emit(VerifyPhoneNumberCodeSentState(
      //       verificationId: verificationId,
      //     ));
      //   },
      //   (e) {
      //     emit(VerifyPhoneNumberErrorState(e.message ?? 'Unknown error'));
      //   },
      //   (verificationId) {
      //     emit(VerifyPhoneNumberErrorState('Auto retrieval timeout'));
      //   },
      // );

      // if (result.isLeft()) {
      //   emit(VerifyPhoneNumberErrorState(result
      //       .leftMap((l) => l.message)
      //       .fold((l) => l, (r) => 'Unknown error')));
      // }
    }
  }

  FutureOr<void> verifyOtpEvent(
      VerifyOtpEvent event, Emitter<AuthenticationState> emit) async {
    emit(VerifyOtpLoadingState());

    if (event.confirmationResult != null) {
      final result =
          await AuthService().verifyOtp(event.otp, event.confirmationResult!);

      result.fold(
        (l) {
          emit(VerifyOtpErrorState(l.message));
        },
        (r) {
          emit(VerifyOtpSuccessState());
        },
      );
    } else {
      final result = await AuthService().createAndSignInWithCredential(
        event.verificationId!,
        event.otp,
      );

      result.fold(
        (l) {
          emit(VerifyOtpErrorState(l.message));
        },
        (r) {
          emit(VerifyOtpSuccessState());
        },
      );
    }
  }
}
