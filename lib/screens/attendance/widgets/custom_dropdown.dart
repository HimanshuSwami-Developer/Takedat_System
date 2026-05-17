import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final T? value;
  final Function(T?) onChanged;
  final IconData? icon;
  final String Function(T)? itemLabel; // optional custom label

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.icon,
    this.itemLabel,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value;
  }

  String _labelOf(T item) =>
      widget.itemLabel != null ? widget.itemLabel!(item) : item.toString();

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DropdownSheet<T>(
        hint: widget.label,
        items: widget.items,
        selected: selectedValue,
        labelOf: _labelOf,
        onSelect: (value) {
          setState(() => selectedValue = value);
          widget.onChanged(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedValue != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──
          Text(
            widget.label,
            style: AppTextStyles.label.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 6),

          // ── Trigger Field ──
          GestureDetector(
            onTap: _openSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: Colors.grey),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      hasValue ? _labelOf(selectedValue as T) : widget.hint,
                      style: hasValue
                          ? AppTextStyles.body.copyWith(color: Colors.black87)
                          : AppTextStyles.label.copyWith(color: Colors.grey),
                    ),
                  ),
                  AnimatedRotation(
                    turns: 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Sheet ──────────────────────────────────────────────
class _DropdownSheet<T> extends StatefulWidget {
  final String hint;
  final List<T> items;
  final T? selected;
  final String Function(T) labelOf;
  final Function(T) onSelect;

  const _DropdownSheet({
    required this.hint,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  State<_DropdownSheet<T>> createState() => _DropdownSheetState<T>();
}

class _DropdownSheetState<T> extends State<_DropdownSheet<T>> {
  late T? _hovered;

  @override
  void initState() {
    super.initState();
    _hovered = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),

          // Sheet title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.hint,
                style: AppTextStyles.label.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 16),

          // Options list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.items.length,
              itemBuilder: (_, i) {
                final item = widget.items[i];
                final label = widget.labelOf(item);
                final isSelected = widget.selected != null &&
                    widget.labelOf(widget.selected as T) == label;

                return InkWell(
                  onTap: () {
                    widget.onSelect(item);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.06)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: AppTextStyles.body.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}