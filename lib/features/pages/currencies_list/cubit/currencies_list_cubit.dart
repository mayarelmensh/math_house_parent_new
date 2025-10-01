import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_manager.dart';
import '../../../../core/api/end_points.dart';
import '../../../../data/models/currency_model.dart';
import 'currencies_list_states.dart';

@injectable
class CurrenciesListCubit extends Cubit<CurrenciesStates> {
  final ApiManager _apiManager;

  CurrenciesListCubit(this._apiManager) : super(CurrenciesInitial());

  // جلب قائمة العملات
  Future<void> getCurrenciesList() async {
    try {
      emit(CurrenciesLoading());

      final response = await _apiManager.getData(
        endPoint: EndPoints.currenciesList,
      );

      if (response.statusCode == 200 && response.data != null) {
        final currencyResponse = CurrencyModel.fromJson(response.data);
        emit(CurrenciesSuccess(currencies: currencyResponse.currencies));
      } else {
        emit(CurrenciesError(message: 'Error loading currencies'));
      }
    } on DioException catch (e) {
      String errorMessage = _handleDioError(e);
      emit(CurrenciesError(message: errorMessage));
    } catch (e) {
      emit(CurrenciesError(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  // دالة لتحديد العملة المختارة (اختياري، لاستخدامها في شاشة الدفع)
  void selectCurrency(Currency selectedCurrency) {
    final currentState = state;
    if (currentState is CurrenciesSuccess) {
      emit(CurrenciesSuccess(currencies: currentState.currencies));
      // يمكنك هنا إضافة منطق لحفظ العملة المختارة، مثلاً باستخدام SharedPreferences
      // أو إرسالها إلى شاشة الدفع عبر event أو حالة
    }
  }

  // معالجة أخطاء Dio
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Unauthorized access';
        } else if (error.response?.statusCode == 404) {
          return 'Data not found';
        } else if (error.response?.statusCode == 500) {
          return 'Server error';
        }
        return 'Connection error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Check your internet connection';
      default:
        return 'Network error occurred';
    }
  }
}