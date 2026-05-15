class UserModel {

  final String? id;
  final String empId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.empId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
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
  createdAt: $createdAt
)
''';
  }
}