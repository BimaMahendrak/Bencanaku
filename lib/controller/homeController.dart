import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomeController {
  final ValueNotifier<List<Map<String, dynamic>>> gempaData = ValueNotifier([]);
  final ValueNotifier<Position?> userLocation = ValueNotifier(null);
  final ValueNotifier<String> userCity = ValueNotifier('');
  final ValueNotifier<int> gempaWeeklyCount = ValueNotifier(0);
  final ValueNotifier<List<Map<String, dynamic>>> gempaWeeklyData = ValueNotifier([]);

  Future<void> fetchGempaData() async {
    try {
      final response = await http.get(
        Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final gempaList = data['Infogempa']['gempa'] as List<dynamic>;

        if (gempaList.isNotEmpty) {
          // Ambil data terbaru untuk card gempa
          final gempa = gempaList.first;
          final coordinates = gempa['Coordinates'].split(',');

          gempaData.value = [
            {
              'tanggal': gempa['Tanggal'],
              'jam': gempa['Jam'],
              'magnitude': gempa['Magnitude'],
              'kedalaman': gempa['Kedalaman'],
              'wilayah': gempa['Wilayah'],
              'potensi': gempa['Potensi'],
              'latitude': double.parse(coordinates[0]),
              'longitude': double.parse(coordinates[1]),
            }
          ];

          // Hitung gempa dalam 1 minggu terakhir
          _calculateWeeklyEarthquakes(gempaList);
        }
      } else {
        throw Exception('Gagal mengambil data gempa');
      }
    } catch (e) {
      debugPrint('Error fetching gempa data: $e');
    }
  }

  void _calculateWeeklyEarthquakes(List<dynamic> gempaList) {
    try {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      
      List<Map<String, dynamic>> weeklyEarthquakes = [];
      
      for (var gempa in gempaList) {
        try {
          // Parse tanggal dari format Indonesia
          String tanggalStr = gempa['Tanggal'];
          DateTime? gempaDate = _parseIndonesianDate(tanggalStr);
          
          if (gempaDate != null && gempaDate.isAfter(oneWeekAgo)) {
            final coordinates = gempa['Coordinates'].split(',');
            weeklyEarthquakes.add({
              'tanggal': gempa['Tanggal'],
              'jam': gempa['Jam'],
              'magnitude': gempa['Magnitude'],
              'kedalaman': gempa['Kedalaman'],
              'wilayah': gempa['Wilayah'],
              'potensi': gempa['Potensi'],
              'latitude': double.parse(coordinates[0]),
              'longitude': double.parse(coordinates[1]),
            });
          }
        } catch (e) {
          debugPrint('Error parsing earthquake date: $e');
        }
      }
      
      gempaWeeklyCount.value = weeklyEarthquakes.length;
      gempaWeeklyData.value = weeklyEarthquakes;
      
    } catch (e) {
      debugPrint('Error calculating weekly earthquakes: $e');
      gempaWeeklyCount.value = 0;
    }
  }

  DateTime? _parseIndonesianDate(String dateStr) {
    try {
      // Map bulan Indonesia ke nomor
      Map<String, int> monthMap = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6,
        'Jul': 7, 'Agu': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12
      };
      
      // Format: "30 Okt 2025"
      List<String> parts = dateStr.split(' ');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int? month = monthMap[parts[1]];
        int year = int.parse(parts[2]);
        
        if (month != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      debugPrint('Error parsing date: $dateStr, error: $e');
    }
    return null;
  }

  Future<void> fetchUserLocation() async {
    try {
      // Meminta izin lokasi
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak');
      }

      // Mendapatkan lokasi pengguna
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Mengupdate ValueNotifier untuk posisi
      userLocation.value = position;

      // Ambil nama kota dari koordinat menggunakan API
      await _getCityFromCoordinatesAPI(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error fetching user location: $e');
      userCity.value = 'Lokasi tidak diketahui';
    }
  }

  Future<void> _getCityFromCoordinatesAPI(double latitude, double longitude) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=10&addressdetails=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'BencanaKu App', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract city name from response
        String cityName = 'Lokasi tidak diketahui';
        
        if (data['address'] != null) {
          final address = data['address'];
          
          // Priority: city -> town -> village -> county -> state
          cityName = address['city'] ?? 
                    address['town'] ?? 
                    address['village'] ?? 
                    address['county'] ?? 
                    address['state'] ?? 
                    'Lokasi tidak diketahui';
        }
        
        userCity.value = cityName;
      } else {
        userCity.value = 'Lokasi tidak diketahui';
      }
    } catch (e) {
      debugPrint('Error getting city name from API: $e');
      userCity.value = 'Lokasi tidak diketahui';
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void dispose() {
    gempaData.dispose();
    userLocation.dispose();
    userCity.dispose();
    gempaWeeklyCount.dispose();
    gempaWeeklyData.dispose();
  }
}