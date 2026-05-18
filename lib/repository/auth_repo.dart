import 'package:supabase_flutter/supabase_flutter.dart';

import '../constant/session_keys.dart';
import '../constant/session_manager.dart';
import '../models/users_model.dart';

class AuthRepository {
  final supabase = Supabase.instance.client;

  /// =========================
  /// ADMIN LOGIN WITH PASSWORD
  /// =========================

Future<UserModel> adminLogin({
  required String email,
  required String password,
}) async {

  /// LOGIN
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );

  if (response.user == null) {
    throw Exception("Invalid email or password");
  }

  /// GET USER FROM TABLE
  final data = await supabase
      .from('users')
      .select()
      .eq('email', email)
      .maybeSingle();

  /// NO USER FOUND
  if (data == null) {
    await supabase.auth.signOut();

    throw Exception("User profile not found");
  }

  final user = UserModel.fromMap(data);

  /// INACTIVE USER
  if (!user.isActive) {
    await supabase.auth.signOut();

    throw Exception(
      "Your account is inactive. Contact admin.",
    );
  }

  /// ROLE CHECK
  if (user.role.toLowerCase() != "admin") {
    await supabase.auth.signOut();

    throw Exception("Only admin can login");
  }

  /// SAVE SESSION
  await saveSession(user);

  return user;
}


  /// =========================
  /// SEND EMAIL OTP
  /// =========================

  /// =========================
  /// SEND EMAIL OTP
  /// =========================

  Future<void> sendOtp({
    required String email,
    required Function(String verificationId) codeSent,
  }) async {
    /// CHECK USER EXISTS IN USERS TABLE
    final userData = await supabase
        .from('users')
        .select()
        .eq('is_active', true)
        .eq('email', email)
        .maybeSingle();

    if (userData == null) {
      throw Exception("Email not registered.");
    }

    /// SEND OTP
    await supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: null,
      shouldCreateUser: false,
    );

    codeSent(email);
  }

  /// =========================
  /// VERIFY EMAIL OTP
  /// =========================

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String otp,
    required String phone,
  }) async {
    final email = verificationId;

    /// VERIFY OTP
    final response = await supabase.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: otp,
    );

    if (response.user == null) {
      throw Exception("Invalid OTP");
    }

    /// GET USER
    final data = await supabase
        .from('users')
        .select()
        .eq('is_active', true)
        .eq('email', email)
        .single();

    final user = UserModel.fromMap(data);

    await saveSession(user);

    return user;
  }

  /// =========================
  /// SAVE SESSION
  /// =========================

  Future<void> saveSession(UserModel user) async {
    await SessionManager.saveBool(SessionKeys.isLoggedIn, true);

    await SessionManager.saveString(SessionKeys.userId, user.id ?? "");

    await SessionManager.saveString(SessionKeys.empId, user.empId);

    await SessionManager.saveString(SessionKeys.fullName, user.fullName);

    await SessionManager.saveString(SessionKeys.email, user.email);

    await SessionManager.saveString(SessionKeys.phone, user.phone);

    await SessionManager.saveString(SessionKeys.address, user.address);

    await SessionManager.saveString(SessionKeys.role, user.role);
  }

  /// =========================
  /// LOGOUT
  /// =========================

  Future<void> logout() async {
    await supabase.auth.signOut();

    await SessionManager.clear();
  }
}
