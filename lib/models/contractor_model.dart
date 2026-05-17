class ContractorModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final double amount;
  final String? paySlip;
  final DateTime payDate;
  final DateTime? createdAt;
  final DateTime? updatedAt; // ✅ new

  ContractorModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.amount,
    this.paySlip,
    required this.payDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ContractorModel.fromJson(Map<String, dynamic> json) {
    return ContractorModel(
      id: json['id'] as int?,
      name: json['contractor_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['contact_number'] as String? ?? '',
      amount: (json['pay_amount'] as num? ?? 0).toDouble(),
      paySlip: json['pay_slip'] as String?,
      // ✅ timestamptz — full datetime with time preserved
      payDate: DateTime.parse(json['pay_date'] as String).toLocal(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'contractor_name': name,
      'email': email,
      'contact_number': phone,
      'pay_amount': amount,
      // ✅ UTC ISO8601 with time — correct for timestamptz
      'pay_date': payDate.toUtc().toIso8601String(),
    };
    if (paySlip != null) map['pay_slip'] = paySlip;
    return map;
  }

  ContractorModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    double? amount,
    String? paySlip,
    DateTime? payDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      amount: amount ?? this.amount,
      paySlip: paySlip ?? this.paySlip,
      payDate: payDate ?? this.payDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}