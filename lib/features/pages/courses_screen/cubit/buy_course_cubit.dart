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
    required String userId, // غيرناه لـ String
    required String courseId, // غيرناه لـ String
    required String paymentMethodId, // غيرناه لـ String
    required String amount, // غيرناه لـ String
    required String duration, // غيرناه لـ String
    required String image,
    String? promoCode, // غيرناه لـ String
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

      emit(BuyCourseSuccessState(
        buyCourseResponse,
        paymentLink: buyCourseResponse.paymentLink,
      ));
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
}