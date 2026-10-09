import 'package:firebase_messaging/firebase_messaging.dart'; //[cite: 8]
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; //[cite: 8]

final _local = FlutterLocalNotificationsPlugin(); //[cite: 8]

String? pendingDeepLink; //[cite: 8]

Future<bool> requestNotificationPermission() async { //[cite: 8]
  final settings = await FirebaseMessaging.instance.requestPermission( //[cite: 8]
    alert: true, //[cite: 8]
    badge: true, //[cite: 8]
    sound: true, //[cite: 8]
    announcement: false, //[cite: 8]
    carPlay: false, //[cite: 8]
    criticalAlert: false, //[cite: 8]
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized || //[cite: 8]
      settings.authorizationStatus == AuthorizationStatus.provisional; //[cite: 8]
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  
  await _local.initialize(
    // Tambahkan nama parameter 'settings:' di sini
    settings: const InitializationSettings(
      android: android,
      iOS: ios, // Perhatikan penulisan nama parameter iOS (huruf kapital OS)
    ),
    onDidReceiveNotificationResponse: (response) {
      // Klik banner foreground -> teruskan payload ke router.
      pendingDeepLink = response.payload;
    },
  );
}

Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async { //[cite: 9]
  // 1. Ambil token saat ini dan kirim ke backend.[cite: 9]
  final token = await FirebaseMessaging.instance.getToken(); //[cite: 9]
  if (token != null) await onToken(token); //[cite: 9]

  // 2. Token bisa berubah (reinstall, clear data, rotasi keamanan).[cite: 9]
  // Listener ini WAJIB ada, jika tidak backend menyimpan token basi.[cite: 9]
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken); //[cite: 9]

  // 3. Langganan topik kampus (mis. semua mahasiswa angkatan).[cite: 9]
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus'); //[cite: 9]
}