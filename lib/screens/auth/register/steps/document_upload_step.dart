import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

import '../../widget/ocr_documents.dart';

class DocumentUploadStep extends StatelessWidget {
  final VoidCallback onNext;
  const DocumentUploadStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 PROGRESS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Step 2 of 3", style: AppTextStyles.small),
              Text(
                "66% Complete",
                style: AppTextStyles.small.copyWith(color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.66,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: Colors.grey.shade300,
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 TITLE
          Text(
            "Upload Documents",
            style: AppTextStyles.headline.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Please provide 5 identity or residency documents for OCR verification to secure your account.",
            style: AppTextStyles.label.copyWith(color: Colors.black54),
          ),

          const SizedBox(height: 12),

          /// 🔹 DOCUMENT LIST
          OCRDocumentCard(title: "Blue ACT Certification"),

          OCRDocumentCard(title: "Orange ACT Certification"),

          OCRDocumentCard(title: "SIA Licence"),

          OCRDocumentCard(title: "Share Code"),

          OCRDocumentCard(title: "First Aid Certification"),

          const SizedBox(height: 12),

          /// 🔹 CONTINUE BUTTON (DISABLED)
          CustomButton(
            text: "Continue",
            icon: Icons.arrow_forward,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}
