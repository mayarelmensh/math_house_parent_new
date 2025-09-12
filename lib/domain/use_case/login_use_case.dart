import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/login_response_entity.dart';
import 'package:math_house_parent_new/domain/repository/auth/auth_repository.dart';

@injectable
class LoginUseCase {
  AuthRepository authRepository;
  LoginUseCase({required this.authRepository});
  Future<Either<Failures, LoginResponseEntity>> invoke(
    String email,
    String password,
  ) {
    return authRepository.login(email, password);
  }
}
