import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/models/signed_document_model.dart';
import 'package:takedat_app/models/users_model.dart';

class EmployeeComplianceRepository {

  final supabase = Supabase.instance.client;

  /// =====================================================
  /// SAFE RELATION PARSER
  /// =====================================================

  dynamic _parseRelation(dynamic value) {

    if (value == null) {
      return null;
    }

    /// LIST RELATION
    if (value is List) {

      if (value.isEmpty) {
        return null;
      }

      return value.first;
    }

    /// OBJECT RELATION
    return value;
  }

  /// =====================================================
  /// GET ALL EMPLOYEE COMPLIANCE
  /// =====================================================

  Future<List<Map<String, dynamic>>> getCompliance({

    int page = 0,

    int limit = 20,

    String search = '',
  }) async {

    final from = page * limit;

    final to = from + limit - 1;

    /// =====================================================
    /// QUERY
    /// =====================================================

    PostgrestFilterBuilder query = supabase
        .from('users')
        .select('''
          id,
          emp_id,
          full_name,
          email,
          phone,
          address,
          role,
          is_active,
          created_at,

          act_certificate (
            *
          ),

          sharecode_first_aid (
            *
          ),

          sia_licence (
            *
          ),

          signed_documents (
            *
          )
        ''')
        .eq(
          'is_active',
          true,
        );

    /// =====================================================
    /// SEARCH
    /// =====================================================

    if (search.isNotEmpty) {

      query = query.or(
        'full_name.ilike.%$search%,'
        'email.ilike.%$search%,'
        'emp_id.ilike.%$search%,'
        'phone.ilike.%$search%',
      );
    }

    /// =====================================================
    /// RESPONSE
    /// =====================================================

    final response = await query
        .order(
          'created_at',
          ascending: false,
        )
        .range(from, to);

    /// =====================================================
    /// MAP DATA
    /// =====================================================

    return (response as List).map((item) {

      final actData =
          _parseRelation(
            item['act_certificate'],
          );

      final sharecodeData =
          _parseRelation(
            item['sharecode_first_aid'],
          );

      final siaData =
          _parseRelation(
            item['sia_licence'],
          );

      final signedData =
          _parseRelation(
            item['signed_documents'],
          );

      return {

        /// USER
        'user':
            UserModel.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            ),

        /// ACT CERTIFICATE
        'act_certificate':

            actData != null

                ? ActCertificateModel.fromJson(
                    Map<String, dynamic>.from(
                      actData,
                    ),
                  )

                : null,

        /// SHARECODE + FIRST AID
        'sharecode_firstaid':

            sharecodeData != null

                ? SharecodeFirstAidModel.fromJson(
                    Map<String, dynamic>.from(
                      sharecodeData,
                    ),
                  )

                : null,

        /// SIA LICENCE
        'sia_licence':

            siaData != null

                ? SiaLicenceModel.fromJson(
                    Map<String, dynamic>.from(
                      siaData,
                    ),
                  )

                : null,

        /// SIGNED DOCUMENTS
        'signed_documents':

            signedData != null

                ? SignedDocumentsModel.fromJson(
                    Map<String, dynamic>.from(
                      signedData,
                    ),
                  )

                : null,
      };
    }).toList();
  }

  /// =====================================================
  /// GET SINGLE EMPLOYEE COMPLIANCE
  /// =====================================================

  Future<Map<String, dynamic>?> getEmployeeCompliance(
    String userId,
  ) async {

    final response = await supabase
        .from('users')
        .select('''
          id,
          emp_id,
          full_name,
          email,
          phone,
          address,
          role,
          is_active,
          created_at,

          act_certificate (
            *
          ),

          sharecode_first_aid (
            *
          ),

          sia_licence (
            *
          ),

          signed_documents (
            *
          )
        ''')
        .eq(
          'id',
          userId,
        )
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final actData =
        _parseRelation(
          response['act_certificate'],
        );

    final sharecodeData =
        _parseRelation(
          response['sharecode_first_aid'],
        );

    final siaData =
        _parseRelation(
          response['sia_licence'],
        );

    final signedData =
        _parseRelation(
          response['signed_documents'],
        );

    return {

      /// USER
      'user':
          UserModel.fromMap(
            Map<String, dynamic>.from(
              response,
            ),
          ),

      /// ACT
      'act_certificate':

          actData != null

              ? ActCertificateModel.fromJson(
                  Map<String, dynamic>.from(
                    actData,
                  ),
                )

              : null,

      /// SHARECODE
      'sharecode_firstaid':

          sharecodeData != null

              ? SharecodeFirstAidModel.fromJson(
                  Map<String, dynamic>.from(
                    sharecodeData,
                  ),
                )

              : null,

      /// SIA
      'sia_licence':

          siaData != null

              ? SiaLicenceModel.fromJson(
                  Map<String, dynamic>.from(
                    siaData,
                  ),
                )

              : null,

      /// SIGNED DOCS
      'signed_documents':

          signedData != null

              ? SignedDocumentsModel.fromJson(
                  Map<String, dynamic>.from(
                    signedData,
                  ),
                )

              : null,
    };
  }

  /// =====================================================
  /// UPSERT ACT CERTIFICATE
  /// =====================================================

  Future<void> upsertActCertificate(
    ActCertificateModel model,
  ) async {

    final existing = await supabase
        .from('act_certificate')
        .select('id')
        .eq(
          'user_id',
          model.userId,
        )
        .maybeSingle();

    if (existing != null) {

      await supabase
          .from('act_certificate')
          .update(
            model.toJson(),
          )
          .eq(
            'id',
            existing['id'],
          );
    }

    else {

      await supabase
          .from('act_certificate')
          .insert(
            model.toJson(),
          );
    }
  }

  /// =====================================================
  /// UPSERT SHARECODE + FIRST AID
  /// =====================================================

  Future<void> upsertSharecodeFirstAid(
    SharecodeFirstAidModel model,
  ) async {

    final existing = await supabase
        .from('sharecode_first_aid')
        .select('id')
        .eq(
          'user_id',
          model.userId,
        )
        .maybeSingle();

    if (existing != null) {

      await supabase
          .from('sharecode_first_aid')
          .update(
            model.toJson(),
          )
          .eq(
            'id',
            existing['id'],
          );
    }

    else {

      await supabase
          .from('sharecode_first_aid')
          .insert(
            model.toJson(),
          );
    }
  }

  /// =====================================================
  /// UPSERT SIA LICENCE
  /// =====================================================

  Future<void> upsertSiaLicence(
    SiaLicenceModel model,
  ) async {

    final existing = await supabase
        .from('sia_licence')
        .select('id')
        .eq(
          'user_id',
          model.userId,
        )
        .maybeSingle();

    if (existing != null) {

      await supabase
          .from('sia_licence')
          .update(
            model.toJson(),
          )
          .eq(
            'id',
            existing['id'],
          );
    }

    else {

      await supabase
          .from('sia_licence')
          .insert(
            model.toJson(),
          );
    }
  }

  /// =====================================================
  /// UPSERT SIGNED DOCUMENTS
  /// =====================================================

  Future<void> upsertSignedDocuments(
    SignedDocumentsModel model,
  ) async {

    final existing = await supabase
        .from('signed_documents')
        .select('id')
        .eq(
          'user_id',
          model.userId,
        )
        .maybeSingle();

    if (existing != null) {

      await supabase
          .from('signed_documents')
          .update(
            model.toJson(),
          )
          .eq(
            'id',
            existing['id'],
          );
    }

    else {

      await supabase
          .from('signed_documents')
          .insert(
            model.toJson(),
          );
    }
  }

  /// =====================================================
  /// DELETE ACT CERTIFICATE
  /// =====================================================

  Future<void> deleteActCertificate(
    int id,
  ) async {

    await supabase
        .from('act_certificate')
        .delete()
        .eq(
          'id',
          id,
        );
  }

  /// =====================================================
  /// DELETE SHARECODE + FIRST AID
  /// =====================================================

  Future<void> deleteSharecodeFirstAid(
    int id,
  ) async {

    await supabase
        .from('sharecode_first_aid')
        .delete()
        .eq(
          'id',
          id,
        );
  }

  /// =====================================================
  /// DELETE SIA LICENCE
  /// =====================================================

  Future<void> deleteSiaLicence(
    int id,
  ) async {

    await supabase
        .from('sia_licence')
        .delete()
        .eq(
          'id',
          id,
        );
  }

  /// =====================================================
  /// DELETE SIGNED DOCUMENTS
  /// =====================================================

  Future<void> deleteSignedDocuments(
    int id,
  ) async {

    await supabase
        .from('signed_documents')
        .delete()
        .eq(
          'id',
          id,
        );
  }
}