import 'package:math_house_parent_new/domain/entities/buy_package_entity.dart';

abstract class BuyPackageRemoteDataSource {
  Future<BuyPackageEntity> buyPackage({
    required int userId,
    required dynamic paymentMethodId,
    required String image,
    required int packageId,
  });
}
