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
              /// SEARCH
              _searchField(),

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
    return Container(
      width: double.infinity,
      child: CustomTextField(
        onChanged: (value) {
          /// CANCEL OLD TIMER
          if (_debounce?.isActive ?? false) {
            _debounce?.cancel();
          }

          /// DEBOUNCE
          _debounce = Timer(const Duration(milliseconds: 500), () {
            final query = value.trim();

            bloc.add(SearchEmployeeComplianceEvent(query));
          });
        },
        label: "",
        hint: "Search employee or ID or number or email",
        icon: Icons.search,
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
