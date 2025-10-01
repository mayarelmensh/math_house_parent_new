// wallet_recharge_response_entity.dart
class WalletRechargeResponseEntity {
  final String? success;
  final String? paymentLink;

  WalletRechargeResponseEntity({this.success, this.paymentLink});

  factory WalletRechargeResponseEntity.fromJson(Map<String, dynamic> json) {
    return WalletRechargeResponseEntity(
      success: json['success'] as String?,
      paymentLink: json['payment_link'] as String?, // <<<< دي كانت ناقصة!
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_link': paymentLink,
    };
  }
}