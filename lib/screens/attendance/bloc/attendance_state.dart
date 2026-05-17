import 'package:takedat_app/models/attendance_model.dart';
import 'package:takedat_app/models/shift_model.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';

abstract class AttendanceState {}

class AttendanceInitial
    extends AttendanceState {}

class AttendanceLoading
    extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<ShiftModel> shifts;
  final List<AttendanceModel> attendance;
  final bool hasMore;

  AttendanceLoaded({
    required this.shifts,
    required this.attendance,
    this.hasMore = true,
  });
}

class AttendanceSuccess
    extends AttendanceState {}

class AttendanceFailure
    extends AttendanceState {

  final String error;

  AttendanceFailure(this.error);
}