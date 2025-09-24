import 'package:equatable/equatable.dart';
import '../../../../data/models/buy_cource_model.dart';

abstract class BuyCourseStates extends Equatable {
  const BuyCourseStates();

  @override
  List<Object?> get props => [];
}

class BuyCourseInitialState extends BuyCourseStates {}

class BuyCourseLoadingState extends BuyCourseStates {}

class BuyCourseSuccessState extends BuyCourseStates {
  final BuyCourseResponseEntity buyCourseResponse;
  final String? paymentLink;

  const BuyCourseSuccessState(this.buyCourseResponse, {this.paymentLink});

  @override
  List<Object?> get props => [buyCourseResponse, paymentLink];
}

class BuyCoursePaymentPendingState extends BuyCourseStates {
  final String paymentLink;

  const BuyCoursePaymentPendingState(this.paymentLink);

  @override
  List<Object?> get props => [paymentLink];
}

class BuyCourseErrorState extends BuyCourseStates {
  final String? message;

  const BuyCourseErrorState(this.message);

  @override
  List<Object?> get props => [message];
}