import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/send_code_response_entity.dart';
import 'package:math_house_parent_new/domain/repository/getStudents/send_code_to_student_repository.dart';

@injectable
class SendCodeUseCase {
  SendCodeToStudentRepository sendCodeToStudentRepository;
  SendCodeUseCase({required this.sendCodeToStudentRepository});

  Future<Either<Failures, SendCodeResponseEntity>> invoke(int id) {
    return sendCodeToStudentRepository.sendCode(id);
  }
}
