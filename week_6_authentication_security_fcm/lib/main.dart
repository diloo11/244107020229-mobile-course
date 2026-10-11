import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

// ============================================================================
// 1. BACKGROUND HANDLER (WAJIB TOP-LEVEL FUNCTION)
// ============================================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya simpan/catat ringan di sini, navigasi ditangani saat banner diklik.
}

// Inisialisasi plugin Local Notifications untuk tampilan Foreground
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Mendaftarkan background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inisialisasi Local Notification Channel untuk Android
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        // Digunakan jika user mengklik banner notifikasi lokal saat foreground
        rootNavigatorKey.currentContext?.go(response.payload!);
      }
    },
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Navigator key global agar bisa berpindah rute tanpa butuh BuildContext di FCM listener
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Provider untuk GoRouter agar dapat memantau authStateProvider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final loggedIn = authState.value ?? false;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  // ============================================================================
  // 2. PENANGANAN 3 APP STATE & TOPIC SUBSCRIBING
  // ============================================================================
  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Minta Izin Notifikasi (Wajib untuk Android 13+)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Subscribe ke Topik untuk Broadcast Pengumuman Kampus
    await messaging.subscribeToTopic('pengumuman-kampus');

    // STATE 1: FOREGROUND (Aplikasi terbuka aktif)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final route = message.data['route'] ?? '/';
      const androidDetails = AndroidNotificationDetails(
        'pengumuman_channel',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );

      // Tampilkan banner notifikasi lokal secara manual
      await flutterLocalNotificationsPlugin.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman Baru',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    // STATE 2: BACKGROUND (Aplikasi di-minimize, banner diklik user)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final route = message.data['route'] ?? '/';
      if (mounted) {
        ref.read(routerProvider).go(route);
      }
    });

    // STATE 3: TERMINATED (Aplikasi mati/ditutup paksa, dibuka lewat banner)
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['route'] ?? '/';
      if (mounted) {
        ref.read(routerProvider).go(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}