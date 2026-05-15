import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/repository/auth_repo.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {

    /// ADMIN LOGIN
    on<AdminLoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.adminLogin(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    /// SEND EMAIL OTP
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.sendOtp(
          email: event.email, // ← was phone
          codeSent: (verificationId) {
            emit(OtpSentState(verificationId));
          },
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    /// VERIFY EMAIL OTP
    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.verifyOtp(
          verificationId: event.verificationId,
          otp: event.otp,
          phone: event.email, // ← email passed into phone param
        );
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}