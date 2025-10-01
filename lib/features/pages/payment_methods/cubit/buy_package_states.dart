abstract class BuyPackageState {}

class BuyPackageInitial extends BuyPackageState {}

class BuyPackageLoadingState extends BuyPackageState {}

class BuyPackageSuccess extends BuyPackageState {
  final dynamic response;

  BuyPackageSuccess({this.response});
}

class BuyPackagePaymentPendingState extends BuyPackageState {
  final String paymentLink;

  BuyPackagePaymentPendingState(this.paymentLink);
}

class BuyPackageError extends BuyPackageState {
  final String message;

  BuyPackageError(this.message);
}