import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/constant/session_keys.dart';
import 'package:takedat_app/constant/session_manager.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

import 'package:takedat_app/models/attendance_model.dart';
import 'package:takedat_app/models/payment_model.dart';

import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/payment/widget/payment_slip_service.dart';

/// ======================================================
/// PAYMENT CARD
/// ======================================================

class PaymentCard extends StatelessWidget {
  final PaymentTrackModel payment;

  final VoidCallback onUpdate;

  const PaymentCard({super.key, required this.payment, required this.onUpdate});

  /// ======================================================
  /// PAYMENT EXISTS
  /// ======================================================

  bool get _hasPayment => payment.paymentId != null;

  /// ======================================================
  /// STATUS COLOR
  /// ======================================================

  Color get _statusColor {
    switch (payment.paymentStatus.toLowerCase()) {
      case 'paid':
        return const Color(0xFF22C55E);

      case 'partial':
        return const Color(0xFFF59E0B);

      case 'cancelled':
        return const Color(0xFFEF4444);

      default:
        return Colors.grey;
    }
  }

  /// ======================================================
  /// STATUS LABEL
  /// ======================================================

  String get _statusLabel {
    final s = payment.paymentStatus;

    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final attendance = payment.attendance as AttendanceModel;

    final total = payment.cashPayment + payment.niPayment + payment.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 20,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// =================================================
          /// TOP STATUS BAR
          /// =================================================
          Container(
            height: 5,

            decoration: BoxDecoration(
              color: _hasPayment ? AppColors.primary : Colors.grey.shade300,

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),

                topRight: Radius.circular(22),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                /// =============================================
                /// HEADER
                /// =============================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// AVATAR
                    Container(
                      width: 54,
                      height: 54,

                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      alignment: Alignment.center,

                      child: Text(
                        _initials(payment.user?.fullName ?? ''),

                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.primary,

                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// USER INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            payment.user?.fullName ?? "Unknown",

                            style: AppTextStyles.headline.copyWith(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "EMP ID • ${payment.user?.empId ?? '—'}",

                            style: AppTextStyles.small.copyWith(
                              color: Colors.grey.shade600,

                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// STATUS
                    _StatusBadge(
                      label: _hasPayment ? _statusLabel : "New",

                      color: _hasPayment ? _statusColor : Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// =============================================
                /// SHIFT INFO
                /// =============================================
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: "Shift Start",

                        icon: Icons.login_rounded,

                        value: _formatDate(attendance.shiftStart),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _InfoCard(
                        title: "Shift End",

                        icon: Icons.logout_rounded,

                        value: _formatDate(attendance.shiftEnd),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// =============================================
                /// PAYMENT INFO
                /// =============================================
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: "Payment I / Payment II",

                        icon: Icons.payments_outlined,

                        value: _hasPayment
                            ? "£${payment.cashPayment.toStringAsFixed(2)}  /  £${payment.niPayment.toStringAsFixed(2)}"
                            : "—",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _InfoCard(
                        title: "Expense",

                        icon: Icons.receipt_long_outlined,

                        value: _hasPayment
                            ? "£${payment.expense.toStringAsFixed(2)}"
                            : "—",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// =============================================
                /// TOTAL
                /// =============================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Total Payment",

                        style: AppTextStyles.label.copyWith(
                          color: Colors.black87,
                        ),
                      ),

                      Text(
                        _hasPayment ? "£${total.toStringAsFixed(2)}" : "—",

                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.primary,

                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// =============================================
                /// BUTTONS
                /// =============================================
                Row(
                  children: [
                    /// UPDATE
                    if (SessionManager.getString(SessionKeys.role) == "admin")
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUpdate,

                          icon: Icon(
                            Icons.edit_outlined,

                            size: 18,

                            color: AppColors.primary,
                          ),

                          label: Text(
                            "Update",

                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),

                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),

                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.4),
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                    Spacer(),

                    /// GENERATE SLIP
                    Expanded(
                      child: _hasPayment
                          ? CustomButton(
                              text: "Generate Slip",

                              isFullWidth: true,

                              onTap: () async {
                                try {
                                  await PaymentSlipService.generateSlip(
                                    employeeName: payment.user?.fullName ?? '',

                                    employeeId: payment.user?.empId ?? '',

                                    shiftStart: attendance.shiftStart,

                                    shiftEnd: attendance.shiftEnd,

                                    cashPayment: payment.cashPayment,

                                    niPayment: payment.niPayment,

                                    expense: payment.expense,

                                    paymentStatus: payment.paymentStatus,
                                  );

                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,

                                      behavior: SnackBarBehavior.floating,

                                      content: Text(
                                        "Payment slip downloaded",

                                        style: AppTextStyles.label.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint(e.toString());

                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,

                                      behavior: SnackBarBehavior.floating,

                                      content: Text(e.toString()),
                                    ),
                                  );
                                }
                              },
                            )
                          : _DisabledButton(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// INITIALS
  /// ======================================================

  String _initials(String name) {
    final parts = name.trim().split(' ');

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// ======================================================
  /// FORMAT DATE
  /// ======================================================

  String _formatDate(DateTime dt) {
    return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
  }
}

/// ======================================================
/// STATUS BADGE
/// ======================================================

class _StatusBadge extends StatelessWidget {
  final String label;

  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 7,
            height: 7,

            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 6),

          Text(
            label,

            style: TextStyle(
              fontSize: 12,

              fontWeight: FontWeight.w700,

              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// INFO CARD
/// ======================================================

class _InfoCard extends StatelessWidget {
  final String title;

  final String value;

  final IconData icon;

  const _InfoCard({
    required this.title,

    required this.value,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade500),

              const SizedBox(width: 5),

              Text(
                title,

                style: TextStyle(
                  fontSize: 11,

                  color: Colors.grey.shade500,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value,

            style: const TextStyle(
              fontSize: 13,

              fontWeight: FontWeight.w700,

              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// DISABLED BUTTON
/// ======================================================

class _DisabledButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(14),
      ),

      alignment: Alignment.center,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.lock_outline_rounded,

            size: 16,

            color: Colors.grey.shade500,
          ),

          const SizedBox(width: 8),

          Text(
            "Generate Slip",

            style: TextStyle(
              fontWeight: FontWeight.w600,

              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
