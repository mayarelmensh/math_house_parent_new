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
    try {
      emit(MyCoursesLoading());

      final token = SharedPreferenceUtils.getData(key: 'token');
      if (token == null) {
        emit(const MyCoursesError('Authentication token not found'));
        return;
      }

      final response = await apiManager.postData(
        endPoint: EndPoints.myCourses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        if (response.data == null || response.data['courses'] == null) {
          emit(MyCoursesEmpty());
          return;
        }

        final courseResponse = MyCourseResponse.fromJson(response.data);
        _cachedCourses = courseResponse;
        // Reset filters on fresh fetch
        _currentSearchQuery = '';
        _currentTeacher = null;
        _applyFilters();
      } else {
        emit(MyCoursesError('Failed to load courses: ${response.statusMessage ?? 'Unknown error'}'));
      }
    } on DioException catch (e) {
      // ... (keep existing error handling)
    } catch (e) {
      emit(MyCoursesError('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> refreshMyCourses(int userId) async {
    try {
      emit(MyCoursesRefreshing(_cachedCourses));

      final token = SharedPreferenceUtils.getData(key: 'token');
      if (token == null) {
        emit(const MyCoursesError('Authentication token not found'));
        return;
      }

      final response = await apiManager.postData(
        endPoint: EndPoints.myCourses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        if (response.data == null || response.data['courses'] == null) {
          emit(MyCoursesEmpty());
          return;
        }

        final courseResponse = MyCourseResponse.fromJson(response.data);
        _cachedCourses = courseResponse;
        // Reset filters on refresh
        _currentSearchQuery = '';
        _currentTeacher = null;
        _applyFilters();
      } else {
        emit(MyCoursesError('Failed to refresh courses: ${response.statusMessage ?? 'Unknown error'}'));
      }
    } on DioException catch (e) {
      // ... (keep existing error handling)
    } catch (e) {
      emit(MyCoursesError('Unexpected error: ${e.toString()}'));
    }
  }

  void searchCourses(String query) {
    _currentSearchQuery = query;
    _applyFilters();
  }

  void filterByTeacher(String? teacher) {
    _currentTeacher = teacher;
    _applyFilters();
  }

  void _applyFilters() {
    if (_cachedCourses == null) {
      emit(MyCoursesEmpty());
      return;
    }

    List<MyCourse> filtered = _cachedCourses!.courses;

    if (_currentTeacher != null) {
      filtered = _cachedCourses!.getCoursesByTeacher(_currentTeacher!);
    }

    final tempResponse = MyCourseResponse(courses: filtered);
    filtered = tempResponse.searchCourses(_currentSearchQuery);

    if (filtered.isEmpty) {
      emit(MyCoursesEmpty());
    } else {
      emit(MyCoursesLoaded(MyCourseResponse(courses: filtered)));
    }
  }

  MyCourse? getCourseById(int courseId) {
    return _cachedCourses?.getCourseById(courseId);
  }

  List<String> get allTeachers => _cachedCourses?.allTeachers ?? [];

  void clearCache() {
    _cachedCourses = null;
  }

  void reset() {
    _currentSearchQuery = '';
    _currentTeacher = null;
    clearCache();
    emit(MyCoursesInitial());
  }
}