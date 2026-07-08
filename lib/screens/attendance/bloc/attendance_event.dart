import 'package:takedat_app/models/attendance_model.dart';
import 'package:takedat_app/models/shift_model.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';

abstract class AttendanceEvent {}

/// ======================================================
/// SHIFT
/// ======================================================

class LoadShiftsEvent
    extends AttendanceEvent {}

class SaveShiftEvent
    extends AttendanceEvent {

  final ShiftModel model;

  SaveShiftEvent(this.model);
}

class UpdateShiftEvent
    extends AttendanceEvent {

  final ShiftModel model;

  UpdateShiftEvent(this.model);
}

class DeleteShiftEvent
    extends AttendanceEvent {

  final int id;

  DeleteShiftEvent(this.id);
}

/// ======================================================
/// ATTENDANCE
/// ======================================================

class LoadAttendanceEvent
    extends AttendanceEvent {}

class LoadMoreAttendanceEvent extends AttendanceEvent {}

class SearchAttendanceEvent extends AttendanceEvent {
  final String search;

  SearchAttendanceEvent(this.search);
}
  
class FilterAttendanceEvent extends AttendanceEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? companyCode;

  FilterAttendanceEvent({
    this.startDate,
    this.endDate,
    this.status,
    this.companyCode,
  });
}

class SaveAttendanceEvent
    extends AttendanceEvent {

  final AttendanceModel model;

  SaveAttendanceEvent(this.model);
}

class UpdateAttendanceEvent
    extends AttendanceEvent {

  final AttendanceModel model;

  UpdateAttendanceEvent(this.model);
}

class DeleteAttendanceEvent
    extends AttendanceEvent {

  final int id;

  DeleteAttendanceEvent(this.id);
}