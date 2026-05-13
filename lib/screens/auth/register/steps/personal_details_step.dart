import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';

class PersonalDetailsStep extends StatelessWidget {
  final VoidCallback onNext;

  const PersonalDetailsStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 STEP TITLE
          Text(
            "STEP 1 OF 3",
            style: AppTextStyles.small.copyWith(color: AppColors.primary),
          ),

          const SizedBox(height: 6),

          Text(
            "Personal Details",
            style: AppTextStyles.headline.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Please provide your legal information as it appears on your official documents.",
            style: AppTextStyles.small.copyWith(color: Colors.black54),
          ),

          const SizedBox(height: 20),

          CustomTextField(
            label: "Full Name",
            hint: "Johnathan Doe",
            icon: Icons.person,
          ),

          CustomTextField(
            label: "Email Address",
            hint: "john@example.com",
            icon: Icons.email,
          ),

          CustomTextField(
            label: "Contact Number",
            hint: "+91 9876543210",
            icon: Icons.phone,
          ),

          CustomTextField(
            label: "Physical Address",
            hint: "123 Business Way, NY",
            isTextArea: true,
          ),
          const SizedBox(height: 16),

          /// 🔹 INFO BOX
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This information will be used for identity verification.",
                    style: AppTextStyles.small.copyWith(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          /// 🔹 BUTTON
          CustomButton(
            text: "Continue",
            icon: Icons.arrow_forward,
            onTap: onNext,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
