import 'package:math_house_parent_new/domain/entities/login_response_entity.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheParent(ParentLoginEntity parent);
  Future<ParentLoginEntity?> getCachedParent();
  Future<void> clearCachedParent();
}
