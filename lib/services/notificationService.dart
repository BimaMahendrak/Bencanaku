import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class NotificationService {
  static bool _isInitialized = false;

  /// Inisialisasi Awesome Notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Inisialisasi Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // Icon default app
      [
        NotificationChannel(
          channelGroupKey: 'emergency_group',
          channelKey: 'emergency_channel',
          channelName: 'Peringatan Darurat',
          channelDescription: 'Notifikasi peringatan gempa dan bencana',
          defaultColor: const Color(0xFFFF5722),
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: false,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'emergency_group',
          channelGroupName: 'Emergency',
        ),
      ],
    );

    _isInitialized = true;
    print('✅ Awesome Notifications berhasil diinisialisasi');
  }

  /// Meminta izin notifikasi
  static Future<bool> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    
    if (!isAllowed) {
      // Minta izin notifikasi
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    
    return isAllowed;
  }

  /// Menampilkan notifikasi langsung
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Cek izin dulu
    final isAllowed = await requestPermission();
    if (!isAllowed) {
      print('❌ Izin notifikasi ditolak');
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'emergency_channel',
        groupKey: 'emergency_group',
        title: title,
        body: body,
        bigPicture: null,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        fullScreenIntent: false,
        criticalAlert: true,
        category: NotificationCategory.Alarm,
        payload: payload != null ? {'data': payload} : null,
      ),
    );

    print('📱 Notifikasi berhasil dikirim: $title');
  }

  /// Menjadwalkan notifikasi
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    final isAllowed = await requestPermission();
    if (!isAllowed) return;

    final scheduledTime = DateTime.now().add(delay);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'emergency_channel',
        title: title,
        body: body,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        payload: payload != null ? {'data': payload} : null,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );

    print('⏰ Notifikasi dijadwalkan untuk: $scheduledTime');
  }

  /// Membatalkan semua notifikasi
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    print('🚫 Semua notifikasi dibatalkan');
  }

  /// Membatalkan notifikasi berdasarkan ID
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    print('🚫 Notifikasi dibatalkan (ID: $id)');
  }

  /// Setup listener untuk handle notifikasi yang diklik
  static void setupListeners() {
    // Listener untuk notifikasi yang diklik
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Handler ketika notifikasi dibuat
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    print('📝 Notifikasi dibuat: ${receivedNotification.title}');
  }

  /// Handler ketika notifikasi ditampilkan
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    print('👁️ Notifikasi ditampilkan: ${receivedNotification.title}');
  }

  /// Handler ketika notifikasi diklik
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    print('👆 Notifikasi diklik: ${receivedAction.title}');
    
    // TODO: Tambahkan navigasi berdasarkan payload
    final payload = receivedAction.payload?['data'];
    if (payload != null) {
      print('📦 Payload: $payload');
      // Navigasi ke halaman tertentu berdasarkan payload
    }
  }

  /// Handler ketika notifikasi di-dismiss
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print('❌ Notifikasi di-dismiss: ${receivedAction.title}');
  }
}

/// Helper untuk notifikasi darurat
class EmergencyNotifications {
  static final List<Map<String, String>> _earthquakeTemplates = [
    {
      'title': '🚨 PERINGATAN GEMPA!',
      'body': 'Gempa M 6.2 terdeteksi 15km dari lokasi Anda. Segera cari tempat yang aman!',
    },
    {
      'title': '⚠️ GEMPA KUAT!',
      'body': 'Gempa M 5.8 di Jakarta. Waspada gempa susulan. Keluar dari bangunan!',
    },
    {
      'title': '🔴 GEMPA BESAR!',
      'body': 'Gempa M 7.1 di Bandung. EVAKUASI SEGERA! Tsunami warning!',
    },
    {
      'title': '⚡ GUNCANGAN TERDETEKSI!',
      'body': 'Sensor mendeteksi guncangan kuat. Periksa keamanan sekitar Anda.',
    },
  ];

  /// Mengirim peringatan gempa acak
  static Future<void> sendRandomEarthquakeAlert() async {
    final random = Random();
    final template = _earthquakeTemplates[random.nextInt(_earthquakeTemplates.length)];
    
    await NotificationService.showNotification(
      title: template['title']!,
      body: template['body']!,
      payload: 'earthquake_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Mengirim peringatan deteksi guncangan
  static Future<void> sendShakeAlert() async {
    await NotificationService.showNotification(
      title: '📳 GUNCANGAN TERDETEKSI!',
      body: 'Perangkat mendeteksi guncangan tidak normal. Waspadai kemungkinan gempa!',
      payload: 'shake_detection',
    );
  }

  /// Mengirim pengingat evakuasi
  static Future<void> sendEvacuationReminder() async {
    await NotificationService.showNotification(
      title: '🏃‍♀️ LATIHAN EVAKUASI',
      body: 'Waktunya latihan evakuasi! Pastikan Anda tahu rute evakuasi terdekat.',
      payload: 'evacuation_reminder',
    );
  }

  /// Menjadwalkan pengingat keselamatan harian
  static Future<void> scheduleDailySafetyReminder() async {
    await NotificationService.scheduleNotification(
      title: '☀️ PENGINGAT KESELAMATAN',
      body: 'Periksa tas darurat Anda. Pastikan semua kebutuhan emergency tersedia.',
      delay: const Duration(days: 1),
      payload: 'daily_safety_reminder',
    );
  }

  /// Mengirim notifikasi test dengan delay
  static Future<void> sendDelayedTestNotification({int delayMinutes = 1}) async {
    await NotificationService.scheduleNotification(
      title: '⏰ TEST TERJADWAL',
      body: 'Ini adalah notifikasi test yang dijadwalkan $delayMinutes menit yang lalu.',
      delay: Duration(minutes: delayMinutes),
      payload: 'delayed_test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}