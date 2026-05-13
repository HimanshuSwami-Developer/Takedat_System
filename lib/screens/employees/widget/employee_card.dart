import 'package:flutter/material.dart';
import 'package:takedat_app/screens/employees/ui/employees_screen.dart';

class EmployeeComplianceCard extends StatelessWidget {
  final EmployeeComplianceModel employee;
  final VoidCallback onTap;

  const EmployeeComplianceCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: employee.isExpanded
              ? const Color(0xFF00C57B)
              : Colors.transparent,
          width: 1.4,
        ),
      ),

      child: Column(
        children: [
          /// =======================================
          /// HEADER
          /// =======================================
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// AVATAR
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _avatarColor(employee.initials),

                    child: Text(
                      employee.initials,

                      style: const TextStyle(
                        color: Colors.black87,
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
                        Stack(
                          clipBehavior: Clip.none,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  employee.name,

                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.badge_outlined,
                                      size: 15,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      "EMP-${employee.empId}",

                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 2),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.mail_outline,
                                      size: 15,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(width: 4),

                                    Expanded(
                                      child: Text(
                                        employee.email,

                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (employee.complianceRequired)
                              Positioned(
                                top: -12,
                                right: 0,

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD93025),

                                    borderRadius: BorderRadius.circular(4),
                                  ),

                                  child: const Text(
                                    "COMPLIANCE ACTION REQUIRED",

                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    employee.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          /// =======================================
          /// EXPANDED SECTION
          /// =======================================
          if (employee.isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade300),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// ADDRESS TITLE
                  const Text(
                    "PRIMARY ADDRESS",

                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ADDRESS BOX
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4EE),

                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            employee.address,

                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// TITLE
                  const Text(
                    "COMPLIANCE DOCUMENTS",

                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// DOCUMENT GRID
                  Wrap(
                    spacing: 10,
                    runSpacing:10,
                    alignment: WrapAlignment.start,

                    children: [
                      _responsiveDocCard(
                        context,
                        isDesktop,
                        _docCard(
                          title: "Act Orange",
                          expiry: "EXP: DEC 2025",
                          icon: Icons.shield_outlined,
                          bg: const Color(0xFFDFF4E7),
                          iconBg: const Color(0xFFC6EED5),
                        ),
                      ),

                      _responsiveDocCard(
                        context,
                        isDesktop,
                        _docCard(
                          title: "Act Blue",
                          expiry: "EXP: NOV 2023",
                          icon: Icons.warning_amber_rounded,
                          bg: const Color(0xFFF2E8D9),
                          iconBg: const Color(0xFFE3D4BC),
                        ),
                      ),

                      _responsiveDocCard(
                        context,
                        isDesktop,
                        _docCard(
                          title: "SIA License",
                          expiry: "EXP: OCT 2023",
                          icon: Icons.gavel_rounded,
                          bg: const Color(0xFFF6D9D8),
                          iconBg: const Color(0xFFEBC0BE),
                          expiryColor: const Color(0xFFD93025),
                        ),
                      ),

                      _responsiveDocCard(
                        context,
                        isDesktop,
                        _docCard(
                          title: "Share Code",
                          expiry: "EXP: JAN 2026",
                          icon: Icons.qr_code_2,
                          bg: const Color(0xFFE7EFE8),
                          iconBg: const Color(0xFFD4E2D7),
                        ),
                      ),

                      _responsiveDocCard(
                        context,
                        isDesktop,
                        _docCard(
                          title: "First Aid",
                          expiry: "EXP: MAY 2024",
                          icon: Icons.medical_services_outlined,
                          bg: const Color(0xFFE7EFE8),
                          iconBg: const Color(0xFFD4E2D7),
                        ),
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

Widget _responsiveDocCard(
  BuildContext context,
  bool isDesktop,
  Widget child,
) {
  final availableWidth =
      MediaQuery.of(context).size.width;

  double cardWidth;

  if (isDesktop) {
    /// 5 cards in desktop row
    cardWidth = (availableWidth - 120) / 5;
  } else {
    /// 2 cards in mobile row
    cardWidth = (availableWidth - 50) / 2.2;
  }

  return SizedBox(
    width: cardWidth,
    child: child,
  );
}

  /// =======================================
  /// DOCUMENT CARD
  /// =======================================

  Widget _docCard({
    required String title,
    required String expiry,
    required IconData icon,
    required Color bg,
    required Color iconBg,
    Color expiryColor = Colors.black54,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),

            child: Icon(icon, size: 18, color: Colors.black54),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          Text(
            expiry,

            style: TextStyle(
              fontSize: 10,
              color: expiryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String initials) {
    switch (initials) {
      case "JS":
        return const Color(0xFF00B26B);

      case "AM":
        return const Color(0xFFDCE3F7);

      case "DW":
        return const Color(0xFFF4D1CF);

      default:
        return const Color(0xFFD9DEF7);
    }
  }
}
