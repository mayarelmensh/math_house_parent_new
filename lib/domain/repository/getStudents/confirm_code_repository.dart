import 'package:dartz/dartz.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/confirm_code_response_entity.dart';

abstract class ConfirmCodeRepository {
  Future<Either<Failures, ConfirmCodeResponseEntity>> confirmCode(int code);
}
