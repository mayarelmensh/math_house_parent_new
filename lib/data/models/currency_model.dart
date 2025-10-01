// CurrencyModel.dart
class CurrencyModel {
  final List<Currency> currencies;

  CurrencyModel({required this.currencies});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    var currenciesList = json['currencies'] as List;
    List<Currency> currencies = currenciesList
        .map((currencyJson) => Currency.fromJson(currencyJson))
        .toList();

    return CurrencyModel(currencies: currencies);
  }

  Map<String, dynamic> toJson() {
    return {
      'currencies': currencies.map((currency) => currency.toJson()).toList(),
    };
  }
}

class Currency {
  final int id;
  final String currency;
  final double amount;

  Currency({
    required this.id,
    required this.currency,
    required this.amount,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] as int,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'amount': amount,
    };
  }
}