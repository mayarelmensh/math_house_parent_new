import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/get_students_response_entity.dart';

abstract class GetStudentsStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetStudentsInitialState extends GetStudentsStates {}

class GetStudentsLoadingState extends GetStudentsStates {}

class GetStudentsSuccessState extends GetStudentsStates {
  final List<StudentsEntity> students;

  GetStudentsSuccessState({required this.students});

  @override
  List<Object?> get props => [students];
}

class GetMyStudents extends GetStudentsStates {
  final List<MyStudentsEntity> myStudents;

  GetMyStudents({required this.myStudents});

  @override
  List<Object?> get props => [myStudents];
}

class GetStudentsErrorState extends GetStudentsStates {
  final Failures error;

  GetStudentsErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class StudentSelected extends GetStudentsStates {
  final int selectedStudentId;

  StudentSelected(this.selectedStudentId);

  @override
  List<Object?> get props => [selectedStudentId];
}