import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/ocr_documents.dart';

import '../../../../constant/session_keys.dart';
import '../../../../constant/session_manager.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class DocumentUploadStep extends StatefulWidget {
  final VoidCallback onNext;

  const DocumentUploadStep({
    super.key,
    required this.onNext,
  });

  @override
  State<DocumentUploadStep> createState() => _DocumentUploadStepState();
}

class _DocumentUploadStepState extends State<DocumentUploadStep> {

  // =====================================================
  // FLAGS
  // =====================================================
  bool blueActDone   = false;
  bool orangeActDone = false;
  bool siaDone       = false;
  bool shareCodeDone = false;
  bool firstAidDone  = false;
  bool isUploading   = false;

  // =====================================================
  // TRACK COMPLETED EVENTS
  // =====================================================
  int _completedEvents = 0;
  static const int _totalEvents = 3;

  // =====================================================
  // SESSION
  // =====================================================
  String userId    = "";
  String userEmail = "";
  bool sessionLoaded = false;

  // =====================================================
  // BLUE ACT
  // =====================================================
  File?      _blueFile;
  Uint8List? _blueBytes;
  String?    _blueFileName;
  String?    _blueName;
  DateTime?  _blueExpiry;

  // =====================================================
  // ORANGE ACT
  // =====================================================
  File?      _orangeFile;
  Uint8List? _orangeBytes;
  String?    _orangeFileName;
  String?    _orangeName;
  DateTime?  _orangeExpiry;

  // =====================================================
  // SIA
  // =====================================================
  File?      _siaFile;
  Uint8List? _siaBytes;
  String?    _siaFileName;
  String?    _siaHolderName;
  String?    _siaNumber;
  DateTime?  _siaExpiry;

  // =====================================================
  // SHARECODE
  // =====================================================
  File?      _sharecodeFile;
  Uint8List? _sharecodeBytes;
  String?    _sharecodeFileName;
  String?    _sharecodeNumber;
  String?    _sharecodeHolderName;
  DateTime?  _sharecodeExpiry;

  // =====================================================
  // FIRST AID
  // =====================================================
  File?      _firstAidFile;
  Uint8List? _firstAidBytes;
  String?    _firstAidFileName;
  String?    _firstAidHolderName;
  DateTime?  _firstAidExpiry;

