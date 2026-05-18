/// ======================================================
/// MANAGE STATUS SCREEN
/// ======================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:takedat_app/models/users_model.dart';
import 'package:takedat_app/router/my_routes.dart';

import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/settings/bloc/settings_bloc.dart';
import 'package:takedat_app/screens/settings/bloc/settings_event.dart';
import 'package:takedat_app/screens/settings/bloc/settings_state.dart';

class ManageStatusScreen extends StatefulWidget {
  const ManageStatusScreen({super.key});

  @override
  State<ManageStatusScreen> createState() => _ManageStatusScreenState();
}

class _ManageStatusScreenState extends State<ManageStatusScreen> {
  final TextEditingController searchController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  Timer? _debounce;

  late ManageStatusBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = context.read<ManageStatusBloc>()..add(LoadUsersEvent());

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        bloc.add(LoadMoreUsersEvent());
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();

    scrollController.dispose();

    _debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),

          child: BlocBuilder<ManageStatusBloc, ManageStatusState>(
            builder: (context, state) {
              final users = state is ManageStatusLoaded
                  ? state.users
                  : <UserModel>[];

              return Column(
                children: [
                  const SizedBox(height: 8),

                  /// TOP BAR
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "Manage Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E4F3D),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// SEARCH
                  SizedBox(
                    height: 45,
                    child: CustomTextField(
                      controller: searchController,
                      label: "",
                      hint: "Search by name, email, number, emp id",
                      icon: Icons.search,

                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) {
                          _debounce!.cancel();
                        }

                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            bloc.add(SearchUsersEvent(value.trim()));
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LOADING
                  if (state is ManageStatusLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  /// ERROR
                  else if (state is ManageStatusFailure)
                    Expanded(child: Center(child: Text(state.message)))
                  /// LIST
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,

                        itemCount: users.length,

                        itemBuilder: (context, index) {
                          final user = users[index];

                          return _employeeCard(user);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

/// COMPACT CARD
Widget _employeeCard(UserModel employee) {
  final inactive = !employee.isActive;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),

    padding: const EdgeInsets.all(14),

    decoration: BoxDecoration(
      color: inactive
          ? const Color(0xFFF4F4F4)
          : Colors.white,

      borderRadius: BorderRadius.circular(20),

      border: Border.all(
        color: inactive
            ? Colors.grey.shade300
            : const Color(0xFFE7ECE9),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        /// AVATAR
        CircleAvatar(
          radius: 24,

          backgroundColor: inactive
              ? Colors.grey.shade300
              : const Color(0xFF00895F),

          child: Text(
            employee.fullName.isNotEmpty
                ? employee.fullName[0].toUpperCase()
                : "U",

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        const SizedBox(width: 14),

        /// MAIN INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// TOP ROW
              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        /// NAME
                        Text(
                          employee.fullName,

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,

                            color: inactive
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 3),

                        /// EMAIL
                        Text(
                          employee.email,

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 12.5,

                            color: inactive
                                ? Colors.grey
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// SWITCH
                  Transform.scale(
                    scale: .8,

                    child: Switch(
                      value: employee.isActive,

                      activeColor: Colors.white,

                      activeTrackColor:
                          const Color(0xFF00895F),

                      inactiveThumbColor: Colors.white,

                      inactiveTrackColor:
                          Colors.grey.shade400,

                      onChanged: (value) {
                        context
                            .read<ManageStatusBloc>()
                            .add(
                              ToggleUserStatusEvent(
                                userId: employee.id!,
                                isActive: value,
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// BADGES
              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: [

                  /// EMP ID
                  _badge(
                    icon: Icons.badge_outlined,
                    text: employee.empId,
                    color: const Color(0xFF00895F),
                    bg: const Color(0xFFE8F7F1),
                  ),

                  /// ROLE
                  _badge(
                    icon: Icons.work_outline_rounded,
                    text: employee.role.toUpperCase(),
                    color: Colors.blue.shade700,
                    bg: Colors.blue.withOpacity(.08),
                  ),

                  /// STATUS
                  _badge(
                    icon: Icons.circle,
                    text: employee.isActive
                        ? "ACTIVE"
                        : "INACTIVE",

                    color: employee.isActive
                        ? const Color(0xFF00895F)
                        : Colors.grey,

                    bg: employee.isActive
                        ? const Color(0xFFE8F7F1)
                        : Colors.grey.shade200,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// PHONE + ADDRESS
              Row(
                children: [

                  Icon(
                    Icons.call_outlined,
                    size: 15,

                    color: inactive
                        ? Colors.grey
                        : Colors.black54,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    employee.phone,

                    style: TextStyle(
                      fontSize: 12.5,

                      color: inactive
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Icon(
                    Icons.location_on_outlined,
                    size: 15,

                    color: inactive
                        ? Colors.grey
                        : Colors.black54,
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: Text(
                      employee.address,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 12.5,

                        color: inactive
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
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

/// BADGE
Widget _badge({
  required IconData icon,
  required String text,
  required Color color,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),

    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(30),
    ),

    child: Row(
      mainAxisSize: MainAxisSize.min,

      children: [

        Icon(
          icon,
          size: 12,
          color: color,
        ),

        const SizedBox(width: 4),

        Text(
          text,

          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
            color: color,
          ),
        ),
      ],
    ),
  );
}
}
