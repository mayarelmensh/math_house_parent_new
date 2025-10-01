import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/core/api/end_points.dart';
import 'package:math_house_parent_new/features/pages/wallet_history/cubit/wallet_history_states.dart';
import '../../../../core/api/api_manager.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/wallet_history.dart';

@injectable
class WalletHistoryCubit extends Cubit<WalletState> {
  final ApiManager apiManager;
  WalletResponse? _currentResponse; // Store the current wallet response

  WalletHistoryCubit(this.apiManager) : super(WalletInitial());

  Future<void> fetchWalletData({required int userId}) async {
    emit(WalletLoading());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.postData(
        endPoint: EndPoints.walletHistory,
        body: {'user_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'User-Id': userId},
        ),
      );
      final walletResponse = WalletResponse.fromJson(response.data);
      _currentResponse = walletResponse; // Cache the response
      emit(WalletLoaded(walletResponse));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  void filterWalletHistory(String filter) {
    if (_currentResponse == null) {
      emit(WalletError('No wallet data available to filter'));
      return;
    }

    if (filter.toLowerCase() == 'all') {
      emit(WalletLoaded(_currentResponse!));
    } else {
      final filteredHistory = _currentResponse!.wallet_history
          ?.where((history) =>
      history.state?.toLowerCase() == filter.toLowerCase())
          .toList();

      final filteredResponse = WalletResponse(
        money: _currentResponse!.money,
        wallet_history: filteredHistory,
        payment_methods: _currentResponse!.payment_methods,
      );

      emit(WalletLoaded(filteredResponse));
    }
  }
}