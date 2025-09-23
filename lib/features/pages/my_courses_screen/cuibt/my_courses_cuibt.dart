import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_manager.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/my_course_model.dart';
import 'my_courses_states.dart';

@injectable
class MyCoursesCubit extends Cubit<MyCoursesState> {
  final ApiManager apiManager;
  MyCourseResponse? _cachedCourses;
  String _currentSearchQuery = '';
  String? _currentTeacher;

  MyCoursesCubit(this.apiManager) : super(MyCoursesInitial());

  MyCourseResponse? get cachedCourses => _cachedCourses;

  Future<void> fetchMyCourses(int userId) async {
    print("fetchMyCourses: Emitting MyCoursesLoading for userId: $userId");
    emit(MyCoursesLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      print("fetchMyCourses: Token: $token");
      if (token == null) {
        print("fetchMyCourses: Emitting MyCoursesError - Authentication token not found");
        emit(const MyCoursesError('Authentication token not found'));
        return;
      }

      print("fetchMyCourses: Making API call to ${EndPoints.myCourses}");
      final response = await apiManager.postData(
        endPoint: EndPoints.myCourses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        body: {'user_id': userId},
      );

      print("fetchMyCourses: API response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        if (response.data == null || response.data['courses'] == null) {
          print("fetchMyCourses: Emitting MyCoursesEmpty - No courses found");
          emit(MyCoursesEmpty());
          return;
        }

        final courseResponse = MyCourseResponse.fromJson(response.data);
        _cachedCourses = courseResponse;
        _currentSearchQuery = '';
        _currentTeacher = null;
        print("fetchMyCourses: Emitting MyCoursesLoaded with ${courseResponse.courses.length} courses");
        _applyFilters();
      } else {
        print("fetchMyCourses: Emitting MyCoursesError - Failed to load courses: ${response.statusMessage}");
        emit(MyCoursesError('Failed to load courses: ${response.statusMessage ?? 'Unknown error'}'));
      }
    } on DioException catch (e) {
      print("fetchMyCourses: DioException - ${e.message}");
      String errorMessage = 'Failed to load courses';
      if (e.response != null) {
        errorMessage = e.response!.data['message'] ?? 'Unknown error occurred';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timed out';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Invalid response from server';
      }
      emit(MyCoursesError(errorMessage));
    } catch (e) {
      print("fetchMyCourses: Unexpected error - ${e.toString()}");
      emit(MyCoursesError('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> refreshMyCourses(int userId) async {
    print("refreshMyCourses: Emitting MyCoursesRefreshing for userId: $userId");
    emit(MyCoursesRefreshing(_cachedCourses));
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      print("refreshMyCourses: Token: $token");
      if (token == null) {
        print("refreshMyCourses: Emitting MyCoursesError - Authentication token not found");
        emit(const MyCoursesError('Authentication token not found'));
        return;
      }

      print("refreshMyCourses: Making API call to ${EndPoints.myCourses}");
      final response = await apiManager.postData(
        endPoint: EndPoints.myCourses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        body: {'user_id': userId},
      );

      print("refreshMyCourses: API response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        if (response.data == null || response.data['courses'] == null) {
          print("refreshMyCourses: Emitting MyCoursesEmpty - No courses found");
          emit(MyCoursesEmpty());
          return;
        }

        final courseResponse = MyCourseResponse.fromJson(response.data);
        _cachedCourses = courseResponse;
        _currentSearchQuery = '';
        _currentTeacher = null;
        print("refreshMyCourses: Emitting MyCoursesLoaded with ${courseResponse.courses.length} courses");
        _applyFilters();
      } else {
        print("refreshMyCourses: Emitting MyCoursesError - Failed to refresh courses: ${response.statusMessage}");
        emit(MyCoursesError('Failed to refresh courses: ${response.statusMessage ?? 'Unknown error'}'));
      }
    } on DioException catch (e) {
      print("refreshMyCourses: DioException - ${e.message}");
      String errorMessage = 'Failed to refresh courses';
      if (e.response != null) {
        errorMessage = e.response!.data['message'] ?? 'Unknown error occurred';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timed out';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Invalid response from server';
      }
      emit(MyCoursesError(errorMessage));
    } catch (e) {
      print("refreshMyCourses: Unexpected error - ${e.toString()}");
      emit(MyCoursesError('Unexpected error: ${e.toString()}'));
    }
  }

  void searchCourses(String query) {
    print("searchCourses: Applying search query: $query");
    _currentSearchQuery = query;
    _applyFilters();
  }

  void filterByTeacher(String? teacher) {
    print("filterByTeacher: Applying teacher filter: $teacher");
    _currentTeacher = teacher;
    _applyFilters();
  }

  void _applyFilters() {
    if (_cachedCourses == null) {
      print("_applyFilters: Emitting MyCoursesEmpty - No cached courses");
      emit(MyCoursesEmpty());
      return;
    }

    List<MyCourse> filtered = _cachedCourses!.courses;

    if (_currentTeacher != null) {
      filtered = _cachedCourses!.getCoursesByTeacher(_currentTeacher!);
      print("_applyFilters: Filtered by teacher $_currentTeacher: ${filtered.length} courses");
    }

    final tempResponse = MyCourseResponse(courses: filtered);
    filtered = tempResponse.searchCourses(_currentSearchQuery);
    print("_applyFilters: Filtered by search query $_currentSearchQuery: ${filtered.length} courses");

    if (filtered.isEmpty) {
      print("_applyFilters: Emitting MyCoursesEmpty");
      emit(MyCoursesEmpty());
    } else {
      print("_applyFilters: Emitting MyCoursesLoaded with ${filtered.length} courses");
      emit(MyCoursesLoaded(MyCourseResponse(courses: filtered)));
    }
  }

  MyCourse? getCourseById(int courseId) {
    final course = _cachedCourses?.getCourseById(courseId);
    print("getCourseById: CourseId $courseId, Found: ${course != null}");
    return course;
  }

  List<String> get allTeachers => _cachedCourses?.allTeachers ?? [];

  void clearCache() {
    print("clearCache: Clearing cached courses");
    _cachedCourses = null;
  }

  void reset() {
    print("reset: Resetting cubit state");
    _currentSearchQuery = '';
    _currentTeacher = null;
    clearCache();
    emit(MyCoursesInitial());
  }
}