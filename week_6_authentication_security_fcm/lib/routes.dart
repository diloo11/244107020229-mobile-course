class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}

/// Fungsi murni untuk parsing payload FCM ke rute target
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route']?.toString() ?? '/';
  return route.startsWith('/') ? route : '/$route';
}