import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/models/payment_model.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

/// =======================================
/// PAYMENT CARD
/// =======================================

class PaymentCard extends StatelessWidget {
  final PaymentTrackModel payment;
  final VoidCallback onUpdate;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onUpdate,
  });

  /// Payment exists if paymentId is not null
  bool get _hasPayment => payment.paymentId != null;

  Color get _statusColor {
    switch (payment.paymentStatus.toLowerCase()) {
      case 'paid':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String get _statusLabel {
    final s = payment.paymentStatus;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ── COLORED TOP BAR ──────────────────────
            Container(
              height: 4,
              color: _hasPayment ? _statusColor : Colors.grey.shade300,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ── HEADER ROW ───────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// AVATAR
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(payment.user?.fullName ?? '?'),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// NAME + ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.user?.fullName ?? '—',
                              style: AppTextStyles.label.copyWith(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              payment.user?.empId ?? '—',
                              style: AppTextStyles.small.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// STATUS BADGE — only show if payment exists
                      if (_hasPayment)
                        _StatusBadge(
                          label: _statusLabel,
                          color: _statusColor,
                        )
                      else
                        _StatusBadge(
                          label: 'New',
                          color: Colors.grey.shade400,
                          isOutlined: true,
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const _Divider(),
                  const SizedBox(height: 14),

                  /// ── SHIFT INFO ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.login_rounded,
                          label: "Shift Start",
                          value: _formatDate(
                              payment.attendance?.shiftStart ?? DateTime.now()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.logout_rounded,
                          label: "Shift End",
                          value: _formatDate(
                              payment.attendance?.shiftEnd ?? DateTime.now()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// ── PAYMENT INFO ──────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.payments_outlined,
                          label: "Cash / NI",
                          value: _hasPayment
                              ? "\$${payment.cashPayment.toStringAsFixed(2)}  ·  \$${payment.niPayment.toStringAsFixed(2)}"
                              : "—",
                          valueColor: _hasPayment ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.receipt_long_outlined,
                          label: "Expense",
                          value: _hasPayment
                              ? "\$${payment.expense.toStringAsFixed(2)}"
                              : "—",
                          valueColor: _hasPayment ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ── ACTION BUTTONS ────────────────────
                  Row(
                    children: [
                      /// UPDATE
                      Expanded(
                        child: _OutlineBtn(
                          label: "Update",
                          icon: Icons.edit_outlined,
                          onTap: onUpdate,
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// GENERATE SLIP — disabled if no paymentId
                      Expanded(
                        child: _hasPayment
                            ? CustomButton(
                                text: "Generate Slip",
                                onTap: () {
                                  // TODO: generate slip
                                },
                                isFullWidth: true,
                              )
                            : _DisabledBtn(label: "Generate Slip"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatDate(DateTime dt) =>
      DateFormat("dd MMM yyyy, hh:mm a").format(dt);
}

/// =======================================
/// STATUS BADGE
/// =======================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isOutlined;

  const _StatusBadge({
    required this.label,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: isOutlined ? Border.all(color: color, width: 1.2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================
/// INFO TILE
/// =======================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// =======================================
/// OUTLINE BUTTON
/// =======================================

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================
/// DISABLED BUTTON
/// =======================================

class _DisabledBtn extends StatelessWidget {
  final String label;

  const _DisabledBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================
/// DIVIDER
/// =======================================

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.grey.shade100,
    );
  }
}