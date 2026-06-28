import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/models/attendance_model.dart';
import 'package:takedat_app/models/payment_model.dart';
import 'package:takedat_app/models/users_model.dart';

class PaymentTrackRepository {
  final supabase = Supabase.instance.client;

  /// =====================================================
  /// GET PAYMENTS
  /// =====================================================

  Future<List<PaymentTrackModel>> getPayments({
    int page = 0,
    int limit = 20,
    String search = '',
  }) async {
    final from = page * limit;
    final to   = from + limit - 1;

    dynamic query = supabase.from('attendance').select('''
        id,
        user_id,
        mode,
        shift_start,
        shift_end,
        status,
        shift_id,
        created_at,
        updated_at,
        users!inner(
          id,
          full_name,
          email,
          emp_id,
          phone,
          role,
          address,
          is_active
        ),
        payment_track(
          payment_id,
          user_id,
          attendance_id,
          cash_payment,
          ni_payment,
          expense,
          payment_status,
          created_at,
          updated_at
        )
      ''');

    if (search.trim().isNotEmpty) {
      final q = search.trim();
      query = query.or(
        'full_name.ilike.%$q%,'
        'email.ilike.%$q%,'
        'emp_id.ilike.%$q%,'
        'phone.ilike.%$q%',
        referencedTable: 'users',
      );
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    final List<PaymentTrackModel> payments = [];

    for (final item in response) {
      try {
        final userMap     = item['users'] as Map<String, dynamic>?;
        final paymentList = item['payment_track'] as List?;
        final shiftStart  = _parseDate(item['shift_start']);
        final shiftEnd    = _parseDate(item['shift_end']);

        if (shiftStart == null || shiftEnd == null) continue;

        final attendance = AttendanceModel.fromJson({
          'id':         item['id'],
          'user_id':    item['user_id'] ?? '',
          'mode':       item['mode'] ?? '',
          'shift_start': shiftStart.toIso8601String(),
          'shift_end':  shiftEnd.toIso8601String(),
          'status':     item['status'] ?? '',
          'shift_id':   item['shift_id'],
          'created_at': item['created_at'],
          'updated_at': item['updated_at'],
          'users':      userMap,
        });

        final user = userMap != null ? _parseUser(userMap) : null;

        if (paymentList != null && paymentList.isNotEmpty) {
          final p = paymentList.first as Map<String, dynamic>;
          payments.add(PaymentTrackModel(
            paymentId:     p['payment_id'] as int?,
            userId:        (p['user_id'] ?? item['user_id'] ?? '') as String,
            attendanceId:  (p['attendance_id'] ?? attendance.id ?? 0) as int,
            cashPayment:   _toDouble(p['cash_payment']),
            niPayment:     _toDouble(p['ni_payment']),
            expense:       _toDouble(p['expense']),
            paymentStatus: (p['payment_status'] ?? 'pending') as String,
            createdAt:     _parseDate(p['created_at']),
            updatedAt:     _parseDate(p['updated_at']),
            user:          user,
            attendance:    attendance,
          ));
        } else {
          payments.add(PaymentTrackModel(
            paymentId:     null,
            userId:        (item['user_id'] ?? '') as String,
            attendanceId:  attendance.id ?? 0,
            cashPayment:   0,
            niPayment:     0,
            expense:       0,
            paymentStatus: 'pending',
            user:          user,
            attendance:    attendance,
          ));
        }
      } catch (e) {
        assert(() { print('[PaymentRepo] $e'); return true; }());
      }
    }

    return payments;
  }

  /// =====================================================
  /// CREATE PAYMENT — returns saved model
  /// =====================================================

  Future<PaymentTrackModel> createPayment(PaymentTrackModel model) async {
    final response = await supabase
      .from('payment_track')
      .insert(model.toMap())
      .select()
      .single();

    return _mergeWithOriginal(response, model);
  }

  /// =====================================================
  /// UPDATE PAYMENT — returns saved model
  /// =====================================================

  Future<PaymentTrackModel> updatePayment({
    required int paymentId,
    required PaymentTrackModel model,
  }) async {
    final response = await supabase
      .from('payment_track')
      .update(model.toMap())
      .eq('payment_id', paymentId)
      .select()
      .single();

    return _mergeWithOriginal(response, model);
  }

  /// =====================================================
  /// UPSERT PAYMENT — returns updated PaymentTrackModel
  /// ✅ FIXED: now returns model so bloc can update list
  /// =====================================================

  Future<PaymentTrackModel> upsertPayment(PaymentTrackModel model) async {
    final existing = await supabase
      .from('payment_track')
      .select('payment_id')
      .eq('attendance_id', model.attendanceId)
      .maybeSingle();

    PaymentTrackModel saved;

    if (existing != null) {
      saved = await updatePayment(
        paymentId: existing['payment_id'] as int,
        model:     model,
      );
    } else {
      saved = await createPayment(model);
    }

    return saved;
  }

  /// =====================================================
  /// DELETE PAYMENT
  /// =====================================================

  Future<void> deletePayment(int paymentId) async {
    await supabase
      .from('payment_track')
      .delete()
      .eq('payment_id', paymentId);
  }

  /// =====================================================
  /// GET SINGLE PAYMENT
  /// =====================================================

  Future<PaymentTrackModel?> getPayment(int paymentId) async {
    final response = await supabase
      .from('payment_track')
      .select('''
        *,
        users:user_id (
          id, full_name, email,
          emp_id, phone, role,
          address, is_active
        )
      ''')
      .eq('payment_id', paymentId)
      .maybeSingle();

    if (response == null) return null;
    return PaymentTrackModel.fromMap(response);
  }

  /// =====================================================
  /// MERGE — DB response + original model (user + attendance)
  /// DB response mein user/attendance nahi hota
  /// isliye original se copy karo
  /// =====================================================

  PaymentTrackModel _mergeWithOriginal(
  Map<String, dynamic> dbResponse,
  PaymentTrackModel original,
) {
  return PaymentTrackModel(
    paymentId:     dbResponse['payment_id'] as int?,
    userId:        (dbResponse['user_id'] ?? original.userId) as String,
    attendanceId:  (dbResponse['attendance_id'] ?? original.attendanceId) as int,
    cashPayment:   _toDouble(dbResponse['cash_payment']),
    niPayment:     _toDouble(dbResponse['ni_payment']),
    expense:       _toDouble(dbResponse['expense']),
    paymentStatus: (dbResponse['payment_status'] ?? 'pending') as String,
    createdAt:     _parseDate(dbResponse['created_at']),
    updatedAt:     _parseDate(dbResponse['updated_at']),
    user:          original.user,
    attendance:    original.attendance,
  );
}

  // =====================================================
  // HELPERS
  // =====================================================

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  UserModel _parseUser(Map<String, dynamic> map) {
    return UserModel(
      id:        map['id']?.toString(),
      empId:     (map['emp_id']    ?? '').toString(),
      fullName:  (map['full_name'] ?? '').toString(),
      email:     (map['email']     ?? '').toString(),
      phone:     (map['phone']     ?? '').toString(),
      address:   (map['address']   ?? '').toString(),
      role:      (map['role']      ?? '').toString(),
      companyCode: (map['company_code'] ?? '').toString(),
      isActive:  map['is_active'] == true || map['is_active'] == 1,
      createdAt: _parseDate(map['created_at']),
    );
  }
}