import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/models/signed_document_model.dart';
import 'package:takedat_app/models/users_model.dart';
import 'dart:html' as html;

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

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

    String? companyCode,
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
          company_code,
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
        ).eq(
          'role',
          'employee',
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

    if (companyCode != null && companyCode.isNotEmpty) {
      query = query.eq('company_code', companyCode);
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
          company_code,
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


    /// ======================================================
  /// DOWNLOAD COMPLETE DOCUMENTS BUCKET
  /// ======================================================
 
  Future<void>
      downloadDocumentsBucket() async {

    /// ALL FILES
    final List<Map<String, dynamic>>
        allFiles = [];

    /// ===================================================
    /// FETCH FILES RECURSIVELY
    /// ===================================================

    Future<void> fetchFiles(
      String path,
    ) async {

      final files = await supabase
          .storage
          .from('documents')
          .list(
            path: path,
          );

      for (final file in files) {

        /// ===============================================
        /// FOLDER
        /// ===============================================

        if (file.id == null) {

          final folderPath =

              path.isEmpty

                  ? file.name

                  : '$path/${file.name}';

          await fetchFiles(
            folderPath,
          );
        }

        /// ===============================================
        /// FILE
        /// ===============================================

        else {

          allFiles.add({

            'path':

                path.isEmpty

                    ? file.name

                    : '$path/${file.name}',
          });
        }
      }
    }

    /// START FETCH
    await fetchFiles('');

    if (allFiles.isEmpty) {

      throw Exception(
        "No files found in documents bucket",
      );
    }

    /// ===================================================
    /// CREATE ZIP
    /// ===================================================

    final archive = Archive();

    for (final item in allFiles) {

      try {

        final path =
            item['path'];

        /// PUBLIC URL
        final publicUrl =
            supabase.storage
                .from('documents')
                .getPublicUrl(path);

        /// DOWNLOAD FILE
        final response =
            await http.get(
          Uri.parse(publicUrl),
        );

        if (response.statusCode == 200) {

          archive.addFile(

            ArchiveFile(

              path,

              response.bodyBytes.length,

              response.bodyBytes,
            ),
          );
        }
      }

      catch (e) {

        debugPrint(
          'ZIP FILE ERROR => $e',
        );
      }
    }

    /// ===================================================
    /// ZIP ENCODE
    /// ===================================================

    final zipData =
        ZipEncoder().encode(
      archive,
    );

    /// ===================================================
    /// DOWNLOAD ZIP
    /// ===================================================

    final bytes =
        Uint8List.fromList(
      zipData,
    );

    final blob = html.Blob(

      [bytes],

      'application/zip',
    );

    final url =
        html.Url
            .createObjectUrlFromBlob(
      blob,
    );

    final timestamp =
        DateTime.now()
            .millisecondsSinceEpoch;

    final fileName =
        'employee_documents_$timestamp.zip';

    final anchor =
        html.AnchorElement(
          href: url,
        )

          ..style.display = 'none'

          ..download = fileName;

    html.document.body
        ?.children
        .add(anchor);

    /// DOWNLOAD
    anchor.click();

    /// CLEANUP
    anchor.remove();

    html.Url
        .revokeObjectUrl(url);
  }

}