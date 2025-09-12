import '../../entities/buy_package_entity.dart';

abstract class BuyPackageRepository {
  Future<BuyPackageEntity> buyPackage({
    required int userId,
    required dynamic paymentMethodId,
    required String image,
    required int packageId,
  });
}
