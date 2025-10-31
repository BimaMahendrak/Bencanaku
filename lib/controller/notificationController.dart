import 'package:flutter/material.dart';
import '../services/notificationService.dart';
import 'dart:async';

class NotificationController {
  // Manajemen state
  final ValueNotifier<bool> isAutoActive = ValueNotifier<bool>(false);
  final ValueNotifier<int> totalSent = ValueNotifier<int>(0);
  
  Timer? _timer;

  /// Inisialisasi controller notifikasi
  Future<void> initialize() async {
    await NotificationService.initialize();
  }

  /// Mengirim notifikasi test manual
  Future<void> sendTest() async {
    await EmergencyNotifications.sendRandomEarthquakeAlert();
    totalSent.value++;
  }

  /// Mengirim pengingat evakuasi
  Future<void> sendEvacuation() async {
    await EmergencyNotifications.sendEvacuationReminder();
    totalSent.value++;
  }

  /// Menjadwalkan notifikasi test (1 atau 2 menit)
  Future<void> scheduleTest({required int delayMinutes}) async {
    await EmergencyNotifications.sendDelayedTestNotification(delayMinutes: delayMinutes);
    print('⏰ Test dijadwalkan $delayMinutes menit dari sekarang');
  }

  /// Memulai testing otomatis (setiap 10 detik)
  void startAuto() {
    if (isAutoActive.value) return;
    
    isAutoActive.value = true;
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      sendTest();
    });

    print('🔄 Auto testing dimulai - interval: 10s');
  }

  /// Menghentikan testing otomatis
  void stopAuto() {
    _timer?.cancel();
    isAutoActive.value = false;
    print('⏹️ Auto testing dihentikan');
  }

  /// Membatalkan semua notifikasi
  Future<void> cancelAll() async {
    await NotificationService.cancelAllNotifications();
    stopAuto();
  }

  /// Membersihkan resource
  void dispose() {
    stopAuto();
    isAutoActive.dispose();
    totalSent.dispose();
  }
}