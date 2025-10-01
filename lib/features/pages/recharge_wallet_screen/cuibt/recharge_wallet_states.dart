import 'package:math_house_parent_new/data/models/recharge_wallet.dart';

abstract class WalletRechargeStates {}

class WalletRechargeInitialState extends WalletRechargeStates {}

class WalletRechargeLoadingState extends WalletRechargeStates {}

class WalletRechargeSuccessState extends WalletRechargeStates {
  final WalletRechargeResponseEntity walletRechargeResponse;

  WalletRechargeSuccessState(this.walletRechargeResponse);
}

class WalletRechargePaymentPendingState extends WalletRechargeStates {
  final String paymentLink;

  WalletRechargePaymentPendingState(this.paymentLink);
}

class WalletRechargeErrorState extends WalletRechargeStates {
  final String error;

  WalletRechargeErrorState(this.error);
}