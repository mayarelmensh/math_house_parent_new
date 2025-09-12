import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent_new/domain/use_case/confirm_code_use_case.dart';
import 'package:math_house_parent_new/features/pages/students_screen/cubit/confirm_code_states.dart';

@injectable
class ConfirmCodeCubit extends Cubit<ConfirmCodeStates> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  ConfirmCodeUseCase confirmCodeUseCase;
  ConfirmCodeCubit({required this.confirmCodeUseCase})
    : super(ConfirmCodeInitialState());

  void confirmCode(int code) async {
    emit(ConfirmCodeLoadingState());
    final result = await confirmCodeUseCase.invoke(code);
    result.fold(
      (error) => emit(ConfirmCodeErrorState(errors: error)),
      (response) => emit(ConfirmCodeSuccessState(confirmCodeEntity: response)),
    );
  }

  String getOtpCode() {
    return controllers.map((c) => c.text).join();
  }
}
