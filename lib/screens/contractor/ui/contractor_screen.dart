import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/contractor/bloc/contractor_bloc.dart';
import 'package:takedat_app/screens/contractor/bloc/contractor_event.dart';
import 'package:takedat_app/screens/contractor/bloc/contractor_state.dart';
import 'package:takedat_app/screens/contractor/widget/add_contract.dart';
import 'package:takedat_app/screens/contractor/widget/contractor_card.dart';

class ContractorScreen extends StatefulWidget {
  const ContractorScreen({super.key});

  @override
  State<ContractorScreen> createState() => _ContractorScreenState();
}

class _ContractorScreenState extends State<ContractorScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late ContractorBloc _bloc;

  // Track active filters for the indicator dot
  bool get _hasActiveFilter =>
      _bloc.filterMinAmount != null ||
      _bloc.filterMaxAmount != null ||
      _bloc.filterPayDate != null;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ContractorBloc>()..add(LoadContractorsEvent());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreContractorsEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BlocBuilder<ContractorBloc, ContractorState>(
          builder: (context, state) {
            final contractors = state is ContractorLoaded
                ? state.contractors
                : [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ─────────────────────────────
                /// HEADER
                /// ─────────────────────────────
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Contractor",
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      CustomButton(
                        text: "Add Contract",
                        icon: Icons.add,
                        isFullWidth: false,
                        onTap: () => _openAddSheet(context),
                      ),
                    ],
                  ),
                ),

                /// ─────────────────────────────
                /// SEARCH + FILTER
                /// ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: CustomTextField(
                            controller: _searchController,
                            label: "",
                            hint: "Search contractor",
                            icon: Icons.search,
                            onChanged: (value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                              _debounce = Timer(
                                const Duration(milliseconds: 500),
                                () => _bloc.add(
                                  SearchContractorsEvent(value.trim()),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _openFilterSheet(context),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _hasActiveFilter
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _hasActiveFilter
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: _hasActiveFilter
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ─────────────────────────────
                /// LOADING
                /// ─────────────────────────────
                if (state is ContractorLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                /// ─────────────────────────────
                /// ERROR
                /// ─────────────────────────────
                else if (state is ContractorFailure)
                  Expanded(
                    child: Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.label.copyWith(color: Colors.red),
                      ),
                    ),
                  )
                /// ─────────────────────────────
                /// LIST
                /// ─────────────────────────────
                else
                  Expanded(
                    child: contractors.isEmpty
                        ? Center(
                            child: Text(
                              "No contractors found",
                              style: AppTextStyles.label.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: [
                                ...contractors.map(
                                  (contractor) => ContractorCard(
                                    contractor: contractor,
                                    onEdit: () =>
                                        _openEditSheet(context, contractor),
                                   onDelete: () => _confirmDelete(contractor),
                                  ),
                                ),
                                if (state is ContractorLoaded && state.hasMore)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ─────────────────────────────────────
  /// ADD SHEET
  /// ─────────────────────────────────────
  void _openAddSheet(BuildContext context) {
    final bloc = context.read<ContractorBloc>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AddContractSheet(
          onSave: (model, file) {
            bloc.add(CreateContractorEvent(model, paySlipFile: file));
          },
        ),
      ),
    );
  }

  /// ─────────────────────────────────────
  /// DELETE CONFIRMATION
  /// ─────────────────────────────────────
  Future<void> _confirmDelete(contractor) async {
    final confirmed = await showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,

          insetPadding: const EdgeInsets.symmetric(horizontal: 28),

          child: Container(
            width: 400,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                /// ICON
                Container(
                  height: 72,
                  width: 72,

                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE
                Text(
                  "Delete Contractor?",

                  style: AppTextStyles.headline.copyWith(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                /// MESSAGE
                Text(
                  "Are you sure you want to delete ${contractor.name}? This action cannot be undone.",

                  textAlign: TextAlign.center,

                  style: AppTextStyles.label.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                /// BUTTONS
                Row(
                  children: [
                    /// CANCEL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),

                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),

                          side: BorderSide(color: Colors.grey.shade300),
                        ),

                        child: Text(
                          "Cancel",

                          style: AppTextStyles.label.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// DELETE
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),

                        style: ElevatedButton.styleFrom(
                          elevation: 0,

                          backgroundColor: Colors.red,

                          minimumSize: const Size(double.infinity, 48),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: Text(
                          "Delete",

                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      _bloc.add(DeleteContractorEvent(contractor.id!));
    }
  }

  /// ─────────────────────────────────────
  /// EDIT SHEET
  /// ─────────────────────────────────────
  void _openEditSheet(BuildContext context, contractor) {
    final bloc = context.read<ContractorBloc>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AddContractSheet(
          contractor: contractor,
          onSave: (model, file) {
            bloc.add(
              UpdateContractorEvent(contractor.id!, model, paySlipFile: file),
            );
          },
        ),
      ),
    );
  }

  /// ─────────────────────────────────────
  /// FILTER SHEET
  /// ─────────────────────────────────────
  void _openFilterSheet(BuildContext context) {
    final bloc = context.read<ContractorBloc>();

    double tempMin = bloc.filterMinAmount ?? 0;
    double tempMax = bloc.filterMaxAmount ?? 5000;
    DateTime? tempDate = bloc.filterPayDate;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Wrap(
                children: [
                  /// HANDLE
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Filter Contractors",
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// AMOUNT BOXES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _amountBox("Min Amount", tempMin.toInt()),
                      _amountBox("Max Amount", tempMax.toInt()),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// RANGE SLIDER
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),
                    min: 0,
                    max: 5000,
                    divisions: 100,
                    activeColor: AppColors.primary,
                    labels: RangeLabels(
                      tempMin.toInt().toString(),
                      tempMax.toInt().toString(),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        tempMin = value.start;
                        tempMax = value.end;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// DATE PICKER
                  CustomDateField(
                    label: "Date Of Pay",
                    hint: "Select Pay Date",
                    icon: Icons.calendar_today,
                     initialDate: tempDate,
                    onDateSelected: (date) {
                      setSheetState(() => tempDate = date);
                    },
                  ),

                  const SizedBox(height: 24),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: "Reset",
                          onTap: () {
                            bloc.add(FilterContractorsEvent()); // clears all
                            setState(() {}); // refresh filter indicator
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: "Apply",
                          icon: Icons.check,
                          onTap: () {
                            bloc.add(
                              FilterContractorsEvent(
                                minAmount: tempMin > 0 ? tempMin : null,
                                maxAmount: tempMax < 5000 ? tempMax : null,
                                payDate: tempDate,
                              ),
                            );
                            setState(() {}); // refresh filter indicator
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _amountBox(String title, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.small.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "£$value",
              style: AppTextStyles.label.copyWith(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
