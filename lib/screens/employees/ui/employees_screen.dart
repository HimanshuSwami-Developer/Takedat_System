import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/repository/profile_repo.dart';
import 'package:takedat_app/repository/user_repo.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_bloc.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_event.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_state.dart';
import 'package:takedat_app/screens/employees/ui/admin_employee_edit_screen.dart';
import 'package:takedat_app/screens/employees/widget/employee_card.dart';
import 'package:takedat_app/screens/profile/bloc/profile_bloc.dart';
import 'package:takedat_app/screens/profile/bloc/profile_event.dart';

/// =======================================
/// SCREEN
/// =======================================

class EmployeeComplianceScreen extends StatefulWidget {
  const EmployeeComplianceScreen({super.key});

  @override
  State<EmployeeComplianceScreen> createState() =>
      _EmployeeComplianceScreenState();
}

class _EmployeeComplianceScreenState extends State<EmployeeComplianceScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  late EmployeeComplianceBloc bloc;

  String? _filterCompanyCode;

  static const _companies = [
    {'code': 'valeron_protection_group', 'label': 'Valeron Protection Group'},
    {'code': 'tybar_security',           'label': 'Tybar Security'},
    {'code': 'gough_and_kelly',          'label': 'Gough & Kelly'},
  ];

  bool get _hasActiveFilter => _filterCompanyCode != null;

  String _companyLabel(String code) =>
      _companies.firstWhere((c) => c['code'] == code,
          orElse: () => {'label': code})['label']!;

  @override
  void initState() {
    super.initState();

    bloc = context.read<EmployeeComplianceBloc>();

    bloc.add(LoadEmployeeComplianceEvent());

    _scrollController.addListener(_pagination);
  }

  Future<void> _openEditScreen(
    BuildContext ctx,
    EmployeeComplianceItem item,
  ) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ProfileBloc(
            profileRepository: ProfileRepository(),
            userRepository: UserRepository(),
          )..add(LoadProfileEvent(userId: item.user.id!)),
          child: AdminEmployeeEditScreen(employee: item),
        ),
      ),
    );
    if (!mounted) return;
    bloc.add(LoadEmployeeComplianceEvent(refresh: true));
  }

  void _pagination() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      bloc.add(LoadEmployeeComplianceEvent());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();

    searchController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            children: [
              /// SEARCH + FILTER
              Row(
                children: [
                  Expanded(child: _searchField()),
                  const SizedBox(width: 10),
                  _filterButton(),
                ],
              ),

              if (_hasActiveFilter) ...[
                const SizedBox(height: 8),
                _activeFilterChip(),
              ],

              const SizedBox(height: 14),

              /// LIST
              Expanded(
                child:
                    BlocBuilder<
                      EmployeeComplianceBloc,
                      EmployeeComplianceState
                    >(
                      builder: (context, state) {
                        if (state is EmployeeComplianceLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is EmployeeComplianceError) {
                          return Center(child: Text(state.message));
                        }

                        if (state is EmployeeComplianceLoaded) {
                          if (state.employees.isEmpty) {
                            return const Center(
                              child: Text("No employees found"),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,

                            itemCount: state.employees.length,

                            itemBuilder: (context, index) {
                              final item = state.employees[index];

                              return EmployeeComplianceCard(
                                employee: item,

                                onTap: () {
                                  bloc.add(
                                    ToggleExpandEmployeeEvent(item.user.id!),
                                  );
                                },

                                onEdit: () => _openEditScreen(context, item),
                              );
                            },
                          );
                        }

                        return const SizedBox();
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,

        elevation: 4,

        icon: const Icon(Icons.download_rounded, color: Colors.white),

        label: const Text(
          "Download Documents",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),

        onPressed: () async {
          BuildContext? dialogContext;

          /// SHOW LOADER
          showDialog(
            context: context,

            barrierDismissible: false,

            builder: (ctx) {
              dialogContext = ctx;

              return const _DownloadDialog();
            },
          );

          try {
            /// DOWNLOAD
            await bloc.repository.downloadDocumentsBucket();

            /// CLOSE DIALOG
            if (dialogContext != null) {
              Navigator.of(dialogContext!, rootNavigator: true).pop();
            }

            if (!context.mounted) return;

            /// SUCCESS
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,

                backgroundColor: Colors.green,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),

                    SizedBox(width: 12),

                    Expanded(child: Text("Documents downloaded successfully")),
                  ],
                ),
              ),
            );
          } catch (e) {
            /// CLOSE DIALOG
            if (dialogContext != null) {
              Navigator.of(dialogContext!, rootNavigator: true).pop();
            }

            if (!context.mounted) return;

            /// ERROR
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,

                backgroundColor: Colors.red,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                content: Text(e.toString()),
              ),
            );
          }
        },
      ),
    );
  }

  /// SEARCH FIELD
  Widget _searchField() {
    return CustomTextField(
      controller: searchController,
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          bloc.add(SearchEmployeeComplianceEvent(value.trim()));
        });
      },
      label: "",
      hint: "Search employee or ID or number or email",
      icon: Icons.search,
    );
  }

  Widget _filterButton() {
    return GestureDetector(
      onTap: _openFilterSheet,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _hasActiveFilter
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasActiveFilter
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          color: _hasActiveFilter ? AppColors.primary : Colors.grey.shade600,
          size: 20,
        ),
      ),
    );
  }

  Widget _activeFilterChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _companyLabel(_filterCompanyCode!),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                setState(() => _filterCompanyCode = null);
                bloc.add(FilterEmployeeComplianceEvent());
              },
              child: Icon(Icons.close, size: 14, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet() {
    String? tempCode = _filterCompanyCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (_, setSheet) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Filter Employees",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Show only employees from a specific company",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "COMPANY",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _CompanyChip(
                          label: "All",
                          isSelected: tempCode == null,
                          onTap: () => setSheet(() => tempCode = null),
                        ),
                        ..._companies.map(
                          (c) => _CompanyChip(
                            label: c['label']!,
                            isSelected: tempCode == c['code'],
                            onTap: () => setSheet(() => tempCode = c['code']),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                setState(() => _filterCompanyCode = null);
                                bloc.add(FilterEmployeeComplianceEvent());
                                Navigator.pop(sheetCtx);
                              },
                              child: const Text(
                                "Reset",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            onPressed: () {
                              setState(() => _filterCompanyCode = tempCode);
                              bloc.add(
                                FilterEmployeeComplianceEvent(
                                  companyCode: tempCode,
                                ),
                              );
                              Navigator.pop(sheetCtx);
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
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
      },
    );
  }
}

class _CompanyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompanyChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/// ======================================================
/// DOWNLOAD DIALOG
/// ======================================================

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog();

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            /// ICON
            RotationTransition(
              turns: controller,

              child: Container(
                height: 80,
                width: 80,

                decoration: const BoxDecoration(
                  color: Color(0x1400C57B),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.folder_zip_rounded,

                  size: 42,

                  color: Color(0xFF00C57B),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Preparing Documents",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            Text(
              "Downloading and compressing employee files...",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),

            const SizedBox(height: 24),

            ClipRRect(
              borderRadius: BorderRadius.circular(30),

              child: const LinearProgressIndicator(
                minHeight: 10,

                backgroundColor: Color(0xFFEAEAEA),

                valueColor: AlwaysStoppedAnimation(Color(0xFF00C57B)),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Please wait...",

              style: TextStyle(
                fontWeight: FontWeight.w600,

                color: Color(0xFF00C57B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
