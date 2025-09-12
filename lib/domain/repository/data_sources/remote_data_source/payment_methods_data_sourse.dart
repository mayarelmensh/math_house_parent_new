import 'package:math_house_parent_new/data/models/payment_methods_response_dm.dart';
import 'package:math_house_parent_new/domain/entities/payment_methods_response_entity.dart';

abstract class PaymentMethodsRemoteDataSource {
  Future<PaymentMethodsResponseEntity> getPaymentMethods({required int userId});
}
