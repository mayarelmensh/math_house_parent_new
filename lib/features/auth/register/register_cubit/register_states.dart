import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/register_response_entity.dart';

abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {}

class RegisterErrorState extends RegisterStates {
  Failures errors;
  RegisterErrorState({required this.errors});
}

class RegisterSuccessState extends RegisterStates {
  RegisterResponseEntity responseEntity;
  RegisterSuccessState({required this.responseEntity});
}

class ChangePasswordVisibilityState extends RegisterStates {}
