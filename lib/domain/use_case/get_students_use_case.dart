import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/get_students_response_entity.dart';
import '../repository/getStudents/get_students_repository.dart';

@injectable
class GetStudentsUseCase {
  final GetStudentsRepository repository;

  GetStudentsUseCase(this.repository);

  Future<Either<Failures, List<StudentsEntity>>> getAllStudents([
    String? query,
  ]) async {
    final result = await repository.getStudents();

    return result.map((students) {
      if (query == null || query.isEmpty) {
        return students.map((dm) => StudentsEntity(
          id: dm.id,
          email: dm.email,
          phone: dm.phone,
          nickName: dm.nickName,
          imageLink: dm.imageLink,
        )).toList();
      }
      final q = query.toLowerCase();
      return students
          .where((s) {
        return s.nickName?.toLowerCase().contains(q) == true ||
            s.email?.toLowerCase().contains(q) == true;
      })
          .map((dm) => StudentsEntity(
        id: dm.id,
        email: dm.email,
        phone: dm.phone,
        nickName: dm.nickName,
        imageLink: dm.imageLink,
      ))
          .toList();
    });
  }

  Future<Either<Failures, List<MyStudentsEntity>>> getMyStudents() async {
    final result = await repository.getMyStudents();

    return result.map((myStudents) {
      return myStudents.map((dm) => MyStudentsEntity(
        id: dm.id,
        email: dm.email,
        phone: dm.phone,
        nickName: dm.nickName,
        imageLink: dm.imageLink,
        categoryId: dm.categoryId,
        category: dm.category != null
            ? CategoryEntity(
          id: dm.category!.id,
          cateName: dm.category!.cateName,
          imageLink: dm.category!.imageLink,
        )
            : null,
      )).toList();
    });
  }
}