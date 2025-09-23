
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/api_manager.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import 'package:math_house_parent_new/data/models/buy_chapter_model.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/chapter_data_model.dart';
import 'chapter_data_states.dart';

@injectable
class ChapterDataCubit extends Cubit<BuyChapterStates> {
final ApiManager apiManager;

ChapterDataCubit(this.apiManager) : super(BuyChapterInitialState());

Future<void> getChapterData(int chapterId) async {
try {
emit(BuyChapterLoadingState());
final token = SharedPreferenceUtils.getData(key: 'token') as String?;

final response = await apiManager.postData(
endPoint: EndPoints.chapterData,
options: Options(headers: {'Authorization': 'Bearer $token'}),
body: {'chapter_ids[]': chapterId},
);
final chapterData = BuyChapterModel.fromJson(response.data);
emit(BuyChapterSuccessState(chapterData));
} catch (e) {
emit(BuyChapterErrorState(e.toString()));
}
}

Future<void> buyChapter({
required String courseId,
required String paymentMethodId,
required double amount,
required String userId,
required String chapterId,
required int duration,
required String image,
int? promoCode,
}) async {
try {
emit(BuyChapterLoadingState());
final token = SharedPreferenceUtils.getData(key: 'token') as String?;

final response = await apiManager.postData(
endPoint: EndPoints.buyChapter,
options: Options(headers: {'Authorization': 'Bearer $token'}),
body: {
'courseId': courseId,
'paymentMethodId': paymentMethodId,
'amount': amount,
'userId': userId,
'chapterId': chapterId,
'duration': duration,
'image': image,
if (promoCode != null) 'promoCode': promoCode,
},
);

final buyChapterResponse = BuyChapterModel.fromJson(response.data);
String? paymentLink = response.data['payment_link'] as String?;
emit(BuyChapterSuccessState(buyChapterResponse, paymentLink: paymentLink));
} catch (e) {
emit(BuyChapterErrorState(e.toString()));
}
}
}
