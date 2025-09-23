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
    required dynamic paymentMethodId,
    required String image,
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
      emit(BuyPackageSuccess(response: response));
    } catch (e) {
      emit(BuyPackageError(e.toString()));
    }
  }
}
