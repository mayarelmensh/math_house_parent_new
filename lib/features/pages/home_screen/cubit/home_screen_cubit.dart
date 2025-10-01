import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/api_manager.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import 'package:math_house_parent_new/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/features/pages/home_screen/cubit/home_screen_states.dart';

import '../../../../data/models/home_model.dart';
@injectable
class HomeScreenCubit extends Cubit<HomeStates> {
  final ApiManager apiManager;

  HomeScreenCubit(this.apiManager) : super(HomeInitialState());

  int selectedIndex = 0;
  List<Widget> bodyList = [];
  StudentResponse? _currentResponse; // Cache the current student response

  Future<void> fetchStudentData() async {
    if (SelectedStudent.studentId == 0) {
      emit(HomeErrorState('No student selected'));
      return;
    }

    emit(HomeLoadingState());

    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.getData(
        endPoint: "${EndPoints.studentData}/${SelectedStudent.studentId}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print("استجابة الـ API: ${response.data}");
      final studentResponse = StudentResponse.fromJson(response.data);
      _currentResponse = studentResponse; // Cache the response
      emit(HomeLoadedState(studentResponse));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  void changeSelectedIndex(int index) {
    selectedIndex = index;
    emit(HomeChangeSelectedIndex());
  }
}