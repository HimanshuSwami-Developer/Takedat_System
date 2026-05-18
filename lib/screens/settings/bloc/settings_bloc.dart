import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/models/users_model.dart';
import 'package:takedat_app/repository/user_repo.dart';
import 'package:takedat_app/screens/settings/bloc/settings_event.dart';
import 'package:takedat_app/screens/settings/bloc/settings_state.dart';

class ManageStatusBloc
    extends Bloc<ManageStatusEvent, ManageStatusState> {

  final UserRepository repository;

  List<UserModel> users = [];

  int currentPage = 0;

  bool hasMore = true;

  String currentSearch = '';

  bool isLoadingMore = false;

  ManageStatusBloc(this.repository)
      : super(ManageStatusInitial()) {

    /// LOAD
    on<LoadUsersEvent>((event, emit) async {
      emit(ManageStatusLoading());

      try {
        currentPage = 0;
        hasMore = true;

        users = await repository.getUsers(
          page: currentPage,
        );

        if (users.length < 20) {
          hasMore = false;
        }

        emit(
          ManageStatusLoaded(
            users: users,
            hasMore: hasMore,
          ),
        );
      } catch (e) {
        emit(ManageStatusFailure(e.toString()));
      }
    });

    /// SEARCH
    on<SearchUsersEvent>((event, emit) async {
      emit(ManageStatusLoading());

      try {
        currentSearch = event.query;

        currentPage = 0;

        users = await repository.getUsers(
          page: currentPage,
          search: currentSearch,
        );

        if (users.length < 20) {
          hasMore = false;
        }

        emit(
          ManageStatusLoaded(
            users: users,
            hasMore: hasMore,
          ),
        );
      } catch (e) {
        emit(ManageStatusFailure(e.toString()));
      }
    });

    /// LOAD MORE
    on<LoadMoreUsersEvent>((event, emit) async {
      if (isLoadingMore || !hasMore) return;

      try {
        isLoadingMore = true;

        currentPage++;

        final more = await repository.getUsers(
          page: currentPage,
          search: currentSearch,
        );

        if (more.length < 20) {
          hasMore = false;
        }

        users.addAll(more);

        emit(
          ManageStatusLoaded(
            users: users,
            hasMore: hasMore,
          ),
        );

        isLoadingMore = false;
      } catch (e) {
        isLoadingMore = false;

        emit(ManageStatusFailure(e.toString()));
      }
    });

    /// TOGGLE STATUS
    on<ToggleUserStatusEvent>((event, emit) async {
      try {
        final updated = await repository.updateUserStatus(
          userId: event.userId,
          isActive: event.isActive,
        );

        final index = users.indexWhere(
          (e) => e.id == updated.id,
        );

        if (index != -1) {
          users[index] = updated;
        }

        emit(
          ManageStatusLoaded(
            users: users,
            hasMore: hasMore,
          ),
        );
      } catch (e) {
        emit(ManageStatusFailure(e.toString()));
      }
    });
  }
}