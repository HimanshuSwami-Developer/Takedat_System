import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/models/signed_document_model.dart';

import 'package:takedat_app/models/users_model.dart';
import 'package:takedat_app/models/act_certificate_model.dart';


class UserRepository {
  final supabase = Supabase.instance.client;

  /// ======================================================
  /// REGISTER USER
  /// ======================================================
Future<UserModel> registerUser(UserModel user) async {

  // 1. Email check
  final existing = await supabase
    .from('users')
    .select('id')
    .eq('email', user.email)
    .maybeSingle();

  if (existing != null) {
    throw Exception("Email already registered.");
  }

  // 2. Admin API — creates auth user WITHOUT replacing current session
  final adminResponse = await supabase.auth.admin.createUser(
    AdminUserAttributes(
      email:        user.email,
      password:     user.email,
      emailConfirm: true,
    ),
  );

  if (adminResponse.user == null) {
    throw Exception("Registration failed.");
  }

  final authId = adminResponse.user!.id;

  // 3. ✅ UPSERT — trigger ke row ko update karega
  // Duplicate error kabhi nahi aayega
  await supabase.from('users').upsert(
    {
      'id':           authId,
      'emp_id':       user.empId,
      'full_name':    user.fullName,
      'email':        user.email,
      'phone':        user.phone,
      'address':      user.address,
      'role':         'employee',
      'company_code': user.companyCode,
      'is_active':    false,
    },
    onConflict: 'id',
  );

  // 4. Fresh fetch
  final data = await supabase
    .from('users')
    .select()
    .eq('id', authId)
    .single();

  return UserModel.fromMap(data);
}

