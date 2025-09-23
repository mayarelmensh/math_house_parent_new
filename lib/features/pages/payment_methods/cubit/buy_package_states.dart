abstract class BuyPackageState {}

class BuyPackageInitial extends BuyPackageState {}

class BuyPackageLoadingState extends BuyPackageState {}

class BuyPackageSuccess extends BuyPackageState {
  final String? paymentLink; // Added to handle Paymob response
  final dynamic response; // Adjust based on your actual response model

  BuyPackageSuccess({this.paymentLink, this.response});
}

class BuyPackageError extends BuyPackageState {
  final String? message;

  BuyPackageError(this.message);
}