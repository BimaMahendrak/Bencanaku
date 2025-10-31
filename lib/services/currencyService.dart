import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  
  /// Mengambil nilai tukar terbaru
  static Future<Map<String, dynamic>?> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$baseCurrency'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'base': data['base'],
          'date': data['date'],
          'rates': data['rates'],
        };
      }
      
      return null;
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return null;
    }
  }

  /// Konversi mata uang
  static double convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required Map<String, dynamic> rates,
  }) {
    if (fromCurrency == toCurrency) return amount;

    // Jika base currency sama dengan fromCurrency
    if (rates['base'] == fromCurrency) {
      return amount * (rates['rates'][toCurrency] ?? 1.0);
    }

    // Konversi melalui base currency
    double toBaseRate = 1.0 / (rates['rates'][fromCurrency] ?? 1.0);
    double fromBaseRate = rates['rates'][toCurrency] ?? 1.0;
    
    return amount * toBaseRate * fromBaseRate;
  }

  /// Format mata uang dengan simbol
  static String formatCurrency(double amount, String currency) {
    String symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// Mendapatkan simbol mata uang
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'MYR':
        return 'RM';
      case 'IDR':
        return 'Rp';
      default:
        return '';
    }
  }

  /// Mendapatkan nama mata uang
  static String getCurrencyName(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return 'US Dollar';
      case 'MYR':
        return 'Malaysian Ringgit';
      case 'IDR':
        return 'Indonesian Rupiah';
      default:
        return currency;
    }
  }
}