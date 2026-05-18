
abstract class EmployeeComplianceEvent {}

class LoadEmployeeComplianceEvent
    extends EmployeeComplianceEvent {

  final bool refresh;

  LoadEmployeeComplianceEvent({
    this.refresh = false,
  });
}

class SearchEmployeeComplianceEvent
    extends EmployeeComplianceEvent {

  final String query;

  SearchEmployeeComplianceEvent(
    this.query,
  );
}

class ToggleExpandEmployeeEvent
    extends EmployeeComplianceEvent {

  final String userId;

  ToggleExpandEmployeeEvent(
    this.userId,
  );
}