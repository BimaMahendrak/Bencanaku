import 'package:flutter/material.dart';
import '../services/currencyService.dart';

class CurrencyController {
  // Controllers untuk input
  final TextEditingController amountController = TextEditingController();
  
  // ValueNotifiers untuk state management
  final ValueNotifier<String> fromCurrency = ValueNotifier<String>('USD');
  final ValueNotifier<String> toCurrency = ValueNotifier<String>('IDR');
  final ValueNotifier<double> result = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String> lastUpdated = ValueNotifier<String>('');

  // Data rates
  Map<String, dynamic>? _exchangeRates;

  // Daftar mata uang yang didukung
  final List<Map<String, String>> supportedCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'flag': '🇲🇾'},
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'flag': '🇮🇩'},
  ];

  /// Mengambil data exchange rates terbaru
  Future<void> fetchExchangeRates() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      _exchangeRates = await CurrencyService.getExchangeRates('USD');
      
      if (_exchangeRates != null) {
        lastUpdated.value = _exchangeRates!['date'] ?? 'Unknown';
        
        // Konversi otomatis jika ada input
        if (amountController.text.isNotEmpty) {
          convertCurrency();
        }
      } else {
        errorMessage.value = 'Gagal mengambil data nilai tukar';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Konversi mata uang
  void convertCurrency() {
    if (_exchangeRates == null) {
      errorMessage.value = 'Data nilai tukar belum tersedia';
      return;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      result.value = 0.0;
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      errorMessage.value = 'Masukkan jumlah yang valid';
      return;
    }

    errorMessage.value = null;

    try {
      final convertedAmount = CurrencyService.convertCurrency(
        amount: amount,
        fromCurrency: fromCurrency.value,
        toCurrency: toCurrency.value,
        rates: _exchangeRates!,
      );

      result.value = convertedAmount;
    } catch (e) {
      errorMessage.value = 'Error konversi: $e';
    }
  }

  /// Tukar posisi mata uang (swap)
  void swapCurrencies() {
    final temp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = temp;
    
    // Konversi ulang
    convertCurrency();
  }

  /// Reset semua input
  void reset() {
    amountController.clear();
    result.value = 0.0;
    errorMessage.value = null;
    fromCurrency.value = 'USD';
    toCurrency.value = 'IDR';
  }

  /// Cleanup resources
  void dispose() {
    amountController.dispose();
    fromCurrency.dispose();
    toCurrency.dispose();
    result.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    lastUpdated.dispose();
  }
}