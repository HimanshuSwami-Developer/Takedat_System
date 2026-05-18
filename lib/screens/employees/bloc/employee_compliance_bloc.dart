import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/models/act_certificate_model.dart';
import 'package:takedat_app/models/sharecode_firstaid_model.dart';
import 'package:takedat_app/models/sia_model.dart';
import 'package:takedat_app/models/signed_document_model.dart';
import 'package:takedat_app/models/users_model.dart';
import 'package:takedat_app/repository/employee_compliance_repo.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_event.dart';
import 'package:takedat_app/screens/employees/bloc/employee_compliance_state.dart';

class EmployeeComplianceBloc
    extends Bloc<EmployeeComplianceEvent, EmployeeComplianceState> {
  final EmployeeComplianceRepository repository;

  EmployeeComplianceBloc(this.repository) : super(EmployeeComplianceInitial()) {
    on<LoadEmployeeComplianceEvent>(_onLoad);

    on<SearchEmployeeComplianceEvent>(_onSearch);

    on<ToggleExpandEmployeeEvent>(_onToggleExpand);
  }

  int _page = 0;

  final int _limit = 20;

  bool _hasReachedMax = false;

  bool _isLoading = false;

  String _search = '';

  List<EmployeeComplianceItem> _employees = [];

  /// =====================================================
  /// LOAD
  /// =====================================================

  Future<void> _onLoad(
    LoadEmployeeComplianceEvent event,

    Emitter<EmployeeComplianceState> emit,
  ) async {
    if (_isLoading || _hasReachedMax) return;

    try {
      _isLoading = true;

      if (event.refresh) {
        _page = 0;

        _hasReachedMax = false;

        _employees.clear();

        emit(EmployeeComplianceLoading());
      }

      final response = await repository.getCompliance(
        page: _page,

        limit: _limit,

        search: _search,
      );

      final items = response.map((e) {
        return EmployeeComplianceItem(
          user: e['user'] as UserModel,

          actCertificate: e['act_certificate'] as ActCertificateModel?,

          sharecodeFirstAid: e['sharecode_firstaid'] as SharecodeFirstAidModel?,

          siaLicence: e['sia_licence'] as SiaLicenceModel?,

          signedDocuments: e['signed_documents'] as SignedDocumentsModel?,
        );
      }).toList();

      if (items.length < _limit) {
        _hasReachedMax = true;
      }

      _employees.addAll(items);

      _page++;

      emit(
        EmployeeComplianceLoaded(
          employees: List.from(_employees),

          hasReachedMax: _hasReachedMax,

          search: _search,
        ),
      );
    } catch (e) {
      emit(EmployeeComplianceError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  /// =====================================================
  /// SEARCH
  /// =====================================================

  Future<void> _onSearch(
    SearchEmployeeComplianceEvent event,

    Emitter<EmployeeComplianceState> emit,
  ) async {
    if (_search == event.query) {
      return;
    }

    _search = event.query;

    _page = 0;

    _hasReachedMax = false;

    _employees.clear();

    add(LoadEmployeeComplianceEvent(refresh: true));
  }

  /// =====================================================
  /// EXPAND
  /// =====================================================

  void _onToggleExpand(
    ToggleExpandEmployeeEvent event,

    Emitter<EmployeeComplianceState> emit,
  ) {
    if (state is! EmployeeComplianceLoaded) {
      return;
    }

    for (final employee in _employees) {
      if (employee.user.id == event.userId) {
        employee.isExpanded = !employee.isExpanded;
      }
    }

    emit(
      (state as EmployeeComplianceLoaded).copyWith(
        employees: List.from(_employees),
      ),
    );
  }
}
