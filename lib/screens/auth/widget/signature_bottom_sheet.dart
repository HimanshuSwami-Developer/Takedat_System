import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

void showSignatureSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SignatureSheet(),
  );
}

class SignatureSheet extends StatefulWidget {
  const SignatureSheet({super.key});

  @override
  State<SignatureSheet> createState() => _SignatureSheetState();
}

class _SignatureSheetState extends State<SignatureSheet> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// 🔹 TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Review & Sign",
                style: AppTextStyles.label.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// 🔹 DOCUMENT PREVIEW
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: const Center(
              child: Text("300 x 300"),
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 DRAW HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DRAW YOUR SIGNATURE",
                style: AppTextStyles.small.copyWith(
                  letterSpacing: 1,
                  color: Colors.black54,
                ),
              ),
              GestureDetector(
                onTap: () => _controller.clear(),
                child: Text(
                  "Clear",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔹 SIGNATURE PAD
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.grey.shade100,
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Discard",style: AppTextStyles.label.copyWith(color: AppColors.primary),),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: "Save Signature",
                  onTap: () async {
                    if (_controller.isNotEmpty) {
                      final data = await _controller.toPngBytes();

                      /// 👉 You can store or send this image
                      print("Signature saved: ${data?.length}");
                      context.pop();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}