class UserModel {

  final String? id;
  final String empId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String companyCode;
  final DateTime? createdAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.empId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.companyCode,
    required this.isActive,
    this.createdAt,
  });

  /// EMPTY MODEL
  factory UserModel.empty() {
    return UserModel(
      id: null,
      empId: '',
      fullName: '',
      email: '',
      phone: '',
      address: '',
      role: '',
      companyCode: '',
      isActive: false,
      createdAt: null,
    );
  }

  /// TO MAP
  Map<String, dynamic> toMap() {
    return {
      "emp_id": empId,
      "full_name": fullName,
      "email": email,
      "phone": phone,
      "address": address,
      "role": role,
      "company_code": companyCode,
      "is_active": isActive,
    };
  }

  /// FROM MAP
  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      id: map['id']?.toString(),

      empId: map['emp_id'] ?? '',

      fullName: map['full_name'] ?? '',

      email: map['email'] ?? '',

      phone: map['phone'] ?? '',

      address: map['address'] ?? '',

      role: map['role'] ?? '',

      companyCode: map['company_code'] ?? '',

      isActive: map['is_active'] == true || map['is_active'] == 1,

      createdAt: map['created_at'] != null
          ? DateTime.tryParse(
              map['created_at'].toString(),
            )
          : null,
    );
  }

  /// COPY WITH
  UserModel copyWith({
    String? id,
    String? empId,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? companyCode,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      empId: empId ?? this.empId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      companyCode: companyCode ?? this.companyCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return '''
UserModel(
  id: $id,
  empId: $empId,
  fullName: $fullName,
  email: $email,
  phone: $phone,
  address: $address,
  role: $role,
  companyCode: $companyCode,
  isActive: $isActive,
  createdAt: $createdAt
)
''';
  }
}