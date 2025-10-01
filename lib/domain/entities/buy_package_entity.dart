class BuyPackageEntity {
  final bool? success;
  final String? paymentLink;

  BuyPackageEntity({this.success, this.paymentLink});

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_link': paymentLink,
    };
  }
}