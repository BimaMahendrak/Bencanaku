import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class TimezoneHelper {
  static bool _initialized = false;

  /// Inisialisasi timezone database
  static void initialize() {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Deteksi timezone berdasarkan lokasi GPS
  static String detectTimezone(double latitude, double longitude) {
    // Koordinat Indonesia dan timezone-nya
    if (_isInWIB(latitude, longitude)) {
      return 'Asia/Jakarta'; // WIB (UTC+7)
    } else if (_isInWITA(latitude, longitude)) {
      return 'Asia/Makassar'; // WITA (UTC+8)
    } else if (_isInWIT(latitude, longitude)) {
      return 'Asia/Jayapura'; // WIT (UTC+9)
    } else {
      // Default ke WIB jika di luar Indonesia
      return 'Asia/Jakarta';
    }
  }

  /// Cek apakah koordinat berada di wilayah WIB
  static bool _isInWIB(double lat, double lng) {
    // Wilayah WIB: Sumatera, Jawa, Kalimantan Barat & Tengah
    return (lng >= 95.0 && lng <= 117.0) && 
           (lat >= -11.0 && lat <= 6.0);
  }

  /// Cek apakah koordinat berada di wilayah WITA
  static bool _isInWITA(double lat, double lng) {
    // Wilayah WITA: Bali, NTB, NTT, Kalimantan Timur & Selatan, Sulawesi
    return (lng >= 117.0 && lng <= 130.0) && 
           (lat >= -11.0 && lat <= 3.0);
  }

  /// Cek apakah koordinat berada di wilayah WIT
  static bool _isInWIT(double lat, double lng) {
    // Wilayah WIT: Maluku, Papua
    return (lng >= 130.0 && lng <= 141.0) && 
           (lat >= -11.0 && lat <= 1.0);
  }

  /// Mendapatkan waktu saat ini berdasarkan timezone
  static DateTime getCurrentTime(String timezone) {
    final location = tz.getLocation(timezone);
    return tz.TZDateTime.now(location);
  }

  /// Format waktu dengan nama timezone Indonesia
  static String formatTimeWithTimezone(DateTime dateTime, String timezone) {
    String timezoneName = getIndonesianTimezoneName(timezone); // Ubah dari _getIndonesianTimezoneName
    String formattedTime = DateFormat('HH:mm:ss').format(dateTime);
    return '$formattedTime $timezoneName';
  }

  /// Format tanggal dan waktu lengkap
  static String formatDateTimeWithTimezone(DateTime dateTime, String timezone) {
    String timezoneName = getIndonesianTimezoneName(timezone); // Ubah dari _getIndonesianTimezoneName
    String formattedDateTime = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID').format(dateTime);
    return '$formattedDateTime $timezoneName';
  }

  /// Konversi nama timezone ke nama Indonesia
  static String getIndonesianTimezoneName(String timezone) {
    switch (timezone) {
      case 'Asia/Jakarta':
        return 'WIB';
      case 'Asia/Makassar':
        return 'WITA';
      case 'Asia/Jayapura':
        return 'WIT';
      default:
        return 'WIB';
    }
  }

  /// Mendapatkan greeting berdasarkan waktu
  static String getGreeting(DateTime dateTime) {
    int hour = dateTime.hour;
    
    if (hour >= 5 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  /// Konversi waktu gempa BMKG (WIB) ke timezone lokasi user
  static DateTime convertBMKGTimeToLocal(String bmkgTime, String targetTimezone) {
    try {
      // Parse waktu BMKG (format: "15:29:20 WIB")
      String timeOnly = bmkgTime.replaceAll(' WIB', '').replaceAll(' WITA', '').replaceAll(' WIT', '');
      
      // Buat DateTime hari ini dengan waktu dari BMKG (assume WIB)
      DateTime today = DateTime.now();
      List<String> timeParts = timeOnly.split(':');
      
      DateTime bmkgDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      // Konversi ke timezone yang diinginkan
      final wibLocation = tz.getLocation('Asia/Jakarta');
      final targetLocation = tz.getLocation(targetTimezone);
      
      final wibTime = tz.TZDateTime.from(bmkgDateTime, wibLocation);
      final localTime = tz.TZDateTime.from(wibTime, targetLocation);
      
      return localTime;
    } catch (e) {
      return DateTime.now();
    }
  }
}