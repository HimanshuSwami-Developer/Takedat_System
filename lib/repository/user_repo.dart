import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:takedat_app/models/users_model.dart';

class UserRepository {

  final supabase = Supabase.instance.client;

  Future<UserModel> registerUser(
    UserModel user,
  ) async {

    /// INSERT USER
    final response = await supabase
        .from('users')
        .insert({
          ...user.toMap(),
        })
        .select()
        .single();

    /// RETURN INSERTED USER
    return UserModel.fromMap(response);
  }
}