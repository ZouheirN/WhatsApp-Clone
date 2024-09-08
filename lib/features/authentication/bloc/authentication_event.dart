part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

// Verify Phone Number
class VerifyPhoneNumberEvent extends AuthenticationEvent {
  final String phoneNumber;

  VerifyPhoneNumberEvent(this.phoneNumber);
}

// Verify OTP
class VerifyOtpEvent extends AuthenticationEvent {
  final String otp;
  final String? verificationId;
  final ConfirmationResult? confirmationResult;

  VerifyOtpEvent({required this.otp, this.verificationId, this.confirmationResult});
}
