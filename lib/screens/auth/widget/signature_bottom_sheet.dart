import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:signature/signature.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

Future<Uint8List?> showSignatureSheet(
  BuildContext context, {

  required String title,

  required String documentPath,
}) async {
  return await showModalBottomSheet<Uint8List>(
    context: context,

    isScrollControlled: true,

    backgroundColor: Colors.transparent,

    builder: (_) => SignatureSheet(title: title, documentPath: documentPath),
  );
}

class SignatureSheet extends StatefulWidget {
  final String documentPath;
  final String title;

  const SignatureSheet({
    super.key,
    required this.documentPath,
    required this.title,
  });

  @override
  State<SignatureSheet> createState() => _SignatureSheetState();
}

class _SignatureSheetState extends State<SignatureSheet> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? signatureBytes;

Future<void> saveSignature() async {

  if (_controller.isEmpty) return;

  final signatureData =
      await _controller.toPngBytes();

  if (signatureData == null) return;

  /// LOAD DOCUMENT IMAGE
  final ByteData documentBytes =
      await rootBundle.load(
    widget.documentPath,
  );

  final Uint8List documentUint8 =
      documentBytes.buffer
          .asUint8List();

  /// DECODE
  final img.Image? documentImage =
      img.decodeImage(documentUint8);

  final img.Image? signatureImage =
      img.decodeImage(signatureData);

  if (documentImage == null ||
      signatureImage == null) {
    return;
  }

  /// RESIZE SIGNATURE
  final resizedSignature =
      img.copyResize(

    signatureImage,

    width: 180,

    height: 80,
  );

  /// ADD SIGNATURE
  img.compositeImage(

    documentImage,

    resizedSignature,

    dstX:
        documentImage.width - 240,

    dstY:
        documentImage.height - 180,
  );

  /// FINAL IMAGE
  final finalImage =
      Uint8List.fromList(

    img.encodePng(documentImage),
  );

  /// PREVIEW
  setState(() {

    signatureBytes = finalImage;
  });

  /// RETURN IMAGE
  Navigator.pop(
    context,
    finalImage,
  );
}
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: AppTextStyles.label.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),

              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// DOCUMENT PREVIEW
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: signatureBytes != null
                          ? Image.memory(signatureBytes!, fit: BoxFit.contain)
                          : Image.asset(
                              widget.documentPath,
                              fit: BoxFit.contain,
                            ),
                    ),
                  );
                },
              );
            },
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: signatureBytes != null
                    ? Image.memory(signatureBytes!, fit: BoxFit.contain)
                    : Image.asset(widget.documentPath, fit: BoxFit.contain),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// HEADER
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
                onTap: () {
                  _controller.clear();

                  setState(() {
                    signatureBytes = null;
                  });
                },
                child: Text(
                  "Clear",
                  style: AppTextStyles.small.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// SIGN PAD
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.grey.shade100,
            ),
          ),

          const SizedBox(height: 20),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Discard",
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: CustomButton(
                  text: "Save Signature",
                  onTap: saveSignature,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
