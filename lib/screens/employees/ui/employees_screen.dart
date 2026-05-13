import 'package:flutter/material.dart';
import 'package:takedat_app/screens/employees/widget/employee_card.dart';

/// =======================================
/// MODEL
/// =======================================

class EmployeeComplianceModel {
  final String initials;
  final String name;
  final String empId;
  final String email;
  final String address;
  final bool complianceRequired;
  bool isExpanded;

  EmployeeComplianceModel({
    required this.initials,
    required this.name,
    required this.empId,
    required this.email,
    required this.address,
    this.complianceRequired = false,
    this.isExpanded = false,
  });
}

/// =======================================
/// DUMMY DATA
/// =======================================

final List<EmployeeComplianceModel> employeeList = [
  EmployeeComplianceModel(
    initials: "JS",
    name: "Johnathan Smith",
    empId: "88121",
    email: "j.smith@workforce.co",
    address: "24 Westbourne Grove, London, W2 5RH, United Kingdom",
    isExpanded: true,
  ),

  EmployeeComplianceModel(
    initials: "AM",
    name: "Alice Martinez",
    empId: "9902",
    email: "a.martinez@workforce.co",
    address: "12 Oxford Street, Manchester",
  ),

  EmployeeComplianceModel(
    initials: "DW",
    name: "David Wilson",
    empId: "4451",
    email: "d.wilson@workforce.co",
    address: "221B Baker Street, London",
  ),

  EmployeeComplianceModel(
    initials: "RK",
    name: "Robert King",
    empId: "1120",
    email: "r.king@workforce.co",
    address: "7 King Street, Liverpool",
    complianceRequired: true,
  ),
];

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

  List<EmployeeComplianceModel> filteredList = employeeList;

  void _searchEmployee(String value) {
    final query = value.toLowerCase();

    setState(() {
      filteredList = employeeList.where((e) {
        return e.name.toLowerCase().contains(query) ||
            e.empId.toLowerCase().contains(query) ||
            e.email.toLowerCase().contains(query);
      }).toList();
    });
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
              /// =======================================
              /// SEARCH SECTION
              /// =======================================
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: _searchField(
                  hint: "Search by name",
                  icon: Icons.search,
                  controller: searchController,
                  onChanged: _searchEmployee,
                ),
              ),

              const SizedBox(height: 12),

              /// =======================================
              /// LIST
              /// =======================================
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,

                  itemBuilder: (context, index) {
                    final employee = filteredList[index];

                    return EmployeeComplianceCard(
                      employee: employee,

                      onTap: () {
                        setState(() {
                          employee.isExpanded = !employee.isExpanded;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =======================================
  /// SEARCH FIELD
  /// =======================================

  Widget _searchField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    return Container(
      height: 46,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: const Color(0xFFF0F2EE),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,

              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,

                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
