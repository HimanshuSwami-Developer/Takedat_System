import 'package:takedat_app/models/attendance_model.dart';
import 'package:takedat_app/models/users_model.dart';

class PaymentTrackModel {
  /// PAYMENT
  final int? paymentId;

  final String userId;

  final int attendanceId;

  final double cashPayment;

  final double niPayment;

  final double expense;

  final String paymentStatus;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  /// RELATIONS
  final UserModel? user;

  final AttendanceModel? attendance;

  PaymentTrackModel({
    this.paymentId,
    required this.userId,
    required this.attendanceId,
    required this.cashPayment,
    required this.niPayment,
    required this.expense,
    required this.paymentStatus,
    this.createdAt,
    this.updatedAt,

    /// RELATIONS
    this.user,
    this.attendance,
  });

  /// =====================================================
  /// FROM MAP
  /// =====================================================

  factory PaymentTrackModel.fromMap(Map<String, dynamic> map) {
    return PaymentTrackModel(
      paymentId: map['payment_id'],

      userId: map['user_id'] ?? '',

      attendanceId: map['attendance_id'] ?? 0,

      cashPayment: (map['cash_payment'] as num?)?.toDouble() ?? 0,

      niPayment: (map['ni_payment'] as num?)?.toDouble() ?? 0,

      expense: (map['expense'] as num?)?.toDouble() ?? 0,

      paymentStatus: map['payment_status'] ?? 'pending',

      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,

      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,

      /// RELATIONS
      user: map['users'] != null ? UserModel.fromMap(map['users']) : null,

      attendance: map['attendance'] != null
          ? AttendanceModel.fromJson(map['attendance'])
          : null,
    );
  }

  /// =====================================================
  /// TO MAP
  /// ONLY IDS ARE SENT
  /// =====================================================

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,

      'attendance_id': attendanceId,

      'cash_payment': cashPayment,

      'ni_payment': niPayment,

      'expense': expense,

      'payment_status': paymentStatus,
    };
  }

  /// =====================================================
  /// COPY WITH
  /// =====================================================

  PaymentTrackModel copyWith({
    int? paymentId,
    String? userId,
    int? attendanceId,
    double? cashPayment,
    double? niPayment,
    double? expense,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    AttendanceModel? attendance,
  }) {
    return PaymentTrackModel(
      paymentId: paymentId ?? this.paymentId,

      userId: userId ?? this.userId,

      attendanceId: attendanceId ?? this.attendanceId,

      cashPayment: cashPayment ?? this.cashPayment,

      niPayment: niPayment ?? this.niPayment,

      expense: expense ?? this.expense,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,

      user: user ?? this.user,

      attendance: attendance ?? this.attendance,
    );
  }
}
