import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/constant/session_keys.dart';
import 'package:takedat_app/constant/session_manager.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/utils/app_toast.dart';

import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class PersonalDetailsStep extends StatefulWidget {
  final VoidCallback onNext;

  const PersonalDetailsStep({super.key, required this.onNext});

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  final empIdController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  static const List<Map<String, String>> _companies = [
    {'code': 'valeron_protection_group', 'label': 'Valeron Protection Group'},
    {'code': 'tybar_security', 'label': 'Tybar Security'},
    {'code': 'gough_and_kelly', 'label': 'Gough & Kelly'},
  ];

  String _selectedCompanyCode = 'valeron_protection_group';

  @override
  void dispose() {
    empIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// SAVE SESSION
  Future<void> saveUserSession() async {
    await SessionManager.saveBool(SessionKeys.isLoggedIn, true);

    await SessionManager.saveString(
      SessionKeys.empId,
      empIdController.text.trim(),
    );

    await SessionManager.saveString(
      SessionKeys.fullName,
      nameController.text.trim(),
    );

    await SessionManager.saveString(
      SessionKeys.email,
      emailController.text.trim(),
    );

    await SessionManager.saveString(
      SessionKeys.phone,
      phoneController.text.trim(),
    );

    await SessionManager.saveString(
      SessionKeys.address,
      addressController.text.trim(),
    );

    await SessionManager.saveString(
      SessionKeys.companyCode,
      _selectedCompanyCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) async {
          /// SUCCESS
          if (state is RegisterSuccess) {
            /// SAVE SESSION
            await saveUserSession();

            /// TOAST
            AppToast.success(context, "User Registered Successfully");

            widget.onNext();
          }

          /// ERROR
          if (state is RegisterFailure) {
            AppToast.error(context, state.error);
          }
        },

        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// STEP TITLE
              Text(
                "STEP 1 OF 3",
                style: AppTextStyles.small.copyWith(color: AppColors.primary),
              ),

              const SizedBox(height: 6),

              /// TITLE
              Text(
                "Personal Details",
                style: AppTextStyles.headline.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              /// SUBTITLE
              Text(
                "Please provide your legal information as it appears on your official documents.",
                style: AppTextStyles.small.copyWith(color: Colors.black54),
              ),

              const SizedBox(height: 20),

              /// EMP ID
              CustomTextField(
                controller: empIdController,
                label: "EMP ID",
                hint: "EMP-2001",
                icon: Icons.perm_identity_rounded,
              ),

              /// FULL NAME
              CustomTextField(
                controller: nameController,
                label: "Full Name",
                hint: "Johnathan Doe",
                icon: Icons.person,
              ),

              /// EMAIL
              CustomTextField(
                controller: emailController,
                label: "Email Address",
                hint: "john@example.com",
                icon: Icons.email,
              ),

              /// PHONE
              CustomTextField(
                controller: phoneController,
                label: "Contact Number",
                hint: "+91 9876543210",
                icon: Icons.phone,
              ),

              /// ADDRESS
              CustomTextField(
                controller: addressController,
                label: "Physical Address",
                hint: "123 Business Way, NY",
                isTextArea: true,
              ),

              const SizedBox(height: 12),

              /// COMPANY CODE DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedCompanyCode,
                decoration: InputDecoration(
                  labelText: "Company",
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _companies
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c['code'],
                        child: Text(c['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCompanyCode = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              /// INFO BOX
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.primary),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "This information will be used for identity verification.",
                        style: AppTextStyles.small.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTON
              CustomButton(
                text: state is RegisterLoading ? "Loading..." : "Continue",

                icon: Icons.arrow_forward,

                onTap: () {
                  /// VALIDATION
                  if (empIdController.text.trim().isEmpty ||
                      nameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty) {
                    AppToast.warning(context, "Please fill all fields");

                    return;
                  }

                  /// REGISTER EVENT
                  context.read<RegisterBloc>().add(
                    RegisterUserEvent(
                      empId: empIdController.text.trim(),
                      fullName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      address: addressController.text.trim(),
                      companyCode: _selectedCompanyCode,
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
