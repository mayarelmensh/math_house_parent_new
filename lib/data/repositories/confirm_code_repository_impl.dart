import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/repository/data_sources/remote_data_source/confirm_code_data_source.dart';
import 'package:math_house_parent_new/domain/repository/getStudents/confirm_code_repository.dart';
import '../../domain/entities/confirm_code_response_entity.dart';

@Injectable(as: ConfirmCodeRepository)
class ConfirmCodeRepositoryImpl implements ConfirmCodeRepository {
  ConfirmCodeDataSource confirmCodeDataSource;
  ConfirmCodeRepositoryImpl({required this.confirmCodeDataSource});
  @override
  Future<Either<Failures, ConfirmCodeResponseEntity>> confirmCode(
    int code,
  ) async {
    var either = await confirmCodeDataSource.confirmCode(code);
    return either.fold((error) => Left(error), (response) => (Right(response)));
  }
}
