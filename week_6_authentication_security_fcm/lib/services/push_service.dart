import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// 1. BACKGROUND HANDLER (WAJIB TOP-LEVEL FUNCTION)
// ⚠️ DILARANG MENGAKSES BuildContext ATAU Riverpod DI SINI!
// ============================================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya simpan atau catat data ringan di sini.
}

class PushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Endpoint API backend (Sesuaikan URL backend jika ada)
  final String _backendUrl = 'https://api.example.com/devices';

  /// Inisialisasi seluruh alur Push Notification
  Future<void> initialize(GoRouter router) async {
    // A. Registrasi Background Handler Top-Level
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // B. Minta Izin Notifikasi
    await requestPermission();

    // C. Setup Local Notifications (Khusus tampilan Foreground)
    await _setupLocalNotifications(router);

    // D. Ambil Token FCM & Konfigurasi Refresh Listener
    await _setupFCMToken();

    // E. Subscribing Topic
    await subscribeToTopic('pengumuman-kampus');

    // F. Tangani Event Klik Notifikasi (3 App States)
    _setupNotificationListeners(router);
  }

  // ============================================================================
  // 2. REQUEST PERMISSION
  // ============================================================================
  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User permission status: ${settings.authorizationStatus}');
  }

  // ============================================================================
  // 3. GET TOKEN & ON TOKEN REFRESH
  // ============================================================================
  Future<void> _setupFCMToken() async {
    // Ambil token awal
    String? token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token terdeteksi (Prefix): ${token.substring(0, 10)}...');
      await _sendTokenToBackend(token);
    }

    // Listener otomatis saat token diperbarui/basi
    _messaging.onTokenRefresh.listen((String newToken) async {
      debugPrint('FCM Token diperbarui (Prefix): ${newToken.substring(0, 10)}...');
      await _sendTokenToBackend(newToken);
    });
  }

  /// Mengirim token baru ke Backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Ambil Auth Token dari Flutter Secure Storage
      String? authToken = await _storage.read(key: 'auth_token');

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': 'android',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Berhasil mengirimkan FCM token baru ke backend.');
      } else {
        debugPrint('Gagal mengirim FCM token ke backend. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error kirim token ke backend: $e');
    }
  }

  // ============================================================================
  // 4. LOCAL NOTIFICATION SETUP (FOREGROUND MANUAL)
  // ============================================================================
  Future<void> _setupLocalNotifications(GoRouter router) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          router.go(response.payload!);
        }
      },
    );
  }

  // ============================================================================
  // 5. SUBSCRIBE / UNSUBSCRIBE TOPIC
  // ============================================================================
  Future<void> subscribeToTopic(String topicName) async {
    await _messaging.subscribeToTopic(topicName);
    debugPrint('Berhasil subscribe ke topik: $topicName');
  }

  Future<void> unsubscribeFromTopic(String topicName) async {
    await _messaging.unsubscribeFromTopic(topicName);
    debugPrint('Berhasil unsubscribe dari topik: $topicName');
  }

  // ============================================================================
  // 6. LISTENERS FOR 3 APP STATES
  // ============================================================================
  void _setupNotificationListeners(GoRouter router) async {
    // 1. STATE FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final route = message.data['route'] ?? '/';

      const androidDetails = AndroidNotificationDetails(
        'pengumuman_channel',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();

      await _localNotifications.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman Baru',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: route,
      );
    });

    // 2. STATE BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final route = message.data['route'] ?? '/';
      router.go(route);
    });

    // 3. STATE TERMINATED
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['route'] ?? '/';
      router.go(route);
    }
  }
}