class PaymentMethodsResponseEntity {
  final List<PaymentMethodEntity>? paymentMethods;

  PaymentMethodsResponseEntity({this.paymentMethods});
}

class PaymentMethodEntity {
  final dynamic id;
  final String? payment;
  final String? paymentType;
  final String? description;
  final String? logo;
  final String? paymentLink; // Added to handle Paymob link if needed

  PaymentMethodEntity({
    this.id,
    this.payment,
    this.paymentType,
    this.description,
    this.logo,
    this.paymentLink,
  });
}