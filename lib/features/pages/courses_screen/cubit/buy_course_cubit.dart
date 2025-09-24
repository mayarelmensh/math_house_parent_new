import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/api_manager.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/buy_cource_model.dart';
import 'buy_course_states.dart';

@injectable
class BuyCourseCubit extends Cubit<BuyCourseStates> {
  final ApiManager apiManager;

  BuyCourseCubit(this.apiManager) : super(BuyCourseInitialState());

  Future<void> buyPackage({
    required String userId,
    required String courseId,
    required String paymentMethodId,
    required String amount,
    required String duration,
    required String image,
    String? promoCode,
  }) async {
    emit(BuyCourseLoadingState());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null) {
        emit(BuyCourseErrorState('No token found'));
        return;
      }

      // Prepare the image data based on payment type
      String imageData;
      if (image == 'wallet') {
        imageData = 'wallet';
      } else {
        if (image.startsWith('data:image/')) {
          imageData = image;
        } else {
          imageData = 'data:image/jpeg;base64,$image';
        }
      }

      // Prepare the request body
      final body = {
        'course_id': courseId,
        'payment_method_id': paymentMethodId,
        'amount': amount,
        'user_id': userId,
        'duration': duration,
        'image': imageData,
        if (promoCode != null) 'promo_code': promoCode,
      };

      // Log the request for debugging
      print('BuyCourse Request: $body');
      print('Headers: {Authorization: Bearer $token}');

      final response = await apiManager.postData(
        endPoint: EndPoints.buyCourse,
        body: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('BuyCourse Response: ${response.data}');
      final buyCourseResponse = BuyCourseResponseEntity.fromJson(response.data);
      print('Payment Link: ${buyCourseResponse.paymentLink}');

      if (buyCourseResponse.paymentLink != null && buyCourseResponse.paymentLink!.isNotEmpty) {
        // Emit PaymentPendingState if a payment link is received
        emit(BuyCoursePaymentPendingState(buyCourseResponse.paymentLink!));
      } else {
        // Emit SuccessState for non-payment-link cases (e.g., wallet payment)
        emit(BuyCourseSuccessState(buyCourseResponse));
      }
    } catch (e) {
      String errorMessage = 'Failed to purchase course';
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
      }

      emit(BuyCourseErrorState(errorMessage));
    }
  }

  // Modified method to handle payment result from WebView
  void handlePaymentResult(String url) {
    print('Handling Payment Result: $url');
    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      // Emit SuccessState with an empty BuyCourseResponseEntity
      emit(BuyCourseSuccessState(
        BuyCourseResponseEntity(), // Empty entity or customize based on your needs
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
      emit(BuyCourseErrorState(errorMessage));
    } else {
      // Keep in pending state if no conclusive result
      emit(BuyCoursePaymentPendingState(url));
    }
  }
}