import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_bloc.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_event.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_state.dart';
import 'package:takedat_app/screens/employees/widget/employee_card.dart';

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
