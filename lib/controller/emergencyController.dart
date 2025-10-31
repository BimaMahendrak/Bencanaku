import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

/// Controller untuk menangani fitur emergency alert menggunakan gyroscope
/// Mendeteksi gerakan miring HP untuk memicu alert darurat
class EmergencyController {
  // Stream subscription untuk mendengarkan sensor gyroscope dan accelerometer
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  // Variabel untuk deteksi kemiringan HP
  DateTime? _tiltStartTime; // Waktu mulai miring
  bool _isEmergencyTriggered = false; // Status apakah emergency sudah dipicu
  
  // Nilai batas untuk deteksi emergency
  static const double _tiltThreshold = 70.0; // Batas sudut kemiringan (derajat)
  static const int _holdDurationSeconds = 5; // Durasi tahan kemiringan (detik)
  
  // Callback functions untuk komunikasi dengan UI
  Function(double)? onTiltAngleChanged; // Callback saat sudut berubah
  Function(bool)? onEmergencyTriggered; // Callback saat emergency dipicu
  Function(String)? onDebugMessage; // Callback untuk pesan debug

  /// Mulai monitoring sensor gyroscope dan accelerometer
  Future<void> startMonitoring() async {
    try {
      onDebugMessage?.call('Memulai monitoring accelerometer...');
      // Gunakan accelerometer untuk sudut kemiringan
      _accelerometerSubscription = accelerometerEvents.listen(
        _onAccelerometerEvent,
        onError: (error) {
          onDebugMessage?.call('Error Accelerometer: $error');
        },
      );
      onDebugMessage?.call('Monitoring emergency berhasil dimulai');
    } catch (e) {
      onDebugMessage?.call('Error memulai monitoring: $e');
    }
  }

