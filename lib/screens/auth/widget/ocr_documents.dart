import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:takedat_app/constant/first_aid_service.dart';
import 'package:takedat_app/constant/share_code_ocr_service.dart';
import 'package:takedat_app/constant/sia_ocr_service.dart';
import 'package:takedat_app/constant/act_ocr_service.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/utils/app_utils.dart';

class DocumentUploadData {
  final File? file; // mobile
  final Uint8List? bytes; // web
  final String fileName;
  final String documentNumber;
  final String holderName;
  final DateTime? expiryDate;

  DocumentUploadData({
    this.file,
    this.bytes,
    required this.fileName,
    required this.documentNumber,
    required this.holderName,
    required this.expiryDate,
  }) : assert(
         file != null || bytes != null,
         'Either file (mobile) or bytes (web) must be provided',
       );
}

class OCRDocumentCard extends StatefulWidget {
  final String title;
  final Function(DocumentUploadData data)? onUploaded;

  const OCRDocumentCard({
    super.key,
    required this.title,
    required this.onUploaded,
  });

  @override
  State<OCRDocumentCard> createState() => _OCRDocumentCardState();
}

class _OCRDocumentCardState extends State<OCRDocumentCard> {
  File? selectedImage;
  Uint8List? webImage;
  String fileName = '';

  bool isLoading = false;
  String documentNumber = '';
  String expiryDate = '';
  String holderName = '';
  bool uploaded = false;

  // ─────────────────────────────────────────────────────────
  /// Handles all date formats OCR can return:
  ///   "19.10.2025"  dd.MM.yyyy
  ///   "19/10/2025"  dd/MM/yyyy
  ///   "2025-10-19"  yyyy-MM-dd  (ISO)
  ///   "19 Oct 2025" dd MMM yyyy
  // ─────────────────────────────────────────────────────────
  DateTime? _parseDate(String raw) {
    final s = raw.trim();

    if (s.isEmpty) return null;

    print("RAW DATE => $s");

    /// =====================================================
    /// ISO FORMAT
    /// 2025-10-19
    /// =====================================================

    final iso = DateTime.tryParse(s);

    if (iso != null) {
      print("PARSED ISO => $iso");

      return iso;
    }

    /// =====================================================
    /// dd.MM.yyyy
    /// dd/MM/yyyy
    ///
    /// 19.10.2025
    /// 19/10/2025
    /// =====================================================

    final re1 = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$');

    final m1 = re1.firstMatch(s);

    if (m1 != null) {
      final date = DateTime.tryParse(
        '${m1.group(3)}-'
        '${m1.group(2)!.padLeft(2, '0')}-'
        '${m1.group(1)!.padLeft(2, '0')}',
      );

      print("PARSED NUMERIC => $date");

      return date;
    }

    /// =====================================================
    /// MONTH MAP
    /// =====================================================

    const months = {
      'jan': '01',
      'january': '01',

      'feb': '02',
      'february': '02',

      'mar': '03',
      'march': '03',

      'apr': '04',
      'april': '04',

      'may': '05',

      'jun': '06',
      'june': '06',

      'jul': '07',
      'july': '07',

      'aug': '08',
      'august': '08',

      'sep': '09',
      'sept': '09',
      'september': '09',

      'oct': '10',
      'october': '10',

      'nov': '11',
      'november': '11',

      'dec': '12',
      'december': '12',
    };

    /// =====================================================
    /// dd MMM yyyy
    /// dd MMMM yyyy
    ///
    /// 19 Oct 2025
    /// 18 January 2026
    /// 2 December 2025
    /// =====================================================

    final re2 = RegExp(r'^(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})$');

    final m2 = re2.firstMatch(s);

    if (m2 != null) {
      final monthText = m2.group(2)!.toLowerCase();

      final mon = months[monthText];

      if (mon != null) {
        final date = DateTime.tryParse(
          '${m2.group(3)}-'
          '$mon-'
          '${m2.group(1)!.padLeft(2, '0')}',
        );

        print("PARSED TEXT DATE => $date");

        return date;
      }
    }

    /// =====================================================
    /// FAILED
    /// =====================================================

    print("FAILED TO PARSE DATE => $s");

    return null;
  }

  // ─────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => isLoading = true);

    fileName = image.name;

    if (kIsWeb) {
      webImage = await image.readAsBytes();
    } else {
      selectedImage = File(image.path);
    }

