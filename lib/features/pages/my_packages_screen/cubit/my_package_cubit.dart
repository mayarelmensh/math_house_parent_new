import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/api_manager.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';

import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/my_package_model.dart';
import 'my_package_states.dart';

@injectable
class MyPackageCubit extends Cubit<MyPackageState> {
  final ApiManager apiManager;

  MyPackageCubit(this.apiManager) : super(MyPackageInitial());

  Future<void> fetchMyPackageData({required int userId}) async {
    emit(MyPackageLoading());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.postData(
        endPoint: EndPoints.myPackages,
        body: {'user_id': userId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final package = MyPackageModel.fromJson(response.data);
      emit(MyPackageLoaded(package));
    } catch (e) {
      emit(MyPackageError(e.toString()));
    }
  }
}
