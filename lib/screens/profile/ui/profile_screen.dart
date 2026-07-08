import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/constant/session_keys.dart';
import 'package:takedat_app/constant/session_manager.dart';
import 'package:takedat_app/core/app_colors.dart';

import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/repository/profile_repo.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

import 'package:takedat_app/screens/auth/widget/ocr_documents.dart';
import 'package:takedat_app/screens/profile/bloc/profile_bloc.dart';
import 'package:takedat_app/screens/profile/bloc/profile_event.dart';
import 'package:takedat_app/screens/profile/bloc/profile_state.dart';
import 'package:takedat_app/utils/app_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final primaryGreen = AppColors.primary;

  double downloadProgress = 0;
  String downloadMessage = "";
  bool isDownloading = false;
  String userId = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    userId = await SessionManager.getString(SessionKeys.userId);
    userEmail = await SessionManager.getString(SessionKeys.email);

    if (mounted) {
      context.read<ProfileBloc>().add(LoadProfileEvent(userId: userId));
    }
  }

  /// =====================================================
  /// DOCUMENT UPDATE SHEET
  /// Opens an OCRDocumentCard in a bottom sheet.
  /// On upload, fires the correct bloc event.
  /// =====================================================

  void _showUpdateSheet({
    required String title,
    required String documentType,
    required ActCertificateModel? act,
    required SharecodeFirstAidModel? shareFirstAid,
    required SiaLicenceModel? sia,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: _UpdateDocumentSheet(
            title: title,
            documentType: documentType,
            userId: userId,
            userEmail: userEmail,
            act: act,
            shareFirstAid: shareFirstAid,
            sia: sia,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F2),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is DocumentUpdateSuccess) {
            Navigator.pop(context); // close bottom sheet

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${state.documentType} updated successfully!"),
                backgroundColor: primaryGreen,
              ),
            );

            // Reload profile so UI reflects new data
            context.read<ProfileBloc>().add(LoadProfileEvent(userId: userId));
          }

          if (state is ProfileFailure) {
            AppToast.error(context, state.error);
            context.read<ProfileBloc>().add(LoadProfileEvent(userId: userId));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // ProfileLoaded OR DocumentUpdating/DocumentUpdateSuccess
          // — keep showing profile data through sub-states
          final loaded = _resolveLoaded(state);
          if (loaded == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = loaded.user;
          final act = loaded.actCertificate;
          final shareFirstAid = loaded.sharecodeFirstAid;
          final sia = loaded.siaLicence;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // ─── PROFILE CARD ──────────────────────────
                  _profileCard(user),

                  const SizedBox(height: 22),

                  // ─── DOCUMENTS HEADER ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Documents",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ─── ORANGE ACT ───────────────────────────
                  _documentTile(
                    title: "Act Orange",
                    expiry: act?.actOrangeExpiry,
                    holderName: act?.orangeHolderName,
                    onUpdate: () => _showUpdateSheet(
                      title: "Orange ACT Certification",
                      documentType: "ACT_ORANGE",
                      act: act,
                      shareFirstAid: shareFirstAid,
                      sia: sia,
                    ),
                    documentUrl: act?.actOrangeUrl,
                  ),

                  // ─── BLUE ACT ─────────────────────────────
                  _documentTile(
                    title: "Act Blue",
                    expiry: act?.actBlueExpiry,
                    holderName: act?.blueHolderName,
                    onUpdate: () => _showUpdateSheet(
                      title: "Blue ACT Certification",
                      documentType: "ACT_BLUE",
                      act: act,
                      shareFirstAid: shareFirstAid,
                      sia: sia,
                    ),
                    documentUrl: act?.actBlueUrl,
                  ),

                  // ─── SIA ─────────────────────────────────
                  _documentTile(
                    title: "SIA License",
                    expiry: sia?.siaLicenceExpiry,
                    holderName: sia?.siaHolderName,
                    docNumber: sia?.siaLicenceNumber,
                    onUpdate: () => _showUpdateSheet(
                      title: "SIA Licence",
                      documentType: "SIA",
                      act: act,
                      shareFirstAid: shareFirstAid,
                      sia: sia,
                    ),
                    documentUrl: sia?.url,
                  ),

                  // ─── SHARECODE ────────────────────────────
                  _documentTile(
                    title: "Share Code",
                    expiry: shareFirstAid?.shareCodeExpiry,
                    holderName: shareFirstAid?.shareCodeHolderName,
                    docNumber: shareFirstAid?.shareCodeNumber,
                    onUpdate: () => _showUpdateSheet(
                      title: "Share Code",
                      documentType: "SHARECODE",
                      act: act,
                      shareFirstAid: shareFirstAid,
                      sia: sia,
                    ),
                    documentUrl: shareFirstAid?.shareCodeUrl,
                  ),

                  // ─── FIRST AID ────────────────────────────
                  _documentTile(
                    title: "First Aid",
                    expiry: shareFirstAid?.firstAidExpiry,
                    holderName: shareFirstAid?.firstAidHolderName,
                    onUpdate: () => _showUpdateSheet(
                      title: "First Aid Certification",
                      documentType: "FIRST_AID",
                      act: act,
                      shareFirstAid: shareFirstAid,
                      sia: sia,
                    ),
                    documentUrl: shareFirstAid?.firstAidUrl,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 45,
        width: 150,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(Icons.download),
          label: Text("Export Docs"),
          onPressed: () async {
            if (isDownloading) return;
            setState(() => isDownloading = true);

            double _progress = 0.0;
            String _message = "Preparing your documents...";
            bool _isSuccess = false;
            bool _isFailed = false;
            String _errorText = "";

            final dialogKey = GlobalKey<State>();

            void _updateDialog(double p, String m) {
              if (dialogKey.currentState?.mounted ?? false) {
                dialogKey.currentState!.setState(() {
                  _progress = p;
                  _message = m;
                });
              }
            }

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return PopScope(
                  canPop: false,
                  child: StatefulBuilder(
                    key: dialogKey,
                    builder: (ctx, setDialogState) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                          24,
                          8,
                          24,
                          24,
                        ),
                        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _isFailed
                                    ? Icons.error_outline_rounded
                                    : _isSuccess
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.cloud_download_outlined,
                                color: _isFailed
                                    ? Colors.redAccent
                                    : primaryGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isFailed
                                    ? "Download Failed"
                                    : _isSuccess
                                    ? "Download Complete"
                                    : "Downloading Documents",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: Colors.white12, height: 1),
                              const SizedBox(height: 20),

                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: _isFailed ? 1.0 : _progress,
                                  minHeight: 6,
                                  backgroundColor: Colors.white54,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isFailed ? Colors.redAccent : primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Percentage + spinner row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isFailed
                                        ? "0%"
                                        : "${(_progress * 100).toInt()}%",
                                    style: TextStyle(
                                      color: _isFailed
                                          ? Colors.redAccent
                                          : primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  if (!_isSuccess && !_isFailed)
                                    SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryGreen.withOpacity(0.7),
                                      ),
                                    ),
                                  if (_isSuccess)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  if (_isFailed)
                                    const Icon(
                                      Icons.cancel_rounded,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Status message
                              Text(
                                _isFailed ? _errorText : _message,
                                style: TextStyle(
                                  color: _isFailed
                                      ? Colors.redAccent.withOpacity(0.85)
                                      : primaryGreen,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),

                              // Close button shown only on terminal states
                              if (_isSuccess || _isFailed) ...[
                                const SizedBox(height: 20),
                                const Divider(color: Colors.black, height: 1),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: _isFailed
                                          ? Colors.redAccent.withOpacity(0.12)
                                          : primaryGreen.withOpacity(0.12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                                    child: Text(
                                      "Close",
                                      style: TextStyle(
                                        color: _isFailed
                                            ? Colors.redAccent
                                            : primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );

            try {
              await ProfileRepository().downloadUserFolder(
                userEmail: userEmail,
                onProgress: (p, m) {
                  if (dialogKey.currentState?.mounted ?? false) {
                    dialogKey.currentState!.setState(() {
                      _progress = p;
                      _message = m;
                    });
                  }
                },
              );

              // Mark success inside dialog
              if (dialogKey.currentState?.mounted ?? false) {
                dialogKey.currentState!.setState(() {
                  _progress = 1.0;
                  _isSuccess = true;
                  _message = "All documents saved to your device.";
                });
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Documents downloaded successfully",
                          style: TextStyle(color:Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }
            } catch (e) {
              // Mark failure inside dialog
              if (dialogKey.currentState?.mounted ?? false) {
                dialogKey.currentState!.setState(() {
                  _isFailed = true;
                  _errorText = e.toString();
                });
              }
            } finally {
              setState(() => isDownloading = false);
            }
          },
        ),
      ),
    );
  }

  /// =====================================================
  /// Keep showing profile data while sub-states fire
  /// =====================================================

  ProfileLoaded? _resolveLoaded(ProfileState state) {
    if (state is ProfileLoaded) return state;
    // DocumentUpdating / DocumentUpdateSuccess don't carry data,
    // but BlocConsumer already handled reload. Return null to show spinner briefly.
    return null;
  }

  // ─────────────────────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────────────────────

  Widget _profileCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF7F1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.person, size: 34, color: primaryGreen),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user['full_name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user['emp_id'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  icon: Icons.mail_outline,
                  title: "Email",
                  value: user['email'] ?? '',
                ),
              ),
              Container(width: 1, height: 46, color: Colors.grey.shade300),
              Expanded(
                child: _infoTile(
                  icon: Icons.phone_outlined,
                  title: "Phone",
                  value: user['phone'] ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 14),
          _infoTile(
            icon: Icons.home_outlined,
            title: "Address",
            value: user['address'] ?? '',
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 14),
          _infoTile(
            icon: Icons.business_outlined,
            title: "Company",
            value: _companyLabel(user['company_code'] as String? ?? ''),
          ),
        ],
      ),
    );
  }

  static const _companyMap = {
    'valeron_protection_group': 'Valeron Protection Group',
    'tybar_security':           'Tybar Security',
    'gough_and_kelly':          'Gough & Kelly',
  };

  String _companyLabel(String code) =>
      _companyMap[code] ?? (code.isNotEmpty ? code : '—');

  // ─────────────────────────────────────────────────────────
  // DOCUMENT TILE
  // ─────────────────────────────────────────────────────────

  Widget _documentTile({
    required String title,
    required VoidCallback onUpdate,
    DateTime? expiry,
    String? documentUrl,
    String? holderName,
    String? docNumber,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String status = "Active";
    Color statusColor = Colors.green;
    Color? borderColor;
    Color bg = Colors.white;

    if (expiry != null) {
      final exp = DateTime(expiry.year, expiry.month, expiry.day);
      final diff = exp.difference(today).inDays;

      if (exp.isBefore(today)) {
        status = "Expired";
        statusColor = Colors.red;
        borderColor = Colors.red.shade200;
        bg = const Color(0xffFFF7F7);
      } else if (diff <= 30) {
        status = "Expiring Soon";
        statusColor = Colors.orange;
        borderColor = Colors.orange.shade200;
        bg = const Color(0xffFFFDFC);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.description_outlined,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11),
                    children: [
                      TextSpan(
                        text: "● ",
                        style: TextStyle(color: statusColor),
                      ),
                      TextSpan(
                        text: status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (expiry != null)
                        TextSpan(
                          text:
                              " • ${expiry.day}/${expiry.month}/${expiry.year}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                    ],
                  ),
                ),
                if (holderName != null && holderName.isNotEmpty)
                  Text(
                    holderName,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                if (docNumber != null && docNumber.isNotEmpty)
                  Text(
                    docNumber,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// PREVIEW BUTTON
              if (documentUrl != null && documentUrl.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(color: primaryGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          documentUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text(
                        "Preview",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),

              /// UPDATE BUTTON
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onUpdate,
                  icon: const Icon(Icons.upload, size: 14),
                  label: const Text("Update", style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xffEEF7F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: primaryGreen),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// =========================================================
/// BOTTOM SHEET — wraps OCRDocumentCard for updates
/// =========================================================

class _UpdateDocumentSheet extends StatefulWidget {
  final String title;
  final String documentType;
  final String userId;
  final String userEmail;
  final ActCertificateModel? act;
  final SharecodeFirstAidModel? shareFirstAid;
  final SiaLicenceModel? sia;

  const _UpdateDocumentSheet({
    required this.title,
    required this.documentType,
    required this.userId,
    required this.userEmail,
    this.act,
    this.shareFirstAid,
    this.sia,
  });

  @override
  State<_UpdateDocumentSheet> createState() => _UpdateDocumentSheetState();
}

class _UpdateDocumentSheetState extends State<_UpdateDocumentSheet> {
  DocumentUploadData? _uploadedData;
  bool _isSubmitting = false;

  void _onUploaded(DocumentUploadData data) {
    setState(() => _uploadedData = data);
  }

  /// Fire the right bloc event based on documentType
  void _submit() {
    if (_uploadedData == null) return;

    setState(() => _isSubmitting = true);

    final data = _uploadedData!;
    final bloc = context.read<ProfileBloc>();

    switch (widget.documentType) {
      /// ─── SIA ────────────────────────────────────────────
      case "SIA":
        bloc.add(
          UpdateSiaLicenceEvent(
            userId: widget.userId,
            userEmail: widget.userEmail,
            siaId: (widget.sia?.id).toString(),
            file: data.file,
            bytes: data.bytes,
            fileName: data.fileName,
            holderName: data.holderName,
            licenceNumber: data.documentNumber,
            expiry: data.expiryDate!,
          ),
        );
        break;

      /// ─── ORANGE ACT ─────────────────────────────────────
      case "ACT_ORANGE":
        bloc.add(
          UpdateActCertificateEvent(
            userId: widget.userId,
            userEmail: widget.userEmail,
            actId: (widget.act?.id).toString(),
            orangeFile: data.file,
            orangeBytes: data.bytes,
            orangeFileName: data.fileName,
            orangeHolderName: data.holderName,
            orangeExpiry: data.expiryDate,
          ),
        );
        break;

      /// ─── BLUE ACT ────────────────────────────────────────
      case "ACT_BLUE":
        bloc.add(
          UpdateActCertificateEvent(
            userId: widget.userId,
            userEmail: widget.userEmail,
            actId: (widget.act?.id).toString(),
            blueFile: data.file,
            blueBytes: data.bytes,
            blueFileName: data.fileName,
            blueHolderName: data.holderName,
            blueExpiry: data.expiryDate,
          ),
        );
        break;

      /// ─── SHARECODE ──────────────────────────────────────
      case "SHARECODE":
        bloc.add(
          UpdateSharecodeFirstAidEvent(
            userId: widget.userId,
            userEmail: widget.userEmail,
            shareFirstAidId: (widget.shareFirstAid?.id).toString(),
            sharecodeFile: data.file,
            sharecodeBytes: data.bytes,
            sharecodeFileName: data.fileName,
            sharecodeNumber: data.documentNumber,
            sharecodeHolderName: data.holderName,
            sharecodeExpiry: data.expiryDate,
            // keep existing first aid unchanged
            firstAidExpiry: widget.shareFirstAid?.firstAidExpiry,
            firstAidHolderName: widget.shareFirstAid?.firstAidHolderName,
          ),
        );
        break;

      /// ─── FIRST AID ──────────────────────────────────────
      case "FIRST_AID":
        bloc.add(
          UpdateSharecodeFirstAidEvent(
            userId: widget.userId,
            userEmail: widget.userEmail,
            shareFirstAidId: (widget.shareFirstAid?.id).toString(),
            firstAidFile: data.file,
            firstAidBytes: data.bytes,
            firstAidFileName: data.fileName,
            firstAidHolderName: data.holderName,
            firstAidExpiry: data.expiryDate,
            // keep existing sharecode unchanged
            sharecodeNumber: widget.shareFirstAid?.shareCodeNumber,
            sharecodeHolderName: widget.shareFirstAid?.shareCodeHolderName,
            sharecodeExpiry: widget.shareFirstAid?.shareCodeExpiry,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is DocumentUpdateSuccess || state is ProfileFailure) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HANDLE ──────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Update ${widget.title}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 4),

            Text(
              "Upload a new image — OCR will extract the details automatically.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            // ── OCR CARD ─────────────────────────────────────
            OCRDocumentCard(title: widget.title, onUploaded: _onUploaded),

            const SizedBox(height: 16),

            // ── SAVE BUTTON ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006B43),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (_uploadedData != null && !_isSubmitting)
                    ? _submit
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save Document",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
