import 'package:dartz/dartz.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/login_response_entity.dart';
import 'package:math_house_parent_new/domain/entities/register_response_entity.dart';

abstract class AuthRepository {
  Future<Either<Failures, RegisterResponseEntity>> register(
    String name,
    String email,
    String phone,
    String password,
    String confPassword,
  );

  Future<Either<Failures, LoginResponseEntity>> login(
    String email,
    String password,
  );
}
