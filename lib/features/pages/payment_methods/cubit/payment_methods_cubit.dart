import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/payment_methods_response_entity.dart';
import '../../../../domain/use_case/payment_methods_use_case.dart';
import 'payment_methods_states.dart';

@injectable
class PaymentMethodsCubit extends Cubit<PaymentMethodsStates> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;

  PaymentMethodsCubit(this.getPaymentMethodsUseCase)
      : super(PaymentMethodsInitialState());

  Future<void> getPaymentMethods({required int userId}) async {
    emit(PaymentMethodsLoadingState());
    try {
      final result = await getPaymentMethodsUseCase(userId: userId);

      print('PaymentMethods Response: $result');

      // Check if any payment method has a payment link
      String? foundPaymentLink;
      if (result.paymentMethods != null) {
        for (var method in result.paymentMethods!) {
          if (method.paymentLink != null && method.paymentLink!.isNotEmpty) {
            foundPaymentLink = method.paymentLink;
            print('Found Payment Link: $foundPaymentLink');
            break;
          }
        }
      }

      if (foundPaymentLink != null) {
        // Emit PaymentPendingState if a payment link is found
        emit(PaymentMethodsPaymentPendingState(foundPaymentLink));
      } else {
        // Emit SuccessState for normal cases
        emit(PaymentMethodsSuccessState(result));
      }
    } catch (e) {
      String errorMessage = 'Failed to get payment methods';

      if (e is DioException) {
        print('DioException response data: ${e.response?.data}');
        print('DioException message: ${e.message}');

        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message']?.toString() ??
              'Error ${e.response?.statusCode}: ${e.message}';
        } else {
          errorMessage = 'Error ${e.response?.statusCode}: ${e.message}';
        }
      } else {
        print('Error: $e');
        errorMessage = e.toString();
      }

      emit(PaymentMethodsErrorState(errorMessage));
    }
  }

  // Method to handle payment result from WebView
  void handlePaymentResult(String url) {
    print('Handling Payment Result: $url');

    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      // Emit SuccessState with empty entity (payment completed)
      emit(PaymentMethodsSuccessState(
        PaymentMethodsResponseEntity(),
      ));
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      String errorMessage = 'Payment failed';

      if (url.contains('txn_response_code=DECLINED')) {
        errorMessage = 'Payment was declined by the payment gateway';
      } else if (url.contains('error_occured=true')) {
        errorMessage = 'An error occurred during payment processing';
      }

      emit(PaymentMethodsErrorState(errorMessage));
    } else {
      // Keep in pending state if no conclusive result
      emit(PaymentMethodsPaymentPendingState(url));
    }
  }
}