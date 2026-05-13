import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/signature_bottom_sheet.dart';

class SignDocumentsStep extends StatelessWidget {
  final VoidCallback onComplete;

  const SignDocumentsStep({super.key, required this.onComplete});

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
              Text(
                "STEP 3 OF 3",
                style: AppTextStyles.small.copyWith(color: AppColors.primary),
              ),
              Text(
                "Finalizing Account",
                style: AppTextStyles.small.copyWith(color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: Color(0xFFE0E0E0),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 TITLE
          Text(
            "Sign Documents",
            style: AppTextStyles.headline.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Please review and electronically sign the following agreements to complete your registration.",
            style: AppTextStyles.label.copyWith(color: Colors.black54),
          ),

          const SizedBox(height: 12),

          /// 🔹 CARDS
          _docCard(
            onTap: () {
              showSignatureSheet(context);
            },
            title: "Customer Agreement",
            description:
                "The terms and conditions governing your account relationship and service usage.",
          ),

          _docCard(
            onTap: () {
              showSignatureSheet(context);
            },
            title: "Privacy Policy",
            description:
                "Detailed disclosure on how we collect, use, and protect your personal financial data.",
          ),

          const SizedBox(height: 12),

          /// 🔹 GREEN INFO CARD
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Encryption Secured\n256-bit AES Digital Signatures",
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                ),
                const Icon(Icons.verified, color: Colors.white, size: 40),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 SMALL TEXT
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 14, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                "Your information is securely encrypted",
                style: AppTextStyles.small.copyWith(color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 12),

          CustomButton(text: "Complete Registration", onTap: onComplete),
        ],
      ),
    );
  }

  /// ============================
  /// 🔹 DOCUMENT CARD
  /// ============================
  Widget _docCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER ROW
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, size: 18),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.label.copyWith(color: Colors.black),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "REQUIRED",
                  style: AppTextStyles.small.copyWith(
                    color: Colors.red,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: AppTextStyles.small.copyWith(color: Colors.black54),
          ),

          const SizedBox(height: 12),

          /// BUTTON
          InkWell(
            onTap: onTap,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black26),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: Text(
                  "Review & Sign",
                  style: AppTextStyles.label.copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
