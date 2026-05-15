abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {

  final String verificationId;

  OtpSentState(this.verificationId);
}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {

  final String message;

  AuthFailure(this.message);
}