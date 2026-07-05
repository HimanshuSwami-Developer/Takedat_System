import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import '../models/act_certificate_model.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// ==============================
  /// GET USER PROFILE
  /// ==============================
  Future<Map<String, dynamic>> getProfile({required String userId}) async {
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

        "actCertificate": actData != null
            ? ActCertificateModel.fromJson(actData)
            : null,

        "sharecodeFirstAid": shareCodeData != null
            ? SharecodeFirstAidModel.fromJson(shareCodeData)
            : null,

        "siaLicence": siaData != null
            ? SiaLicenceModel.fromJson(siaData)
            : null,
      };
    } catch (e) {
      throw Exception("Failed to fetch profile : $e");
    }
  }

  /// ==============================
  /// UPDATE ACT CERTIFICATE
  /// ==============================
  Future<void> updateActCertificate({
    required ActCertificateModel model,
  }) async {
    try {
      final data = model.toJson();
      // Never overwrite an existing URL with null — only update when a new
      // file was actually uploaded for that side.
      if (model.actOrangeUrl == null) data.remove('act_orange_url');
      if (model.actBlueUrl == null) data.remove('act_blue_url');
      await _client
          .from('act_certificate')
          .update(data)
          .eq('id', model.id!);
    } catch (e) {
      throw Exception("Failed to update act certificate : $e");
    }
  }

  /// ==============================
  /// UPDATE SHARECODE + FIRSTAID
  /// ==============================
  Future<void> updateSharecodeFirstAid({
    required SharecodeFirstAidModel model,
  }) async {
    try {
      final data = model.toJson();
      // Never overwrite an existing URL with null — only update when a new
      // file was actually uploaded for that side.
      if (model.shareCodeUrl == null) data.remove('share_code_url');
      if (model.firstAidUrl == null) data.remove('first_aid_url');
      await _client
          .from('sharecode_first_aid')
          .update(data)
          .eq('id', model.id!);
    } catch (e) {
      throw Exception("Failed to update sharecode/first aid : $e");
    }
  }

  /// ==============================
  /// UPDATE SIA LICENCE
  /// ==============================
  Future<void> updateSiaLicence({required SiaLicenceModel model}) async {
    try {
      await _client
          .from('sia_licence')
          .update(model.toJson())
          .eq('id', model.id!);
    } catch (e) {
      throw Exception("Failed to update sia licence : $e");
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
      throw Exception("Failed to update user profile : $e");
    }
  }

  /// ==============================
  /// UPDATE BASIC PROFILE (name, phone, address only)
  /// ==============================
  Future<void> updateBasicProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    try {
      await _client.from('users').update({
        'full_name': fullName,
        'phone': phone,
        'address': address,
      }).eq('id', userId);
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  Future<void> downloadUserFolder({
    required String userEmail,
    required Function(double progress, String message) onProgress,
  }) async {
    try {
      /// GET FILES
      final files = await _client.storage
          .from('documents')
          .list(path: userEmail);

      if (files.isEmpty) {
        throw Exception("No files found");
      }

      final archive = Archive();

      /// DOWNLOAD FILES
      for (int i = 0; i < files.length; i++) {
        final file = files[i];

        onProgress(i / files.length, "Downloading ${file.name}");

        final filePath = "$userEmail/${file.name}";

        final url = _client.storage.from('documents').getPublicUrl(filePath);

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          archive.addFile(
            ArchiveFile(
              file.name,
              response.bodyBytes.length,
              response.bodyBytes,
            ),
          );
        }
      }

      /// ZIP CREATION
      onProgress(0.9, "Creating ZIP...");

      final zipData = ZipEncoder().encode(archive);

      if (zipData == null) {
        throw Exception("ZIP failed");
      }

      final bytes = Uint8List.fromList(zipData);

      final blob = html.Blob([bytes]);

      final downloadUrl = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: downloadUrl)
        ..setAttribute("download", "${userEmail}_documents.zip")
        ..click();

      /// IMPORTANT FIX
      await Future.delayed(const Duration(milliseconds: 700));

      html.Url.revokeObjectUrl(downloadUrl);

      onProgress(1, "Download Completed");
    } catch (e) {
      throw Exception("Folder download failed : $e");
    }
  }
}
