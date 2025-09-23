import '../../../../data/models/buy_cource_model.dart';

abstract class BuyCourseStates {}

class BuyCourseInitialState extends BuyCourseStates {}

class BuyCourseLoadingState extends BuyCourseStates {}

class BuyCourseSuccessState extends BuyCourseStates {
  final BuyCourseResponseEntity response;
  final String? paymentLink;

  BuyCourseSuccessState(this.response, {this.paymentLink});
}

class BuyCourseErrorState extends BuyCourseStates {
  final String? message;

  BuyCourseErrorState(this.message);
}