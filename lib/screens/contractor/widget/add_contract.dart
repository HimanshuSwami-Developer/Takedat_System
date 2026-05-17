
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/models/contractor_model.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';

class AddContractSheet extends StatefulWidget {
  final ContractorModel? contractor;
  // ✅ Returns model + optional file (for pay slip upload)
  final Function(ContractorModel model, XFile? paySlipFile) onSave;

  const AddContractSheet({
    super.key,
    this.contractor,
    required this.onSave,
  });

  @override
  State<AddContractSheet> createState() => _AddContractSheetState();
}

class _AddContractSheetState extends State<AddContractSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _amountController;

  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    final c = widget.contractor;
    _nameController = TextEditingController(text: c?.name ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _amountController =
        TextEditingController(text: c?.amount != null ? c!.amount.toString() : '');
    _selectedDate = c?.payDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  XFile? _selectedFile; // ✅ XFile instead of File

  Future<void> _pickFile() async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedFile = image); // ✅ store XFile directly
      }
    } catch (e) {
      debugPrint("Image Picker Error: $e");
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final model = ContractorModel(
      id: widget.contractor?.id,
      name: name,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      payDate: _selectedDate ?? DateTime.now(),
      paySlip: widget.contractor?.paySlip,
    );

    widget.onSave(model, _selectedFile);
    context.pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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

            const SizedBox(height: 18),

            Text(
              widget.contractor == null ? "Add Contract" : "Edit Contract",
              style: AppTextStyles.label.copyWith(
                fontSize: 18,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 22),

            CustomTextField(
              controller: _nameController,
              label: "Contractor",
              hint: "Enter name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 10),

            CustomTextField(
              controller: _emailController,
              label: "Email",
              hint: "Enter email",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 10),

            CustomTextField(
              controller: _phoneController,
              label: "Contact",
              hint: "Enter contact number",
              icon: Icons.call_outlined,
            ),

            const SizedBox(height: 10),

            CustomDateField(
              label: "Pay Date",
              hint: "Select pay date",
              showTime: true,
              icon: Icons.calendar_today,
              initialDate: _selectedDate,
              onDateSelected: (date) => _selectedDate = date,
            ),

            const SizedBox(height: 10),

            CustomTextField(
              controller: _amountController,
              label: "Pay Amount",
              hint: "Enter amount",
              icon: Icons.currency_pound,
            ),

            const SizedBox(height: 14),

            /// UPLOAD FILE
           if(widget.contractor==null) GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.upload_file, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile != null
                                ? _selectedFile!.path.split('/').last
                                : widget.contractor?.paySlip != null
                                    ? "Pay slip attached"
                                    : "Upload PDF or Image",
                            style: AppTextStyles.body
                                .copyWith(color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "PNG, JPG",
                            style: AppTextStyles.small
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                    text: "Cancel",
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: widget.contractor == null ? "Save" : "Update",
                    icon: Icons.check,
                    onTap: _submit,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}