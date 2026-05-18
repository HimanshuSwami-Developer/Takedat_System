import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/models/contractor_model.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/utils/app_toast.dart';

class ContractorCard extends StatefulWidget {
  final ContractorModel contractor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ContractorCard({
    super.key,
    required this.contractor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ContractorCard> createState() => _ContractorCardState();
}

class _ContractorCardState extends State<ContractorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.contractor;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            /// TOP ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat("dd MMM yyyy").format(item.payDate),
                        style: AppTextStyles.small.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  "£${item.amount.toStringAsFixed(2)}",
                  style: AppTextStyles.label.copyWith(
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            /// EXPANDABLE
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),

                  /// PHONE
                  _infoRow("Contact", item.phone),
                  Divider(color: Colors.grey.shade200, height: 1),

                  /// EMAIL
                  _infoRow("Email", item.email),

                  const SizedBox(height: 12),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      _actionButton(
                        label: "Edit",
                        icon: Icons.edit_outlined,
                        color: AppColors.primary,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(width: 10),
                      _actionButton(
                        label: "Delete",
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Only show if pay slip exists
                  if (item.paySlip != null)
                    CustomButton(
                      text: "View Pay Slip",
                      icon: Icons.receipt_long,
                      onTap: () {
                        final url = item.paySlip;

                        if (url == null) return;

                        showDialog(
                          context: context,
                          builder: (_) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(20),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /// HEADER
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Pay Slip Preview",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        IconButton(
                                          onPressed: () => context.canPop()
                                              ? context.pop()
                                              : Navigator.of(context).pop(),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    /// IMAGE PREVIEW
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.contain,

                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null)
                                                  return child;

                                                return const Padding(
                                                  padding: EdgeInsets.all(40),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              },

                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(30),
                                                  child: Text(
                                                    "Unable to load preview",
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: value));

              if (!context.mounted) return;

               AppToast.success(context, "$value copied");
              
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.label.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
