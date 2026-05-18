import 'package:takedat_app/models/users_model.dart';

abstract class ManageStatusState {}

class ManageStatusInitial extends ManageStatusState {}

class ManageStatusLoading extends ManageStatusState {}

class ManageStatusLoaded extends ManageStatusState {
  final List<UserModel> users;
  final bool hasMore;

  ManageStatusLoaded({
    required this.users,
    required this.hasMore,
  });
}

class ManageStatusFailure extends ManageStatusState {
  final String message;

  ManageStatusFailure(this.message);
}