import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/constant/first_aid_service.dart';
import 'package:takedat_app/constant/share_code_ocr_service.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

import 'package:takedat_app/constant/sia_ocr_service.dart';

import '../../../constant/act_ocr_service.dart';

class OCRDocumentCard extends StatefulWidget {
  final String title;

  const OCRDocumentCard({super.key, required this.title});

  @override
  State<OCRDocumentCard> createState() => _OCRDocumentCardState();
}

class _OCRDocumentCardState extends State<OCRDocumentCard> {
  /// MOBILE IMAGE
  File? selectedImage;

  /// WEB IMAGE
  Uint8List? webImage;

  bool isLoading = false;

  String documentNumber = '';
  String expiryDate = '';
  String holderName = '';

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      isLoading = true;
    });

    /// WEB
    if (kIsWeb) {
      webImage = await image.readAsBytes();
    }
    /// MOBILE
    else {
      selectedImage = File(image.path);
    }

    /// OCR PROCESS
    if (widget.title == "SIA Licence") {
      final result = await SIALicenceOCR.extractFromImage(image);

      setState(() {
        documentNumber = result['documentNumber'] ?? '';
        expiryDate = result['expiryDate'] ?? '';
        holderName = result['holderName'] ?? '';
        isLoading = false;
      });
    }

    if (widget.title == "Blue ACT Certification" ||
        widget.title == "Orange ACT Certification") {
      final result = await ACTCertificateOCR.extractFromImage(image);

      setState(() {
        documentNumber = result['completionDate'] ?? ''; // reuse existing field
        expiryDate = ''; // not on this cert
        holderName = result['holderName'] ?? '';
        isLoading = false;
      });
    }
    if (widget.title == "Share Code") {
      final result = await ShareCodeOCR.extractFromImage(image);

      setState(() {
        documentNumber = result['shareCode'] ?? '';
        expiryDate = result['validUntil'] ?? '';
        isLoading = false;
      });
    }
    if (widget.title == "First Aid Certification") {
      final result = await FirstAidCertOCR.extractFromImage(image);

      setState(() {
        documentNumber = result['certificateNumber'] ?? '';
        expiryDate = result['awardedDate'] ?? '';
        holderName = result['holderName'] ?? '';
        result['centre'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            /// TOP ROW
            Row(
              children: [
                /// ICON
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description, size: 18),
                ),

                const SizedBox(width: 12),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        widget.title,
                        style: AppTextStyles.label.copyWith(
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// DOCUMENT NUMBER
                      if (documentNumber.isNotEmpty)
                        Text('No: $documentNumber', style: AppTextStyles.small),

                      /// EXPIRY DATE
                      if (expiryDate.isNotEmpty)
                        Text('Expiry: $expiryDate', style: AppTextStyles.small),

                      /// HOLDER NAME
                      if (holderName.isNotEmpty)
                        Text('Name: $holderName', style: AppTextStyles.small),

                      /// LOADING
                      if (isLoading)
                        Row(
                          children: [
                            const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Processing...',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                      /// DEFAULT
                      if (!isLoading && documentNumber.isEmpty)
                        Text(
                          'Tap to upload',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                /// UPLOAD ICON
                const Icon(Icons.upload),
              ],
            ),

            /// IMAGE PREVIEW
            if (selectedImage != null || webImage != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    /// WEB IMAGE
                    ? Image.memory(
                        webImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    /// MOBILE IMAGE
                    : Image.file(
                        selectedImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
