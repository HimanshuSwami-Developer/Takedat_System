import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/repository/attendance_repo.dart';

import '../../../models/attendance_model.dart';
import '../../../models/shift_model.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  List<ShiftModel> shifts = [];

  List<AttendanceModel> attendance = [];

  int currentPage = 1;

  bool hasMore = true;

  bool isLoadingMore = false;

  String currentSearch = '';

  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterStatus;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    /// ==================================================
    /// LOAD SHIFTS
    /// ==================================================

    on<LoadShiftsEvent>((event, emit) async {
      emit(AttendanceLoading());

      try {
        shifts = await repository.getAllShifts();

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// SAVE SHIFT
    /// ==================================================

    on<SaveShiftEvent>((event, emit) async {
      try {
        final response = await repository.saveShift(event.model);

        shifts.insert(0, response);

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// UPDATE SHIFT
    /// ==================================================

    on<UpdateShiftEvent>((event, emit) async {
      try {
        final response = await repository.updateShift(event.model);

        final index = shifts.indexWhere((e) => e.id == response.id);

        if (index != -1) {
          shifts[index] = response;
        }

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// DELETE SHIFT
    /// ==================================================

    on<DeleteShiftEvent>((event, emit) async {
      try {
        await repository.deleteShift(event.id);

        shifts.removeWhere((e) => e.id == event.id);

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// LOAD ATTENDANCE
    /// ==================================================

    on<LoadAttendanceEvent>((event, emit) async {
      emit(AttendanceLoading());

      try {
        currentPage = 1;
        hasMore = true;

        attendance = await repository.getAttendancePaginated(
          page: currentPage,
          search: currentSearch,
        );

        if (attendance.length < 20) {
          hasMore = false;
        }

        emit(
          AttendanceLoaded(
            shifts: shifts,
            attendance: attendance,
            hasMore: hasMore,
          ),
        );
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    on<LoadMoreAttendanceEvent>((event, emit) async {
      if (isLoadingMore || !hasMore) return;

      try {
        isLoadingMore = true;

        currentPage++;

        final response = await repository.getAttendancePaginated(
          page: currentPage,
          search: currentSearch,
          startDate: filterStartDate,
          endDate: filterEndDate,
          status: filterStatus,
        );

        if (response.length < 20) {
          hasMore = false;
        }

        attendance.addAll(response);

        emit(
          AttendanceLoaded(
            shifts: shifts,
            attendance: attendance,
            hasMore: hasMore,
          ),
        );

        isLoadingMore = false;
      } catch (e) {
        isLoadingMore = false;

        emit(AttendanceFailure(e.toString()));
      }
    });

    on<SearchAttendanceEvent>((event, emit) async {
      emit(AttendanceLoading());

      try {
        currentSearch = event.search;

        currentPage = 1;

        hasMore = true;

        attendance = await repository.getAttendancePaginated(
          page: currentPage,
          search: currentSearch,
        );

        if (attendance.length < 20) {
          hasMore = false;
        }

        emit(
          AttendanceLoaded(
            shifts: shifts,
            attendance: attendance,
            hasMore: hasMore,
          ),
        );
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    on<FilterAttendanceEvent>((event, emit) async {
      emit(AttendanceLoading());

      try {
        filterStartDate = event.startDate;
        filterEndDate = event.endDate;
        filterStatus = event.status;

        currentPage = 1;
        hasMore = true;

        attendance = await repository.getAttendancePaginated(
          page: currentPage,
          search: currentSearch,
          startDate: filterStartDate,
          endDate: filterEndDate,
          status: filterStatus,
        );

        if (attendance.length < 20) {
          hasMore = false;
        }

        emit(
          AttendanceLoaded(
            shifts: shifts,
            attendance: attendance,
            hasMore: hasMore,
          ),
        );
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// SAVE ATTENDANCE
    /// ==================================================

    on<SaveAttendanceEvent>((event, emit) async {
      try {
        final response = await repository.saveAttendance(event.model);

        attendance.insert(0, response);

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// UPDATE ATTENDANCE
    /// ==================================================

    on<UpdateAttendanceEvent>((event, emit) async {
      try {
        final response = await repository.updateAttendance(event.model);

        final index = attendance.indexWhere((e) => e.id == response.id);

        if (index != -1) {
          attendance[index] = response;
        }

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });

    /// ==================================================
    /// DELETE ATTENDANCE
    /// ==================================================

    on<DeleteAttendanceEvent>((event, emit) async {
      try {
        await repository.deleteAttendance(event.id);

        attendance.removeWhere((e) => e.id == event.id);

        emit(AttendanceLoaded(shifts: shifts, attendance: attendance));
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
      }
    });
  }
}
