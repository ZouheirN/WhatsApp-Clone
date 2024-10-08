part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthCodeSentState extends AuthState {
  final String? verificationId;
  final ConfirmationResult? confirmationResult;

  AuthCodeSentState({this.verificationId, this.confirmationResult});
}

class AuthLoggedInState extends AuthState {
  final User firebaseUser;

  AuthLoggedInState(this.firebaseUser);
}

class AuthLoggedOutState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;

  AuthErrorState(this.error);
}
