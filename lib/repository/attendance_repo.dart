import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_model.dart';
import '../models/shift_model.dart';

class AttendanceRepository {
  final supabase = Supabase.instance.client;

  /// =====================================================
  /// SHIFT
  /// =====================================================

  /// SAVE SHIFT
  Future<ShiftModel> saveShift(ShiftModel model) async {
    final response = await supabase
        .from('shifts')
        .insert(model.toJson())
        .select()
        .single();

    return ShiftModel.fromJson(response);
  }

  /// UPDATE SHIFT
  Future<ShiftModel> updateShift(ShiftModel model) async {
    final response = await supabase
        .from('shifts')
        .update(model.toJson())
        .eq('id', model.id!)
        .select()
        .single();

    return ShiftModel.fromJson(response);
  }

  /// GET SHIFT
  Future<ShiftModel?> getShift(int id) async {
    final response = await supabase
        .from('shifts')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ShiftModel.fromJson(response);
  }

  /// GET ALL SHIFTS
  Future<List<ShiftModel>> getAllShifts() async {
    final response = await supabase
        .from('shifts')
        .select()
        .order('created_at', ascending: false);

    return response.map<ShiftModel>((e) => ShiftModel.fromJson(e)).toList();
  }

  /// DELETE SHIFT
  Future<void> deleteShift(int id) async {
    await supabase.from('shifts').delete().eq('id', id);
  }

  /// =====================================================
  /// ATTENDANCE
  /// =====================================================

  /// SAVE ATTENDANCE
  Future<AttendanceModel> saveAttendance(AttendanceModel model) async {
    final response = await supabase
        .from('attendance')
        .insert(model.toJson())
        .select('''
            *,
            users (
              id,
              full_name,
              email,
              emp_id
            ),
            shifts (
              id,
              shift_name
            )
          ''')
        .single();

    return AttendanceModel.fromJson(response);
  }

  /// UPDATE ATTENDANCE
  Future<AttendanceModel> updateAttendance(AttendanceModel model) async {
    final response = await supabase
        .from('attendance')
        .update(model.toJson())
        .eq('id', model.id!)
        .select('''
          *,
          users (
            id,
            full_name,
            email,
            emp_id
          ),
          shifts (
            id,
            shift_name
          )
        ''')
        .single();

    return AttendanceModel.fromJson(response);
  }

  /// GET ATTENDANCE
  Future<AttendanceModel?> getAttendance(int id) async {
    final response = await supabase
        .from('attendance')
        .select('''
          *,
          users (
            id,
            full_name,
            email,
            emp_id
          ),
          shifts (
            id,
            shift_name
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return AttendanceModel.fromJson(response);
  }

  /// GET ALL ATTENDANCE
  Future<List<AttendanceModel>> getAllAttendance() async {
    final response = await supabase
        .from('attendance')
        .select('''
          *,
          users (
            id,
            full_name,
            email,
            emp_id
          ),
          shifts (
            id,
            shift_name
          )
        ''')
        .order('created_at', ascending: false);

    return response
        .map<AttendanceModel>((e) => AttendanceModel.fromJson(e))
        .toList();
  }

  /// GET USER ATTENDANCE
  Future<List<AttendanceModel>> getUserAttendance(String userId) async {
    final response = await supabase
        .from('attendance')
        .select('''
          *,
          users (
            id,
            full_name,
            email,
            emp_id
          ),
          shifts (
            id,
            shift_name
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response
        .map<AttendanceModel>((e) => AttendanceModel.fromJson(e))
        .toList();
  }

  /// =====================================================
  /// GET PAGINATED ATTENDANCE + SEARCH
  /// =====================================================
  Future<List<AttendanceModel>> getAttendancePaginated({
    int page = 1,
    int limit = 20,
    String search = '',
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final from = (page - 1) * limit;
    final to = from + limit - 1;

    dynamic query = supabase.from('attendance').select('''
      *,
      users!inner(
        id,
        full_name,
        email,
        phone,
        emp_id
      ),
      shifts(
        id,
        shift_name
      )
    ''');

    /// SEARCH
    if (search.trim().isNotEmpty) {
      query = query.or(
        'full_name.ilike.%$search%,'
        'email.ilike.%$search%,'
        'phone.ilike.%$search%,'
        'emp_id.ilike.%$search%',
        referencedTable: 'users',
      );
    }

    if (startDate != null) {
      query = query.gte('shift_start', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('shift_end', endDate.toIso8601String());
    }

    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status.toLowerCase());
    }
    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return response
        .map<AttendanceModel>((e) => AttendanceModel.fromJson(e))
        .toList();
  }

  /// DELETE ATTENDANCE
  Future<void> deleteAttendance(int id) async {
    await supabase.from('attendance').delete().eq('id', id);
  }
}
