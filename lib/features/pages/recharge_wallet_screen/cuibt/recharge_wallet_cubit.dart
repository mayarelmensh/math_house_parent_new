import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/api_manager.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import 'package:math_house_parent_new/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_states.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/recharge_wallet.dart';

@injectable
class WalletRechargeCubit extends Cubit<WalletRechargeStates> {
  ApiManager apiManager;

  WalletRechargeCubit(this.apiManager) : super(WalletRechargeInitialState());

  Future<void> rechargeWallet({
    required int userId,
    required double wallet,
    required dynamic paymentMethodId,
    required String image,
  }) async {
    try {
      emit(WalletRechargeLoadingState());

      final token = SharedPreferenceUtils.getData(key: 'token') as String?;

      final response = await apiManager.postData(
        endPoint: EndPoints.rechargeWallet,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        body: {
          'user_id': userId,
          'wallet': wallet,
          'payment_method_id': paymentMethodId,
          'image': image,
        },
      );

      if (response.statusCode == 200) {
        final walletRechargeResponse = WalletRechargeResponseEntity.fromJson(
          response.data,
        );
        if (paymentMethodId.toString() == '10' &&
            walletRechargeResponse.paymentLink != null &&
            walletRechargeResponse.paymentLink!.isNotEmpty) {
          emit(WalletRechargePaymentPendingState(
              walletRechargeResponse.paymentLink!));
        } else {
          emit(WalletRechargeSuccessState(walletRechargeResponse));
        }
      } else {
        emit(WalletRechargeErrorState('Failed to recharge wallet'));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while recharging wallet';

      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      emit(WalletRechargeErrorState(errorMessage));
    } catch (e) {
      emit(WalletRechargeErrorState('Unexpected error: ${e.toString()}'));
    }
  }

  void handlePaymentResult(String url) {
    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      emit(WalletRechargeSuccessState(
          WalletRechargeResponseEntity(success: 'Wallet recharged successfully')));
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      String errorMessage = 'Payment failed';
      if (url.contains('txn_response_code=DECLINED')) {
        errorMessage = 'Payment was declined by the payment gateway';
      } else if (url.contains('error_occured=true')) {
        errorMessage = 'An error occurred during payment processing';
      }
      emit(WalletRechargeErrorState(errorMessage));
    }
  }
}