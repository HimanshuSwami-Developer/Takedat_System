import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/screens/auth/widget/ocr_documents.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_state.dart';
import 'package:takedat_app/screens/profile/bloc/profile_bloc.dart';
import 'package:takedat_app/screens/profile/bloc/profile_event.dart';
import 'package:takedat_app/screens/profile/bloc/profile_state.dart';
import 'package:takedat_app/utils/app_toast.dart';

/// =========================================================
/// ADMIN EMPLOYEE EDIT SCREEN
/// Allows admin to edit an employee's profile and documents.
/// Reuses ProfileBloc — no new bloc needed.
/// =========================================================

class AdminEmployeeEditScreen extends StatefulWidget {
  final EmployeeComplianceItem employee;

  const AdminEmployeeEditScreen({super.key, required this.employee});

  @override
  State<AdminEmployeeEditScreen> createState() =>
      _AdminEmployeeEditScreenState();
}

class _AdminEmployeeEditScreenState extends State<AdminEmployeeEditScreen> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _controllersSeeded = false;

  String get _userId    => widget.employee.user.id!;
  String get _userEmail => widget.employee.user.email;

  static const _green = AppColors.primary;

  @override
  void initState() {
    super.initState();
    // Pre-fill from locally-cached data while fresh data loads
    _nameCtrl.text    = widget.employee.user.fullName;
    _phoneCtrl.text   = widget.employee.user.phone;
    _addressCtrl.text = widget.employee.user.address;
    _controllersSeeded = true;

    context.read<ProfileBloc>().add(LoadProfileEvent(userId: _userId));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── DOCUMENT UPDATE SHEET ──────────────────────────────────

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
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _AdminDocumentSheet(
          title: title,
          documentType: documentType,
          userId: _userId,
          userEmail: _userEmail,
          act: act,
          shareFirstAid: shareFirstAid,
          sia: sia,
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employee.user.fullName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              'EMP-${widget.employee.user.empId}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),

      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is DocumentUpdateSuccess) {
            if (state.documentType == "PROFILE") {
              AppToast.success(context, "Profile saved successfully");
            } else {
              Navigator.pop(context); // close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${state.documentType} updated successfully!"),
                  backgroundColor: _green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            // Always reload to show fresh data
            context.read<ProfileBloc>().add(LoadProfileEvent(userId: _userId));
          }

          if (state is ProfileFailure) {
            AppToast.error(context, state.error);
            context.read<ProfileBloc>().add(LoadProfileEvent(userId: _userId));
          }
        },

        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            // Seed controllers once from server after first load
            if (!_controllersSeeded) {
              _nameCtrl.text    = state.user['full_name'] ?? '';
              _phoneCtrl.text   = state.user['phone'] ?? '';
              _addressCtrl.text = state.user['address'] ?? '';
              _controllersSeeded = true;
            }

            return _buildBody(state);
          }

          // For sub-states (DocumentUpdating), keep body visible via last loaded
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBody(ProfileLoaded loaded) {
    final act          = loaded.actCertificate;
    final shareFirstAid = loaded.sharecodeFirstAid;
    final sia          = loaded.siaLicence;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFILE EDIT CARD ──────────────────────────
            _profileEditCard(loaded.user),

            const SizedBox(height: 22),

            // ── DOCUMENTS HEADER ───────────────────────────
            const Text(
              "Documents",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 14),

            // ── ACT ORANGE ─────────────────────────────────
            _documentTile(
              title: "Act Orange",
              expiry: act?.actOrangeExpiry,
              holderName: act?.orangeHolderName,
              documentUrl: act?.actOrangeUrl,
              onUpdate: () => _showUpdateSheet(
                title: "Orange ACT Certification",
                documentType: "ACT_ORANGE",
                act: act,
                shareFirstAid: shareFirstAid,
                sia: sia,
              ),
            ),

            // ── ACT BLUE ───────────────────────────────────
            _documentTile(
              title: "Act Blue",
              expiry: act?.actBlueExpiry,
              holderName: act?.blueHolderName,
              documentUrl: act?.actBlueUrl,
              onUpdate: () => _showUpdateSheet(
                title: "Blue ACT Certification",
                documentType: "ACT_BLUE",
                act: act,
                shareFirstAid: shareFirstAid,
                sia: sia,
              ),
            ),

            // ── SIA ────────────────────────────────────────
            _documentTile(
              title: "SIA License",
              expiry: sia?.siaLicenceExpiry,
              holderName: sia?.siaHolderName,
              docNumber: sia?.siaLicenceNumber,
              documentUrl: sia?.url,
              onUpdate: () => _showUpdateSheet(
                title: "SIA Licence",
                documentType: "SIA",
                act: act,
                shareFirstAid: shareFirstAid,
                sia: sia,
              ),
            ),

            // ── SHARE CODE ─────────────────────────────────
            _documentTile(
              title: "Share Code",
              expiry: shareFirstAid?.shareCodeExpiry,
              holderName: shareFirstAid?.shareCodeHolderName,
              docNumber: shareFirstAid?.shareCodeNumber,
              documentUrl: shareFirstAid?.shareCodeUrl,
              onUpdate: () => _showUpdateSheet(
                title: "Share Code",
                documentType: "SHARECODE",
                act: act,
                shareFirstAid: shareFirstAid,
                sia: sia,
              ),
            ),

            // ── FIRST AID ──────────────────────────────────
            _documentTile(
              title: "First Aid",
              expiry: shareFirstAid?.firstAidExpiry,
              holderName: shareFirstAid?.firstAidHolderName,
              documentUrl: shareFirstAid?.firstAidUrl,
              onUpdate: () => _showUpdateSheet(
                title: "First Aid Certification",
                documentType: "FIRST_AID",
                act: act,
                shareFirstAid: shareFirstAid,
                sia: sia,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── PROFILE EDIT CARD ──────────────────────────────────────

  Widget _profileEditCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  (user['full_name'] as String? ?? '').isNotEmpty
                      ? (user['full_name'] as String)[0].toUpperCase()
                      : "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // ── FIELDS ──────────────────────────────────────
          _editField(
            controller: _nameCtrl,
            label: "Full Name",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _editField(
            controller: _phoneCtrl,
            label: "Phone",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _editField(
            controller: _addressCtrl,
            label: "Address",
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // ── SAVE BUTTON ─────────────────────────────────
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isSaving = state is DocumentUpdating &&
                  state.documentType == "PROFILE";

              return SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () {
                          if (_nameCtrl.text.trim().isEmpty ||
                              _phoneCtrl.text.trim().isEmpty ||
                              _addressCtrl.text.trim().isEmpty) {
                            AppToast.warning(context, "Please fill all fields");
                            return;
                          }
                          context.read<ProfileBloc>().add(
                            UpdateUserProfileEvent(
                              userId: _userId,
                              fullName: _nameCtrl.text.trim(),
                              phone: _phoneCtrl.text.trim(),
                              address: _addressCtrl.text.trim(),
                            ),
                          );
                        },
                  icon: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                  label: Text(
                    isSaving ? "Saving..." : "Save Profile",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
      ),
    );
  }

  // ── DOCUMENT TILE ──────────────────────────────────────────

  Widget _documentTile({
    required String title,
    required VoidCallback onUpdate,
    DateTime? expiry,
    String? documentUrl,
    String? holderName,
    String? docNumber,
  }) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String status      = "Active";
    Color  statusColor = Colors.green;
    Color? borderColor;
    Color  bg          = Colors.white;

    if (expiry != null) {
      final exp  = DateTime(expiry.year, expiry.month, expiry.day);
      final diff = exp.difference(today).inDays;

      if (exp.isBefore(today)) {
        status      = "Expired";
        statusColor = Colors.red;
        borderColor = Colors.red.shade200;
        bg          = const Color(0xffFFF7F7);
      } else if (diff <= 30) {
        status      = "Expiring Soon";
        statusColor = Colors.orange;
        borderColor = Colors.orange.shade200;
        bg          = const Color(0xffFFFDFC);
      }
    }

    if (documentUrl == null) {
      status      = "Not Uploaded";
      statusColor = Colors.grey;
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
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (docNumber != null && docNumber.isNotEmpty)
                  Text(
                    docNumber,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (documentUrl != null && documentUrl.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _previewDocument(documentUrl),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                      ),
                      label: const Text(
                        "Preview",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onUpdate,
                  icon: const Icon(Icons.upload, size: 14),
                  label: const Text(
                    "Update",
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _previewDocument(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => Navigator.pop(ctx),
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
      ),
    );
  }
}

/// =========================================================
/// BOTTOM SHEET — document update (admin)
/// Identical logic to ProfileScreen's _UpdateDocumentSheet
/// =========================================================

class _AdminDocumentSheet extends StatefulWidget {
  final String title;
  final String documentType;
  final String userId;
  final String userEmail;
  final ActCertificateModel? act;
  final SharecodeFirstAidModel? shareFirstAid;
  final SiaLicenceModel? sia;

  const _AdminDocumentSheet({
    required this.title,
    required this.documentType,
    required this.userId,
    required this.userEmail,
    this.act,
    this.shareFirstAid,
    this.sia,
  });

  @override
  State<_AdminDocumentSheet> createState() => _AdminDocumentSheetState();
}

class _AdminDocumentSheetState extends State<_AdminDocumentSheet> {
  DocumentUploadData? _uploadedData;
  bool _isSubmitting = false;

  void _onUploaded(DocumentUploadData data) {
    setState(() => _uploadedData = data);
  }

  void _submit() {
    if (_uploadedData == null) return;
    setState(() => _isSubmitting = true);

    final data = _uploadedData!;
    final bloc = context.read<ProfileBloc>();

    switch (widget.documentType) {
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
            // preserve existing first aid fields
            firstAidExpiry: widget.shareFirstAid?.firstAidExpiry,
            firstAidHolderName: widget.shareFirstAid?.firstAidHolderName,
          ),
        );
        break;

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
            // preserve existing sharecode fields
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Upload a new image — OCR will extract the details automatically.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            OCRDocumentCard(
              title: widget.title,
              onUploaded: _onUploaded,
            ),

            const SizedBox(height: 16),

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
