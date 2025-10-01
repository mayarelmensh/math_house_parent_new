import '../../../../data/models/home_model.dart';

abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeChangeSelectedIndex extends HomeStates {}

class HomeLoadingState extends HomeStates {}

class HomeLoadedState extends HomeStates {
  final StudentResponse studentResponse;

  HomeLoadedState(this.studentResponse);
}

class HomeErrorState extends HomeStates {
  final String error;

  HomeErrorState(this.error);
}