  /// Hentikan monitoring sensor
  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    onDebugMessage?.call('Monitoring emergency dihentikan');
  }

  /// Menangani data dari sensor gyroscope
  void _onGyroscopeEvent(GyroscopeEvent event) {
    try {
      // Hitung sudut kemiringan dari data gyroscope
      double tiltAngle = _calculateTiltAngle(event.x, event.y, event.z);
      _currentTiltAngle = tiltAngle;
      
      // Beritahu UI tentang perubahan sudut
      onTiltAngleChanged?.call(tiltAngle);
      
      // Periksa apakah sudut melebihi batas threshold
      if (tiltAngle >= _tiltThreshold) {
        _handleTiltDetected();
      } else {
        _resetTiltTimer();
      }
    } catch (e) {
      onDebugMessage?.call('Error memproses data gyroscope: $e');
    }
  }

  // Tambahkan variabel untuk sudut kemiringan dari accelerometer
  double _currentTiltAngle = 0.0;

  // Fungsi untuk menghitung sudut kemiringan dari accelerometer
  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Sudut kemiringan terhadap sumbu X (portrait)
    double angle = atan2(event.y, event.z) * 180 / pi;
    _currentTiltAngle = angle.abs();

    onTiltAngleChanged?.call(_currentTiltAngle);

    // Deteksi kemiringan seperti sebelumnya
    if (_currentTiltAngle >= _tiltThreshold) {
      _handleTiltDetected();
    } else {
      _resetTiltTimer();
    }
  }

  /// Menghitung sudut kemiringan dari data gyroscope
  double _calculateTiltAngle(double x, double y, double z) {
    // Konversi data rotasi gyroscope ke sudut
    double magnitude = sqrt(x * x + y * y + z * z);
    double angle = magnitude * 10; // Kalikan faktor untuk sensitivitas
    return angle.abs();
  }

  /// Menangani saat kemiringan terdeteksi
  void _handleTiltDetected() {
    if (_tiltStartTime == null) {
      // Mulai timer kemiringan
      _tiltStartTime = DateTime.now();
      onDebugMessage?.call('Kemiringan terdeteksi, timer dimulai');
    } else {
      // Periksa apakah sudah ditahan cukup lama
      Duration holdDuration = DateTime.now().difference(_tiltStartTime!);
      
      if (holdDuration.inSeconds >= _holdDurationSeconds && !_isEmergencyTriggered) {
        _triggerEmergency();
      }
    }
  }

  /// Reset timer kemiringan
  void _resetTiltTimer() {
    _tiltStartTime = null;
    _isEmergencyTriggered = false;
  }

  /// Memicu alert emergency
  void _triggerEmergency() {
    _isEmergencyTriggered = true;
    onEmergencyTriggered?.call(true);
    onDebugMessage?.call('🚨 EMERGENCY DIPICU! 🚨');
    
    // Reset setelah trigger untuk memungkinkan trigger berikutnya
    Future.delayed(const Duration(seconds: 2), () {
      _resetTiltTimer();
    });
  }

  /// Mendapatkan lokasi GPS saat ini
  Future<Position?> getCurrentLocation() async {
    try {
      onDebugMessage?.call('Mengambil lokasi GPS...');
      
      // Periksa apakah layanan lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        onDebugMessage?.call('Layanan lokasi tidak aktif');
        await Geolocator.openLocationSettings();
        return null;
      }

      // Periksa dan minta izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          onDebugMessage?.call('Izin lokasi ditolak');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        onDebugMessage?.call('Izin lokasi ditolak secara permanen');
        return null;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      onDebugMessage?.call('Lokasi diperoleh: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      onDebugMessage?.call('Error mendapatkan lokasi: $e');
      return null;
    }
  }

  /// Bagikan lokasi emergency melalui aplikasi lain
  Future<void> shareEmergencyLocation() async {
    try {
      onDebugMessage?.call('Memulai proses berbagi lokasi...');
      
      // Dapatkan lokasi saat ini
      Position? position = await getCurrentLocation();
      
      if (position == null) {
        throw Exception('Tidak dapat memperoleh lokasi saat ini');
      }

      // Format waktu saat ini
      String timestamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
      
      // Buat URL Google Maps
      String googleMapsUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      
      // Buat pesan emergency dalam bahasa Indonesia
      String message = """
🚨 ALERT DARURAT 🚨
Saya membutuhkan bantuan segera!

📍 Lokasi saya saat ini:
Latitude: ${position.latitude.toStringAsFixed(6)}
Longitude: ${position.longitude.toStringAsFixed(6)}

🗺️ Buka di Google Maps:
$googleMapsUrl

🕐 Waktu: $timestamp
📱 Dikirim dari Aplikasi BencanaKu


""";

      // Bagikan melalui sistem sharing bawaan
      await Share.share(
        message,
        subject: '🚨 Alert Darurat - Butuh Bantuan Segera',
      );

      onDebugMessage?.call('Lokasi emergency berhasil dibagikan');
    } catch (e) {
      onDebugMessage?.call('Error berbagi lokasi: $e');
      rethrow;
    }
  }

  /// Panggil nomor emergency
  Future<void> callEmergency({String number = '089670247500'}) async {
    try {
      onDebugMessage?.call('Memulai panggilan emergency ke $number...');
      
      // Buat URI untuk panggilan telepon
      final Uri phoneUri = Uri(scheme: 'tel', path: number);
      
      // Periksa apakah dapat melakukan panggilan
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        onDebugMessage?.call('Panggilan emergency dimulai ke $number');
      } else {
        throw Exception('Tidak dapat melakukan panggilan telepon pada perangkat ini');
      }
    } catch (e) {
      onDebugMessage?.call('Error panggilan emergency: $e');
      rethrow;
    }
  }

  /// Getter untuk mendapatkan sudut kemiringan saat ini
  double get currentTiltAngle => _currentTiltAngle;
  
  /// Getter untuk mendapatkan progress timer kemiringan (0.0 - 1.0)
  double get tiltProgress {
    if (_tiltStartTime == null) return 0.0;
    
    Duration elapsed = DateTime.now().difference(_tiltStartTime!);
    double progress = elapsed.inMilliseconds / (_holdDurationSeconds * 1000);
    return progress.clamp(0.0, 1.0);
  }

  /// Bersihkan resources saat tidak digunakan
  void dispose() {
    stopMonitoring();
  }
}