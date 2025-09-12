import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/courses_response_entity.dart';
import 'package:math_house_parent_new/domain/repository/courses_list/courses_list_repository.dart';

@injectable
class CoursesListUseCase {
  CoursesListRepository coursesListRepository;
  CoursesListUseCase({required this.coursesListRepository});

  Future<Either<Failures, CoursesResponseEntity>> invoke() async {
    return await coursesListRepository.getCoursesList();
  }
}
