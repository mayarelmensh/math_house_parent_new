// currencies_list_states.dart
import '../../../../data/models/currency_model.dart';

abstract class CurrenciesStates {}

class CurrenciesInitial extends CurrenciesStates {}

class CurrenciesLoading extends CurrenciesStates {}

class CurrenciesSuccess extends CurrenciesStates {
  final List<Currency> currencies;

  CurrenciesSuccess({required this.currencies});
}

class CurrenciesError extends CurrenciesStates {
  final String message;

  CurrenciesError({required this.message});
}