import 'package:equatable/equatable.dart';
import '../../../../data/models/my_course_model.dart';

abstract class MyCoursesState extends Equatable {
  const MyCoursesState();

  @override
  List<Object?> get props => [];
}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final MyCourseResponse courseResponse;

  const MyCoursesLoaded(this.courseResponse);

  @override
  List<Object> get props => [courseResponse];

  List<MyCourse> get courses => courseResponse.courses;
  int get coursesCount => courseResponse.courses.length;
  List<String> get allTeachers => courseResponse.allTeachers;
}

class MyCoursesError extends MyCoursesState {
  final String message;

  const MyCoursesError(this.message);

  @override
  List<Object> get props => [message];
}

class MyCoursesEmpty extends MyCoursesState {}

class MyCoursesRefreshing extends MyCoursesState {
  final MyCourseResponse? previousCourses;

  const MyCoursesRefreshing(this.previousCourses);

  @override
  List<Object?> get props => [previousCourses];
}