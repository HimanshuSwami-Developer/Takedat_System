import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';

import '../models/act_certificate_model.dart';

class ProfileRepository {
  final SupabaseClient _client =
      Supabase.instance.client;

  /// ==============================
  /// GET USER PROFILE
  /// ==============================
  Future<Map<String, dynamic>> getProfile({
    required String userId,
  }) async {
    try {
      /// USER TABLE
      final userData = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      /// ACT CERTIFICATE
      final actData = await _client
          .from('act_certificate')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      /// SHARECODE + FIRST AID
      final shareCodeData = await _client
          .from('sharecode_first_aid')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      /// SIA LICENCE
      final siaData = await _client
          .from('sia_licence')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return {
        "user": userData,

        "actCertificate":
            actData != null
                ? ActCertificateModel.fromJson(
                    actData,
                  )
                : null,

        "sharecodeFirstAid":
            shareCodeData != null
                ? SharecodeFirstAidModel
                    .fromJson(
                    shareCodeData,
                  )
                : null,

        "siaLicence":
            siaData != null
                ? SiaLicenceModel.fromJson(
                    siaData,
                  )
                : null,
      };
    } catch (e) {
      throw Exception(
        "Failed to fetch profile : $e",
      );
    }
  }

  /// ==============================
  /// UPDATE ACT CERTIFICATE
  /// ==============================
  Future<void> updateActCertificate({
    required ActCertificateModel
        model,
  }) async {
    try {
      await _client
          .from('act_certificate')
          .update(
            model.toJson(),
          )
          .eq('id', model.id!);
    } catch (e) {
      throw Exception(
        "Failed to update act certificate : $e",
      );
    }
  }

  /// ==============================
  /// UPDATE SHARECODE + FIRSTAID
  /// ==============================
  Future<void>
      updateSharecodeFirstAid({
    required SharecodeFirstAidModel
        model,
  }) async {
    try {
      await _client
          .from('sharecode_first_aid')
          .update(
            model.toJson(),
          )
          .eq('id', model.id!);
    } catch (e) {
      throw Exception(
        "Failed to update sharecode/first aid : $e",
      );
    }
  }

  /// ==============================
  /// UPDATE SIA LICENCE
  /// ==============================
  Future<void> updateSiaLicence({
    required SiaLicenceModel model,
  }) async {
    try {
      await _client
          .from('sia_licence')
          .update(
            model.toJson(),
          )
          .eq('id', model.id!);
    } catch (e) {
      throw Exception(
        "Failed to update sia licence : $e",
      );
    }
  }

  /// ==============================
  /// UPDATE USER PROFILE
  /// ==============================
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String role,
  }) async {
    try {
      await _client
          .from('users')
          .update({
            "full_name": fullName,
            "email": email,
            "phone": phone,
            "address": address,
            "role": role,
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception(
        "Failed to update user profile : $e",
      );
    }
  }
}