import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';

import 'package:takedat_app/screens/employees/bloc/employee_compliance_state.dart';

class EmployeeComplianceCard extends StatelessWidget {
  final EmployeeComplianceItem employee;

  final VoidCallback onTap;

  final VoidCallback? onEdit;

  const EmployeeComplianceCard({
    super.key,
    required this.employee,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final user = employee.user;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color:Colors.grey.shade100,

          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: employee.isExpanded
                ? const Color(0x1400C57B)
                : Colors.black.withOpacity(.03),

            blurRadius: 20,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          /// =================================================
          /// HEADER
          /// =================================================
          InkWell(
            borderRadius: BorderRadius.circular(24),

            onTap: onTap,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                children: [
                  /// AVATAR
                  Container(
                    height: 52,
                    width: 52,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary,AppColors.tertiary],
                      ),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    alignment: Alignment.center,

                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : "U",

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 20,

                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// NAME
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.fullName,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 15.5,

                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            if (employee.complianceRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,

                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.red,

                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: const Text(
                                  "ACTION",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 9,

                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        /// TAGS
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,

                          children: [
                            _tag(
                              Icons.badge_outlined,

                              "EMP-${user.empId}",

                              const Color(0xFFF4F5F7),

                              Colors.black87,
                            ),

                            _tag(
                              Icons.admin_panel_settings_outlined,

                              user.role.toUpperCase(),

                              const Color(0xFFEAF7FF),

                              const Color(0xFF0077FF),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// ARROW
                  AnimatedRotation(
                    turns: employee.isExpanded ? .5 : 0,

                    duration: const Duration(milliseconds: 250),

                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,

                      size: 28,

                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// =================================================
          /// EXPANDED CONTENT
          /// =================================================
          if (employee.isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                children: [
                  /// EMAIL
                  _copyTile(
                    context,

                    icon: Icons.email_outlined,

                    text: user.email,
                  ),

                  const SizedBox(height: 10),

                  /// PHONE
                  _copyTile(
                    context,

                    icon: Icons.call_outlined,

                    text: user.phone,
                  ),

                  const SizedBox(height: 10),

                  /// ADDRESS
                  _copyTile(
                    context,

                    icon: Icons.location_on_outlined,

                    text: user.address,
                  ),

                  const SizedBox(height: 18),

                  /// EDIT BUTTON
                  if (onEdit != null) ...[
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text(
                          "Edit",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),
                  ],

                  /// DOCUMENTS
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,

                    children: [
                      /// ACT ORANGE
                      if (employee.actCertificate?.actOrangeUrl != null)
                        _docCard(
                          context,

                          title: "Act Orange",

                          expiry: employee.actCertificate?.actOrangeExpiry,

                          url: employee.actCertificate?.actOrangeUrl,

                          icon: Icons.shield_outlined,

                          color: const Color(0xFFEAFBF3),
                        ),

                      /// ACT BLUE
                      if (employee.actCertificate?.actBlueUrl != null)
                        _docCard(
                          context,

                          title: "Act Blue",

                          expiry: employee.actCertificate?.actBlueExpiry,

                          url: employee.actCertificate?.actBlueUrl,

                          icon: Icons.verified_user_outlined,

                          color: const Color(0xFFEAF1FF),
                        ),

                      /// SIA
                      if (employee.siaLicence?.url != null)
                        _docCard(
                          context,

                          title: "SIA Licence",

                          expiry: employee.siaLicence?.siaLicenceExpiry,

                          url: employee.siaLicence?.url,

                          icon: Icons.gavel_outlined,

                          color: const Color(0xFFFFEEEE),
                        ),

                      /// SHARE CODE
                      if (employee.sharecodeFirstAid?.shareCodeUrl != null)
                        _docCard(
                          context,

                          title: "Share Code",

                          expiry: employee.sharecodeFirstAid?.shareCodeExpiry,

                          url: employee.sharecodeFirstAid?.shareCodeUrl,

                          icon: Icons.qr_code_2_outlined,

                          color: const Color(0xFFF3F8E8),
                        ),

                      /// FIRST AID
                      if (employee.sharecodeFirstAid?.firstAidUrl != null)
                        _docCard(
                          context,

                          title: "First Aid",

                          expiry: employee.sharecodeFirstAid?.firstAidExpiry,

                          url: employee.sharecodeFirstAid?.firstAidUrl,

                          icon: Icons.medical_services_outlined,

                          color: const Color(0xFFE9F7F4),
                        ),

                      /// SIGNED AUTH
                      if (employee.signedDocuments?.signedAuthenticationUrl !=
                          null)
                        _docCard(
                          context,

                          title: "Signed Auth",

                          url:
                              employee.signedDocuments?.signedAuthenticationUrl,

                          icon: Icons.description_outlined,

                          color: const Color(0xFFF4EEFF),
                        ),

                      /// SIGNED SCREENING
                      if (employee.signedDocuments?.signedScreeningUrl != null)
                        _docCard(
                          context,

                          title: "Signed Screening",

                          url: employee.signedDocuments?.signedScreeningUrl,

                          icon: Icons.assignment_outlined,

                          color: const Color(0xFFFFF6EA),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// =====================================================
  /// TAG
  /// =====================================================

  Widget _tag(IconData icon, String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: bg,

        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 13, color: textColor),

          const SizedBox(width: 5),

          Text(
            text,

            style: TextStyle(
              fontSize: 10.5,

              color: textColor,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// =====================================================
  /// COPY TILE
  /// =====================================================

  Widget _copyTile(
    BuildContext context, {

    required IconData icon,

    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(8),

            onTap: () async {
              await Clipboard.setData(ClipboardData(text: text));

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,

                  content: Text("Copied"),
                ),
              );
            },

            child: Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(8),
              ),

              child: const Icon(Icons.copy_rounded, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  /// =====================================================
  /// DOCUMENT CARD
  /// =====================================================

  Widget _docCard(
    BuildContext context, {

    required String title,

    required String? url,

    required IconData icon,

    required Color color,

    DateTime? expiry,
  }) {
    final expired = expiry != null && expiry.isBefore(DateTime.now());

    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        if (url == null) return;

        showGeneralDialog(
          context: context,

          barrierDismissible: true,

          barrierLabel: "Preview",

          barrierColor: Colors.black87,

          transitionDuration: const Duration(milliseconds: 250),

          pageBuilder: (context, animation, secondaryAnimation) {
            return SafeArea(
              child: Stack(
                children: [
                  /// IMAGE
                  Center(
                    child: InteractiveViewer(
                      child: Image.network(url, fit: BoxFit.contain),
                    ),
                  ),

                  /// CLOSE
                  Positioned(
                    top: 20,
                    right: 20,

                    child: Material(
                      color: Colors.transparent,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),

                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(Icons.close),
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

      child: Container(
        width: 160,

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: color,

          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, size: 22),
            ),

            const SizedBox(height: 14),

            Text(
              title,

              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),

            if (expiry != null) ...[
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: expired ? Colors.red.withOpacity(.12) : Colors.white,

                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      expired
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_today_outlined,

                      size: 13,

                      color: expired ? Colors.red : Colors.black54,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      DateFormat('dd MMM yyyy').format(expiry),

                      style: TextStyle(
                        fontSize: 11,

                        color: expired ? Colors.red : Colors.black87,

                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(30),
              ),

              child: const Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 15),

                  SizedBox(width: 6),

                  Text(
                    "Preview",

                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
