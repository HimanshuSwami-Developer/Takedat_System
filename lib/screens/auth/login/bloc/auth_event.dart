
abstract class AuthEvent {}

class AdminLoginEvent extends AuthEvent {
  final String email;
  final String password;
  AdminLoginEvent({required this.email, required this.password});
}

class SendOtpEvent extends AuthEvent {
  final String email; // ← was phone
  SendOtpEvent(this.email);
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  final String email; // ← was phone
  VerifyOtpEvent({
    required this.verificationId,
    required this.otp,
    required this.email,
  });
}