    try {
      // ── OCR per document type ─────────────────────────────

      if (widget.title == "SIA Licence") {
        final r = await SIALicenceOCR.extractFromImage(image);
        documentNumber = r['documentNumber'] ?? '';
        expiryDate = r['expiryDate'] ?? '';
        holderName = r['holderName'] ?? '';
      } else if (widget.title == "Blue ACT Certification" ||
          widget.title == "Orange ACT Certification") {
        final r = await ACTCertificateOCR.extractFromImage(image);
        // completionDate IS the expiry for ACT certificates
        expiryDate = r['completionDate'] ?? '';
        holderName = r['holderName'] ?? '';
        documentNumber = expiryDate; // show date as doc number on card
      } else if (widget.title == "Share Code") {
        final r = await ShareCodeOCR.extractFromImage(image);
        documentNumber = r['shareCode'] ?? '';
        expiryDate = r['validUntil'] ?? '';
        holderName = r['holderName'] ?? '';
      } else if (widget.title == "First Aid Certification") {
        final r = await FirstAidCertOCR.extractFromImage(image);
        documentNumber = r['certificateNumber'] ?? '';
        expiryDate = r['awardedDate'] ?? '';
        holderName = r['holderName'] ?? '';
      }

      // ── Parse date (handles dd.MM.yyyy, dd/MM/yyyy, ISO, etc.)
      final parsedExpiry = _parseDate(expiryDate);

      /// =====================================================
      /// EXPIRED DOCUMENT CHECK
      /// =====================================================

      // if (parsedExpiry != null) {
      //   final now = DateTime.now();

      //   final today = DateTime(now.year, now.month, now.day);

      //   final expiry = DateTime(
      //     parsedExpiry.year,
      //     parsedExpiry.month,
      //     parsedExpiry.day,
      //   );

      //   /// EXPIRED OR TODAY
      //   if (expiry.isBefore(today) || expiry.isAtSameMomentAs(today)) {
      //     setState(() {
      //       /// RESET EVERYTHING
      //       uploaded = false;

      //       isLoading = false;

      //       selectedImage = null;

      //       webImage = null;

      //       documentNumber = '';

      //       expiryDate = '';

      //       holderName = '';

      //       fileName = '';
      //     });

      //     AppUtils.showDialogMessage(
      //       context,

      //       title: "Document Expired",

      //       message:
      //           "${widget.title} has expired. Please upload a valid document.",

      //       buttonText: "Upload Again",
      //     );

      //     return;
      //   }
      // }

      // ── Fire callback — web AND mobile ────────────────────

      if (kIsWeb && webImage != null) {
        widget.onUploaded?.call(
          DocumentUploadData(
            bytes: webImage,
            fileName: fileName,
            documentNumber: documentNumber,
            holderName: holderName,
            expiryDate: parsedExpiry,
          ),
        );
      } else if (!kIsWeb && selectedImage != null) {
        widget.onUploaded?.call(
          DocumentUploadData(
            file: selectedImage,
            fileName: fileName,
            documentNumber: documentNumber,
            holderName: holderName,
            expiryDate: parsedExpiry,
          ),
        );
      }

      setState(() {
        uploaded = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    uploaded ? Icons.check_circle : Icons.description,
                    color: uploaded ? Colors.green : AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.label.copyWith(
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (documentNumber.isNotEmpty)
                        Text('No: $documentNumber', style: AppTextStyles.small),

                      if (expiryDate.isNotEmpty)
                        Text('Expiry: $expiryDate', style: AppTextStyles.small),

                      if (holderName.isNotEmpty)
                        Text('Name: $holderName', style: AppTextStyles.small),

                      if (isLoading)
                        Row(
                          children: [
                            const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Processing OCR...',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                      if (!isLoading && !uploaded && documentNumber.isEmpty)
                        Text(
                          'Tap to upload document',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                Icon(
                  uploaded ? Icons.verified : Icons.upload,
                  color: uploaded ? Colors.green : Colors.black54,
                ),
              ],
            ),

            // ── Image preview ─────────────────────────────────
            /// ─────────────────────────────────────────────────
            /// IMAGE PREVIEW
            /// ─────────────────────────────────────────────────
            if (selectedImage != null || webImage != null) ...[
              const SizedBox(height: 14),

              Stack(
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),

                    child: kIsWeb
                        ? Image.memory(
                            webImage!,

                            height: 180,

                            width: double.infinity,

                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            selectedImage!,

                            height: 180,

                            width: double.infinity,

                            fit: BoxFit.cover,
                          ),
                  ),

                  /// PREVIEW BADGE
                  Positioned(
                    top: 10,
                    right: 10,

                    child: GestureDetector(
                      onTap: _showPreview,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.black87,

                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 18,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "Preview",

                              style: AppTextStyles.small.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────
  /// FULLSCREEN PREVIEW
  /// ─────────────────────────────────────────────────

  void _showPreview() {
    showDialog(
      context: context,

      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,

          insetPadding: const EdgeInsets.all(12),

          child: Stack(
            children: [
              /// IMAGE
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,

                child: Center(
                  child: kIsWeb
                      ? Image.memory(webImage!, fit: BoxFit.contain)
                      : Image.file(selectedImage!, fit: BoxFit.contain),
                ),
              ),

              /// CLOSE BUTTON
              Positioned(
                top: 12,
                right: 12,

                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: Container(
                    padding: const EdgeInsets.all(8),

                    decoration: const BoxDecoration(
                      color: Colors.black54,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
