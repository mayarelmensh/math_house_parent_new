import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/login_response_entity.dart';

abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class LoginLoadingState extends LoginStates {}

class LoginErrorState extends LoginStates {
  Failures errors;
  LoginErrorState({required this.errors});
}

class LoginSuccessState extends LoginStates {
  LoginResponseEntity loginResponseEntity;
  LoginSuccessState({required this.loginResponseEntity});
}

class ChangePasswordVisibilityState extends LoginStates {}

class ChangeLoading extends LoginStates {}
