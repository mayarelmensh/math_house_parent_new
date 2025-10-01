import 'package:dartz/dartz.dart';
import 'package:math_house_parent_new/core/errors/failures.dart';
import 'package:math_house_parent_new/domain/entities/courses_response_entity.dart';

abstract class CoursesListRepository {
  Future<Either<Failures, CoursesResponseEntity>> getCoursesList(int studentId);
}
