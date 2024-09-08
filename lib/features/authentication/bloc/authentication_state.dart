part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

// Verify Phone Number
class VerifyPhoneNumberLoadingState extends AuthenticationState {}

class VerifyPhoneNumberErrorState extends AuthenticationState {
  final String errorMessage;

  VerifyPhoneNumberErrorState(this.errorMessage);
}

class VerifyPhoneNumberCodeSentState extends AuthenticationState {
  final String? verificationId;
  final ConfirmationResult? confirmationResult;

  VerifyPhoneNumberCodeSentState(
      {this.verificationId, this.confirmationResult});
}

// Verify OTP
class VerifyOtpLoadingState extends AuthenticationState {}

class VerifyOtpErrorState extends AuthenticationState {
  final String errorMessage;

  VerifyOtpErrorState(this.errorMessage);
}

class VerifyOtpSuccessState extends AuthenticationState {}
