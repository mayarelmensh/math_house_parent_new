import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/use_case/buy_package_use_case.dart';
import 'buy_package_states.dart';

@injectable
class BuyPackageCubit extends Cubit<BuyPackageState> {
  final BuyPackageUseCase buyPackageUseCase;

  BuyPackageCubit(this.buyPackageUseCase) : super(BuyPackageInitial());

  Future<void> buyPackage({
    required int userId,
    required int paymentMethodId, // Changed from dynamic to int
    required String? image,
    required int packageId,
  }) async {
    emit(BuyPackageLoadingState());

    try {
      final response = await buyPackageUseCase.execute(
        userId: userId,
        paymentMethodId: paymentMethodId,
        image: image,
        packageId: packageId,
      );

      print('BuyPackage Response: $response');
      print('PaymentLink: ${response.paymentLink} (type: ${response.paymentLink.runtimeType})');

      // Check if paymentLink is a valid string and not empty
      if (response.paymentLink != null && response.paymentLink!.isNotEmpty) {
        emit(BuyPackagePaymentPendingState(response.paymentLink!));
      } else {
        // Emit SuccessState for non-payment-link cases (e.g., wallet payment)
        emit(BuyPackageSuccess(response: response));
      }
    } catch (e) {
      String errorMessage = 'Failed to purchase package';

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

      emit(BuyPackageError(errorMessage));
    }
  }

  // Method to handle payment result from WebView
  void handlePaymentResult(String url) {
    print('Handling Payment Result: $url');

    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      // Emit SuccessState
      emit(BuyPackageSuccess());
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      String errorMessage = 'Payment failed';

      if (url.contains('txn_response_code=DECLINED')) {
        errorMessage = 'Payment was declined by the payment gateway';
      } else if (url.contains('error_occured=true')) {
        errorMessage = 'An error occurred during payment processing';
      }

      emit(BuyPackageError(errorMessage));
    } else {
      // Keep in pending state if no conclusive result
      emit(BuyPackagePaymentPendingState(url));
    }
  }
}