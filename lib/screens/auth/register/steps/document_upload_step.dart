import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

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
          _docItem("Blue ACT Certification", "Expires: 12/2025"),
          _docItem("Orange ACT Certification", "Expires: 08/2026"),
          _docItem("SIA Licence", "Expires: 05/2027"),
          _docItem("Share Code", "Expires: 01/2025"),
          _docItem("First Aid Certification", "Expires: 11/2026"),

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

  /// ============================
  /// 🔹 DOCUMENT ITEM
  /// ============================
  Widget _docItem(String title, String expiry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          /// ICON BOX
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
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  expiry,
                  style: AppTextStyles.small.copyWith(color: Colors.black54),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Processing...",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// MENU
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
