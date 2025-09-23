import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/api_manager.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/buy_chapter_model.dart';
import 'buy_chapter_states.dart';

@injectable
class BuyChapterCubit extends Cubit<BuyChapterStates> {
  final ApiManager apiManager;

  BuyChapterCubit(this.apiManager) : super(BuyChapterInitialState());

  Future<void> buyChapter({
    required String userId,
    required String courseId,
    required String chapterId,
    required String paymentMethodId,
    required String amount,
    required String duration,
    required String image,
    String? promoCode,
  }) async {
    emit(BuyChapterLoadingState());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null) {
        emit(BuyChapterErrorState('No token found'));
        return;
      }

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
        'chapters': [
          {'chapter_id': chapterId, 'duration': duration},
        ],
        'payment_method_id': paymentMethodId,
        'amount': amount,
        'user_id': userId,
        'image': imageData,
        if (promoCode != null) 'promo_code': promoCode,
      };

      print('BuyChapter Request: $body');
      print('Headers: {Authorization: Bearer $token}');

      final response = await apiManager.postData(
        endPoint: EndPoints.buyChapter,
        body: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('BuyChapter Raw Response: $response');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');

      // Extract payment link directly from response data
      String? paymentLink;
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        paymentLink = responseMap['payment_link'] as String?;
        print('Direct payment_link extraction: $paymentLink');
      }

      final buyChapterResponse = BuyChapterModel.fromJson(response.data);
      print('Model Payment Link: ${buyChapterResponse.paymentLink}');

      // Use the directly extracted payment link if model doesn't have it
      final finalPaymentLink = buyChapterResponse.paymentLink ?? paymentLink;
      print('Final Payment Link: $finalPaymentLink');

      emit(BuyChapterSuccessState(buyChapterResponse, finalPaymentLink));
    } catch (e) {
      String errorMessage = 'Failed to purchase chapter';

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

      emit(BuyChapterErrorState(errorMessage));
    }
  }
}