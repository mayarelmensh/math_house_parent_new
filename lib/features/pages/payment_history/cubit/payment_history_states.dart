import 'package:equatable/equatable.dart';
import '../../../../data/models/payment_history_response_dm.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final List<PaymentModel> payments;
  final List<PaymentModel>? allPayments;
  final List<String> availablePaymentMethods; // Added field

  const PaymentSuccess({
    required this.payments,
    this.allPayments,
    required this.availablePaymentMethods, // Make it required
  });

  @override
  List<Object?> get props => [payments, allPayments, availablePaymentMethods];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}