import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import 'package:math_house_parent_new/data/models/buy_package_response_dm.dart';
import '../../../core/api/api_manager.dart';
import '../../../core/cache/shared_preferences_utils.dart';
import '../../../domain/repository/data_sources/remote_data_source/buy_package_data_sourse.dart';

@Injectable(as: BuyPackageRemoteDataSource)
class BuyPackageRemoteDataSourceImpl implements BuyPackageRemoteDataSource {
  final ApiManager apiManager;

  BuyPackageRemoteDataSourceImpl(this.apiManager);

  @override
  Future<BuyPackageResponseDm> buyPackage({
    required int userId,
    required dynamic paymentMethodId,
    required String image,
    required int packageId,
  }) async {
    var token = SharedPreferenceUtils.getData(key: 'token');

    final response = await apiManager.postData(
      endPoint: EndPoints.buyPackage+"$packageId",
      body: {
        'user_id': userId,
        'payment_method_id': paymentMethodId,
        'image': image,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return BuyPackageResponseDm.fromJson(response.data);
  }
}
