class AttendanceModel {
  final int? id;
  final String userId;
  final String mode;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final String status;
  final int? shiftId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? shift;

  AttendanceModel({
    this.id,
    required this.userId,
    required this.mode,
    required this.shiftStart,
    required this.shiftEnd,
    required this.status,
    this.shiftId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.shift,
  });

  // ── FROM JSON (Supabase DB response only) ─────────────────────────────────
  // Keys: user_id, mode, shift_start, shift_end, status, shift_id
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id:         json['id'],
      userId:     json['user_id']    ?? '',
      mode:       json['mode']       ?? '',
      shiftStart: DateTime.parse(json['shift_start']),
      shiftEnd:   DateTime.parse(json['shift_end']),
      status:     json['status']     ?? '',
      shiftId:    json['shift_id'],
      createdAt:  json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt:  json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user:  json['users'],
      shift: json['shifts'],
    );
  }

  // ── FROM LOCAL MAP (AddAttendanceShiftSheet.onSave output) ────────────────
  // Keys: userId, mode, shiftStart (DateTime), shiftEnd (DateTime),
  //       status, shiftId, [id] (for updates)
  factory AttendanceModel.fromLocalMap(Map<String, dynamic> data) {
    return AttendanceModel(
      id:         data['id']         as int?,
      userId:     data['userId']     as String,
      mode:       data['mode']       as String,
      shiftStart: data['shiftStart'] as DateTime,
      shiftEnd:   data['shiftEnd']   as DateTime,
      status:     data['status']     as String,
      shiftId:    data['shiftId'] != null ? (data['shiftId'] as num).toInt() : null,
    );
  }

  // ── TO JSON (sent to Supabase) ────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id':     userId,
      'mode':        mode,
      'shift_start': shiftStart.toIso8601String(),
      'shift_end':   shiftEnd.toIso8601String(),
      'status':      status,
      'shift_id':    shiftId,
    };
  }
}