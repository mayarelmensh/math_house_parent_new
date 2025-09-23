import 'package:math_house_parent_new/data/models/buy_chapter_model.dart';

abstract class BuyChapterStates {}

class BuyChapterInitialState extends BuyChapterStates {}

class BuyChapterLoadingState extends BuyChapterStates {}

class BuyChapterSuccessState extends BuyChapterStates {
  final BuyChapterModel model;
  final String? paymentLink;

  BuyChapterSuccessState(this.model, {this.paymentLink});
}

class BuyChapterErrorState extends BuyChapterStates {
  final String? message;

  BuyChapterErrorState(this.message);
}