import '../../../../data/models/buy_chapter_model.dart';

abstract class BuyChapterStates {}

class BuyChapterInitialState extends BuyChapterStates {}

class BuyChapterLoadingState extends BuyChapterStates {}

class BuyChapterSuccessState extends BuyChapterStates {
  final BuyChapterModel model;
  final String? paymentLink; // Add this parameter

  BuyChapterSuccessState(this.model, this.paymentLink);
}

class BuyChapterErrorState extends BuyChapterStates {
  final String error;

  BuyChapterErrorState(this.error);
}
