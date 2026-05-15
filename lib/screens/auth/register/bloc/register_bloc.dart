import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/models/users_model.dart';
import 'package:takedat_app/screens/auth/register/bloc/register_event.dart';
import 'package:takedat_app/screens/auth/register/bloc/register_state.dart';

import '../../../../constant/session_keys.dart';
import '../../../../constant/session_manager.dart';
import '../../../../repository/user_repo.dart';

class RegisterBloc
    extends Bloc<RegisterEvent, RegisterState> {

  final UserRepository repository;

  RegisterBloc(this.repository)
      : super(RegisterInitial()) {

    on<RegisterUserEvent>((event, emit) async {

      emit(RegisterLoading());

      try {

        final user = UserModel(
          empId: event.empId,
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          address: event.address,
          role: 'user',
        );

        /// REGISTER USER
        final registeredUser =
            await repository.registerUser(user);

        /// SAVE SESSION
        await SessionManager.saveBool(
          SessionKeys.isLoggedIn,
          true,
        );

        await SessionManager.saveString(
          SessionKeys.userId,
          registeredUser.id??"",
        );

        await SessionManager.saveString(
          SessionKeys.empId,
          registeredUser.empId,
        );

        await SessionManager.saveString(
          SessionKeys.fullName,
          registeredUser.fullName,
        );

        await SessionManager.saveString(
          SessionKeys.email,
          registeredUser.email,
        );

        await SessionManager.saveString(
          SessionKeys.phone,
          registeredUser.phone,
        );

        await SessionManager.saveString(
          SessionKeys.address,
          registeredUser.address,
        );


        await SessionManager.saveString(
          SessionKeys.role,
          registeredUser.role,
        );

        emit(RegisterSuccess());

      } catch (e) {

        emit(RegisterFailure(e.toString()));
      }
    });
  }
}