  Future<bool> hasUploadedDocuments(String userId) async {
    final response = await supabase
        .from('act_certificate')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  Future<bool> hasSignedDocuments(String userId) async {
    final response = await supabase
        .from('signed_documents')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  /// ======================================================
  /// UPLOAD FILE
  /// ======================================================
  Future<String> uploadDocument({
    File? file,
    Uint8List? bytes,
    String? fileName,
    required String bucket,
    required String path,
  }) async {
    if (kIsWeb) {
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes!,
            fileOptions: const FileOptions(upsert: true),
          );
    } else {
      await supabase.storage
          .from(bucket)
          .upload(path, file!, fileOptions: const FileOptions(upsert: true));
    }
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// ======================================================
  /// SAVE SIA LICENCE
  /// ======================================================

  Future<SiaLicenceModel> saveSiaLicence(SiaLicenceModel model) async {
    final response = await supabase
        .from('sia_licence')
        .insert(model.toJson())
        .select()
        .single();

    return SiaLicenceModel.fromJson(response);
  }

  /// ======================================================
  /// UPDATE SIA LICENCE
  /// ======================================================

  Future<SiaLicenceModel> updateSiaLicence(SiaLicenceModel model) async {
    final response = await supabase
        .from('sia_licence')
        .update(model.toJson())
        .eq('id', model.id!)
        .select()
        .single();

    return SiaLicenceModel.fromJson(response);
  }

  /// ======================================================
  /// GET SINGLE SIA LICENCE
  /// ======================================================

  Future<SiaLicenceModel?> getSiaLicence(int id) async {
    final response = await supabase
        .from('sia_licence')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return SiaLicenceModel.fromJson(response);
  }

  /// ======================================================
  /// GET ALL SIA LICENCE
  /// ======================================================

  Future<List<SiaLicenceModel>> getAllSiaLicence(String userId) async {
    final response = await supabase
        .from('sia_licence')
        .select()
        .eq('user_id', userId);

    return response
        .map<SiaLicenceModel>((e) => SiaLicenceModel.fromJson(e))
        .toList();
  }

  /// ======================================================
  /// SAVE ACT CERTIFICATE
  /// ======================================================

  Future<ActCertificateModel> saveActCertificate(
    ActCertificateModel model,
  ) async {
    final response = await supabase
        .from('act_certificate')
        .insert(model.toJson())
        .select()
        .single();

    return ActCertificateModel.fromJson(response);
  }

  /// ======================================================
  /// UPDATE ACT CERTIFICATE
  /// ======================================================

  Future<ActCertificateModel> updateActCertificate(
    ActCertificateModel model,
  ) async {
    final response = await supabase
        .from('act_certificate')
        .update(model.toJson())
        .eq('id', model.id!)
        .select()
        .single();

    return ActCertificateModel.fromJson(response);
  }

  /// ======================================================
  /// GET SINGLE ACT CERTIFICATE
  /// ======================================================

  Future<ActCertificateModel?> getActCertificate(int id) async {
    final response = await supabase
        .from('act_certificate')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return ActCertificateModel.fromJson(response);
  }

  /// ======================================================
  /// GET ALL ACT CERTIFICATE
  /// ======================================================

  Future<List<ActCertificateModel>> getAllActCertificate(String userId) async {
    final response = await supabase
        .from('act_certificate')
        .select()
        .eq('user_id', userId);

    return response
        .map<ActCertificateModel>((e) => ActCertificateModel.fromJson(e))
        .toList();
  }

  /// ======================================================
  /// SAVE SHARECODE FIRST AID
  /// ======================================================

  Future<SharecodeFirstAidModel> saveSharecodeFirstAid(
    SharecodeFirstAidModel model,
  ) async {
    final response = await supabase
        .from('sharecode_first_aid')
        .insert(model.toJson())
        .select()
        .single();

    return SharecodeFirstAidModel.fromJson(response);
  }

  /// ======================================================
  /// UPDATE SHARECODE FIRST AID
  /// ======================================================

  Future<SharecodeFirstAidModel> updateSharecodeFirstAid(
    SharecodeFirstAidModel model,
  ) async {
    final response = await supabase
        .from('sharecode_first_aid')
        .update(model.toJson())
        .eq('id', model.id!)
        .select()
        .single();

    return SharecodeFirstAidModel.fromJson(response);
  }

  /// ======================================================
  /// GET SINGLE SHARECODE FIRST AID
  /// ======================================================

  Future<SharecodeFirstAidModel?> getSharecodeFirstAid(int id) async {
    final response = await supabase
        .from('sharecode_first_aid')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return SharecodeFirstAidModel.fromJson(response);
  }

  /// ======================================================
  /// GET ALL SHARECODE FIRST AID
  /// ======================================================

  Future<List<SharecodeFirstAidModel>> getAllSharecodeFirstAid(
    String userId,
  ) async {
    final response = await supabase
        .from('sharecode_first_aid')
        .select()
        .eq('user_id', userId);

    return response
        .map<SharecodeFirstAidModel>((e) => SharecodeFirstAidModel.fromJson(e))
        .toList();
  }

  /// ======================================================
  /// SAVE SIGNED DOCUMENTS
  /// ======================================================

  Future<SignedDocumentsModel> saveSignedDocuments(
    SignedDocumentsModel model,
  ) async {
    final existing = await supabase
        .from('signed_documents')
        .select()
        .eq('user_id', model.userId)
        .maybeSingle();

    Map<String, dynamic> data = model.toJson();

    /// UPDATE EXISTING
    if (existing != null) {
      data = {...existing, ...data};
    }

    final response = await supabase
        .from('signed_documents')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();

    return SignedDocumentsModel.fromJson(response);
  }

  /// ======================================================
  /// GET USER SIGNED DOCUMENTS
  /// ======================================================

  Future<SignedDocumentsModel?> getUserSignedDocuments(String userId) async {
    final response = await supabase
        .from('signed_documents')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return SignedDocumentsModel.fromJson(response);
  }

  // ======================================================
  /// Manage Status
  /// ======================================================

  /// ======================================================
  /// GET USERS
  /// ======================================================
Future<List<UserModel>> getUsers({
  int page = 0,
  int limit = 20,
  String search = '',
  bool? isActive, // ← null = sab, true = active only, false = inactive only
}) async {
  final from = page * limit;
  final to   = from + limit - 1;

  dynamic query = supabase
    .from('users')
    .select()
    .eq('role', 'employee');

  // ✅ Sirf tab filter karo jab explicitly pass kiya ho
  if (isActive != null) {
    query = query.eq('is_active', isActive);
  }

  if (search.isNotEmpty) {
    query = query.or(
      'full_name.ilike.%$search%,'
      'email.ilike.%$search%,'
      'phone.ilike.%$search%,'
      'emp_id.ilike.%$search%',
    );
  }

  final response = await query
    .order('created_at', ascending: false)
    .range(from, to);

  return (response as List)
    .map((e) => UserModel.fromMap(e as Map<String, dynamic>))
    .toList();
}

  /// ======================================================
  /// UPDATE STATUS
  /// ======================================================

  Future<UserModel> updateUserStatus({
  required String userId,
  required bool isActive,
}) async {
  // ✅ Service role — RLS bypass
  final response = await supabase
    .from('users')
    .update({'is_active': isActive})
    .eq('id', userId)
    .select()
    .single();

  return UserModel.fromMap(response);
}

}
