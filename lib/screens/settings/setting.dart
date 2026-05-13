import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/router/my_routes.dart';

/// =======================================
/// MODEL
/// =======================================

class EmployeeModel {
  final String name;
  final String empId;
  final String email;
  final String phone;
  final String address;
  final String image;
  bool isActive;

  EmployeeModel({
    required this.name,
    required this.empId,
    required this.email,
    required this.phone,
    required this.address,
    required this.image,
    required this.isActive,
  });
}

/// =======================================
/// DUMMY DATA
/// =======================================

final List<EmployeeModel> employeeList = [
  EmployeeModel(
    name: "Marcus Richardson",
    empId: "EMP-9010",
    email: "m.richardson@corp.com",
    phone: "+1 (555) 123-4567",
    address: "422 Oakwood Dr, Ste 100, San Francisco, CA",
    image:
        "https://randomuser.me/api/portraits/men/32.jpg",
    isActive: true,
  ),

  EmployeeModel(
    name: "Elena Vance",
    empId: "EMP-88421",
    email: "e.vance@workforce.com",
    phone: "+1 (555) 987-6543",
    address: "1992 Lincoln Ave, Apt 4C, Austin, TX",
    image:
        "https://randomuser.me/api/portraits/women/44.jpg",
    isActive: true,
  ),

  EmployeeModel(
    name: "David Miller",
    empId: "EMP-77102",
    email: "d.miller@inactive.com",
    phone: "+1 (555) 222-3333",
    address: "78 North St, Denver, CO",
    image:
        "https://randomuser.me/api/portraits/men/55.jpg",
    isActive: false,
  ),

  EmployeeModel(
    name: "Sarah Jenkins",
    empId: "EMP-88450",
    email: "s.jenkins@corp.com",
    phone: "+1 (555) 444-5555",
    address: "33 Birch Lane, Seattle, WA",
    image:
        "https://randomuser.me/api/portraits/women/68.jpg",
    isActive: true,
  ),
];

/// =======================================
/// SCREEN
/// =======================================

class ManageStatusScreen extends StatefulWidget {
  const ManageStatusScreen({super.key});

  @override
  State<ManageStatusScreen> createState() => _ManageStatusScreenState();
}

class _ManageStatusScreenState extends State<ManageStatusScreen> {
  final TextEditingController searchController = TextEditingController();

  List<EmployeeModel> filteredList = employeeList;

  void _searchUsers(String value) {
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
      backgroundColor: const Color(0xFFF3F5F2),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00895F),
        elevation: 3,
        onPressed: () {
          context.go(MyRoutes.registerScreen);
        },
        child: const Icon(
          Icons.group_add_rounded,
          color: Colors.white,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),

          child: Column(
            children: [
              /// =======================================
              /// TOP BAR
              /// =======================================

              const SizedBox(height: 8),

              GestureDetector(
                onTap: ()=>context.pop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                
                        const SizedBox(width: 10),
                
                        Text(
                          "Manage Status",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0E4F3D),
                          ),
                        ),
                      ],
                    ),
                
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// =======================================
              /// SEARCH BAR
              /// =======================================

              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: _searchUsers,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search by name, ID or email...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.tune_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// =======================================
              /// LIST
              /// =======================================

              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  padding: EdgeInsets.zero,

                  itemBuilder: (context, index) {
                    final employee = filteredList[index];

                    return _employeeCard(employee);
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
  /// CARD
  /// =======================================

  Widget _employeeCard(EmployeeModel employee) {
    final inactive = !employee.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: inactive
            ? const Color(0xFFE9ECE8)
            : Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// =======================================
          /// TOP INFO
          /// =======================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(employee.image),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: inactive
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      employee.empId,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: inactive
                            ? Colors.grey
                            : const Color(0xFF00895F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// EMAIL
          _infoRow(
            Icons.mail_outline_rounded,
            employee.email,
            inactive,
          ),

          const SizedBox(height: 6),

          /// PHONE
          _infoRow(
            Icons.call_outlined,
            employee.phone,
            inactive,
          ),

          const SizedBox(height: 10),

          /// ADDRESS
          Text(
            employee.address,
            style: TextStyle(
              fontSize: 13,
              color: inactive
                  ? Colors.grey
                  : Colors.black54,
            ),
          ),

          const SizedBox(height: 12),

          /// =======================================
          /// STATUS
          /// =======================================

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: employee.isActive
                      ? const Color(0xFFE2F5EA)
                      : const Color(0xFFE5E6EC),

                  borderRadius: BorderRadius.circular(30),
                ),

                child: Text(
                  employee.isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: employee.isActive
                        ? const Color(0xFF2B7F5E)
                        : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 42,
                height: 24,

                child: Switch(
                  value: employee.isActive,

                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF00895F),

                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,

                  onChanged: (value) {
                    setState(() {
                      employee.isActive = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =======================================
  /// INFO ROW
  /// =======================================

  Widget _infoRow(
    IconData icon,
    String text,
    bool inactive,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: inactive
              ? Colors.grey
              : Colors.black54,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: inactive
                  ? Colors.grey
                  : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}