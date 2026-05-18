abstract class ManageStatusEvent {}

class LoadUsersEvent extends ManageStatusEvent {}

class SearchUsersEvent extends ManageStatusEvent {
  final String query;

  SearchUsersEvent(this.query);
}

class ToggleUserStatusEvent extends ManageStatusEvent {
  final String userId;
  final bool isActive;

  ToggleUserStatusEvent({
    required this.userId,
    required this.isActive,
  });
}

class LoadMoreUsersEvent extends ManageStatusEvent {}