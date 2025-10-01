import 'package:math_house_parent_new/domain/entities/buy_package_entity.dart';

class BuyPackageResponseDm extends BuyPackageEntity {
  BuyPackageResponseDm({
    required super.success,
    super.paymentLink,
  });

  factory BuyPackageResponseDm.fromJson(Map<String, dynamic> json) {
    // تحويل json['success'] لـ bool سواء كان String أو bool
    bool? success;
    if (json['success'] is String) {
      success = json['success'] == 'true';
    } else if (json['success'] is bool) {
      success = json['success'] as bool;
    } else {
      success = false; // القيمة الافتراضية لو null أو نوع غير متوقع
    }

    return BuyPackageResponseDm(
      success: success,
      paymentLink: json['payment_link']?.toString(), // تحويل لـ String للتأكد
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_link': paymentLink,
    };
  }

  @override
  BuyPackageEntity toEntity() {
    return BuyPackageEntity(
      success: success,
      paymentLink: paymentLink,
    );
  }
}