  bool get allUploaded =>
      blueActDone &&
      orangeActDone &&
      siaDone &&
      shareCodeDone &&
      firstAidDone;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    userId    = await SessionManager.getString(SessionKeys.userId);
    userEmail = await SessionManager.getString(SessionKeys.email);
    setState(() => sessionLoaded = true);
  }

  // =====================================================
  // SUBMIT — only fires SIA first
  // ACT and SHARECODE fire sequentially via BlocListener
  // =====================================================
  Future<void> _submitAllDocuments() async {
    if (!allUploaded) return;

    setState(() {
      isUploading      = true;
      _completedEvents = 0;
    });

    // Fire ONLY first event here
    context.read<RegisterBloc>().add(
      SaveSiaLicenceEvent(
        userId:        userId,
        userEmail:     userEmail,
        file:          _siaFile,
        bytes:         _siaBytes,
        fileName:      _siaFileName,
        holderName:    _siaHolderName ?? '',
        licenceNumber: _siaNumber ?? '',
        expiry:        _siaExpiry!,
      ),
    );
  }

  int _progress() {
    int done = 0;
    if (blueActDone)   done++;
    if (orangeActDone) done++;
    if (siaDone)       done++;
    if (shareCodeDone) done++;
    if (firstAidDone)  done++;
    return ((done / 5) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {

        if (state is RegisterFailure) {
          setState(() => isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }

        if (state is RegisterSuccess) {
          _completedEvents++;

          // =====================================================
          // SIA done → fire ACT
          // =====================================================
          if (_completedEvents == 1) {
            context.read<RegisterBloc>().add(
              SaveActCertificateEvent(
                userId:           userId,
                userEmail:        userEmail,
                blueFile:         _blueFile,
                orangeFile:       _orangeFile,
                blueBytes:        _blueBytes,
                orangeBytes:      _orangeBytes,
                blueFileName:     _blueFileName,
                orangeFileName:   _orangeFileName,
                blueHolderName:   _blueName,
                orangeHolderName: _orangeName,
                blueExpiry:       _blueExpiry,
                orangeExpiry:     _orangeExpiry,
              ),
            );
          }

          // =====================================================
          // ACT done → fire SHARECODE + FIRSTAID
          // =====================================================
          else if (_completedEvents == 2) {
            context.read<RegisterBloc>().add(
              SaveSharecodeFirstAidEvent(
                userId:              userId,
                userEmail:           userEmail,
                sharecodeFile:       _sharecodeFile,
                firstAidFile:        _firstAidFile,
                sharecodeBytes:      _sharecodeBytes,
                firstAidBytes:       _firstAidBytes,
                sharecodeFileName:   _sharecodeFileName,
                firstAidFileName:    _firstAidFileName,
                sharecodeNumber:     _sharecodeNumber,
                sharecodeHolderName: _sharecodeHolderName,
                sharecodeExpiry:     _sharecodeExpiry,
                firstAidHolderName:  _firstAidHolderName,
                firstAidExpiry:      _firstAidExpiry,
              ),
            );
          }

          // =====================================================
          // ALL DONE → go to next step
          // =====================================================
          else if (_completedEvents == _totalEvents) {
            setState(() => isUploading = false);
            widget.onNext();
          }
        }
      },

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("STEP 2 OF 3",
                    style: AppTextStyles.small.copyWith(color: AppColors.primary)),
                Text("${_progress()}% Complete",
                    style: AppTextStyles.small.copyWith(color: AppColors.primary)),
              ],
            ),

            const SizedBox(height: 6),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress() / 100,
                minHeight: 6,
                color: AppColors.primary,
                backgroundColor: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 20),

            Text("Upload Documents",
                style: AppTextStyles.headline.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                )),

            const SizedBox(height: 6),

            Text("Upload all required documents for verification.",
                style: AppTextStyles.label.copyWith(color: Colors.black54)),

            const SizedBox(height: 16),

            // BLUE ACT
            OCRDocumentCard(
              title: "Blue ACT Certification",
              onUploaded: (data) {
                _blueFile     = data.file;
                _blueBytes    = data.bytes;
                _blueFileName = data.fileName;
                _blueName     = data.holderName;
                _blueExpiry   = data.expiryDate;
                setState(() => blueActDone = true);
              },
            ),

            // ORANGE ACT
            OCRDocumentCard(
              title: "Orange ACT Certification",
              onUploaded: (data) {
                _orangeFile     = data.file;
                _orangeBytes    = data.bytes;
                _orangeFileName = data.fileName;
                _orangeName     = data.holderName;
                _orangeExpiry   = data.expiryDate;
                setState(() => orangeActDone = true);
              },
            ),

            // SIA
            OCRDocumentCard(
              title: "SIA Licence",
              onUploaded: (data) {
                _siaFile       = data.file;
                _siaBytes      = data.bytes;
                _siaFileName   = data.fileName;
                _siaHolderName = data.holderName;
                _siaNumber     = data.documentNumber;
                _siaExpiry     = data.expiryDate;
                setState(() => siaDone = true);
              },
            ),

            // SHARECODE
            OCRDocumentCard(
              title: "Share Code",
              onUploaded: (data) {
                _sharecodeFile       = data.file;
                _sharecodeBytes      = data.bytes;
                _sharecodeFileName   = data.fileName;
                _sharecodeNumber     = data.documentNumber;
                _sharecodeHolderName = data.holderName;
                _sharecodeExpiry     = data.expiryDate;
                setState(() => shareCodeDone = true);
              },
            ),

            // FIRST AID
            OCRDocumentCard(
              title: "First Aid Certification",
              onUploaded: (data) {
                _firstAidFile       = data.file;
                _firstAidBytes      = data.bytes;
                _firstAidFileName   = data.fileName;
                _firstAidHolderName = data.holderName;
                _firstAidExpiry     = data.expiryDate;
                setState(() => firstAidDone = true);
              },
            ),

            const SizedBox(height: 20),

            // INFO BOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your uploaded files are securely encrypted.",
                      style: AppTextStyles.small.copyWith(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON
            CustomButton(
              text: isUploading ? "Uploading..." : "Continue",
              icon: Icons.arrow_forward,
              onTap: allUploaded && !isUploading
                  ? _submitAllDocuments
                  : null,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}