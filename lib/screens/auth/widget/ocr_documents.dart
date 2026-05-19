import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
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
  Uint8List? webImage; // always holds compressed bytes
  String fileName = '';

  bool isLoading = false;
  String documentNumber = '';
  String expiryDate = '';
  String holderName = '';
  bool uploaded = false;

  // ─────────────────────────────────────────────────────────
  /// Compress to ≤ targetSizeKB.
  /// Step 1 — quality loop at full resolution.
  /// Step 2 — downscale + quality loop.
  /// Fallback — smallest possible output.
  // ─────────────────────────────────────────────────────────
  Future<Uint8List> _compressToTargetSize(
    Uint8List originalBytes, {
    int targetSizeKB = 100,
    int minQuality = 10,
  }) async {
    final targetBytes = targetSizeKB * 1024;

    final image = img.decodeImage(originalBytes);
    if (image == null) return originalBytes;

    // Step 1 — quality only
    for (int quality = 85; quality >= minQuality; quality -= 10) {
      final compressed = img.encodeJpg(image, quality: quality);
      if (compressed.length <= targetBytes) {
        print(
          'Compressed at quality=$quality → '
          '${(compressed.length / 1024).toStringAsFixed(1)} KB',
        );
        return Uint8List.fromList(compressed);
      }
    }

    // Step 2 — downscale + quality
    double scale = 0.8;
    while (scale >= 0.2) {
      final resized = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
      for (int quality = 85; quality >= minQuality; quality -= 15) {
        final compressed = img.encodeJpg(resized, quality: quality);
        if (compressed.length <= targetBytes) {
          print(
            'Compressed at scale=${scale.toStringAsFixed(1)} '
            'quality=$quality → '
            '${(compressed.length / 1024).toStringAsFixed(1)} KB',
          );
          return Uint8List.fromList(compressed);
        }
      }
      scale -= 0.2;
    }

    // Fallback
    final fallback = img.encodeJpg(
      img.copyResize(image, width: (image.width * 0.2).round()),
      quality: minQuality,
    );
    return Uint8List.fromList(fallback);
  }

  // ─────────────────────────────────────────────────────────
  /// Date parser — handles dd.MM.yyyy / dd/MM/yyyy / ISO / dd MMM yyyy
  // ─────────────────────────────────────────────────────────
  DateTime? _parseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    print("RAW DATE => $s");

    final iso = DateTime.tryParse(s);
    if (iso != null) {
      print("PARSED ISO => $iso");
      return iso;
    }

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

    const months = {
      'jan': '01', 'january': '01',
      'feb': '02', 'february': '02',
      'mar': '03', 'march': '03',
      'apr': '04', 'april': '04',
      'may': '05',
      'jun': '06', 'june': '06',
      'jul': '07', 'july': '07',
      'aug': '08', 'august': '08',
      'sep': '09', 'sept': '09', 'september': '09',
      'oct': '10', 'october': '10',
      'nov': '11', 'november': '11',
      'dec': '12', 'december': '12',
    };

    final re2 = RegExp(r'^(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})$');
    final m2 = re2.firstMatch(s);
    if (m2 != null) {
      final mon = months[m2.group(2)!.toLowerCase()];
      if (mon != null) {
        final date = DateTime.tryParse(
          '${m2.group(3)}-$mon-${m2.group(1)!.padLeft(2, '0')}',
        );
        print("PARSED TEXT DATE => $date");
        return date;
      }
    }

    print("FAILED TO PARSE DATE => $s");
    return null;
  }

  // ─────────────────────────────────────────────────────────
  /// Bottom sheet — Camera / Gallery
  // ─────────────────────────────────────────────────────────
  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Upload Document",
              style: AppTextStyles.label.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 6),
            Text(
              "Choose how you'd like to add your document",
              style: AppTextStyles.small.copyWith(color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // ── Camera ──────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Camera",
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Take a photo",
                            style: AppTextStyles.small.copyWith(
                              color: Colors.black38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // ── Gallery ──────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library_rounded,
                              color: Colors.black54,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Gallery",
                            style: AppTextStyles.label.copyWith(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Choose existing",
                            style: AppTextStyles.small.copyWith(
                              color: Colors.black38,
                              fontSize: 11,
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
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  /// Main pick + compress + OCR flow
  // ─────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      // On web, camera source triggers the browser's camera capture
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return;

    setState(() => isLoading = true);
    fileName = image.name;

    try {
      // ── 1. Read original bytes ────────────────────────────
      final originalBytes = await image.readAsBytes();
      print('Original: ${(originalBytes.length / 1024).toStringAsFixed(1)} KB');

      // ── 2. Compress ONCE — reused for preview + upload ───
      final compressedBytes = await _compressToTargetSize(
        originalBytes,
        targetSizeKB: 100,
      );
      print(
        'Final compressed: '
        '${(compressedBytes.length / 1024).toStringAsFixed(1)} KB',
      );

      // ── 3. Store compressed bytes for preview & callback ─
      if (kIsWeb) {
        webImage = compressedBytes;
      } else {
        // Write compressed bytes to a temp file on mobile
        final tempDir = Directory.systemTemp;
        final tempPath = '${tempDir.path}/${image.name}';
        selectedImage = await File(tempPath).writeAsBytes(compressedBytes);
      }

      // ── 4. OCR — pass original XFile (OCR service reads it)
      //    but the stored bytes/file are already compressed ──
      if (widget.title == "SIA Licence") {
        final r = await SIALicenceOCR.extractFromImage(image);
        documentNumber = r['documentNumber'] ?? '';
        expiryDate = r['expiryDate'] ?? '';
        holderName = r['holderName'] ?? '';
      } else if (widget.title == "Blue ACT Certification" ||
          widget.title == "Orange ACT Certification") {
        final r = await ACTCertificateOCR.extractFromImage(image);
        expiryDate = r['completionDate'] ?? '';
        holderName = r['holderName'] ?? '';
        documentNumber = expiryDate;
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

      // ── 5. Parse date ─────────────────────────────────────
      final parsedExpiry = _parseDate(expiryDate);

      // ── 6. Expired check ──────────────────────────────────
      if (parsedExpiry != null) {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final expiry = DateTime(
          parsedExpiry.year,
          parsedExpiry.month,
          parsedExpiry.day,
        );

        if (expiry.isBefore(today) || expiry.isAtSameMomentAs(today)) {
          setState(() {
            uploaded = false;
            isLoading = false;
            selectedImage = null;
            webImage = null;
            documentNumber = '';
            expiryDate = '';
            holderName = '';
            fileName = '';
          });

          AppUtils.showDialogMessage(
            context,
            title: "Document Expired",
            message:
                "${widget.title} has expired. Please upload a valid document.",
            buttonText: "Upload Again",
          );
          return;
        }
      }

      // ── 7. Fire callback with COMPRESSED bytes / file ────
      if (kIsWeb && webImage != null) {
        widget.onUploaded?.call(
          DocumentUploadData(
            bytes: webImage, // ✅ compressed
            fileName: fileName,
            documentNumber: documentNumber,
            holderName: holderName,
            expiryDate: parsedExpiry,
          ),
        );
      } else if (!kIsWeb && selectedImage != null) {
        widget.onUploaded?.call(
          DocumentUploadData(
            file: selectedImage, // ✅ compressed temp file
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
      print('pickImage error: $e');
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
            if (selectedImage != null || webImage != null) ...[
              const SizedBox(height: 14),

              Stack(
                children: [
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

  // ─────────────────────────────────────────────────────────
  /// Fullscreen preview
  // ─────────────────────────────────────────────────────────
  void _showPreview() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: kIsWeb
                    ? Image.memory(webImage!, fit: BoxFit.contain)
                    : Image.file(selectedImage!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
      ),
    );
  }
}