GoRouter(
  redirect: (context, state) {
    final loggedIn =
        container.read(authStateProvider).value ?? false;
    final goingLogin = state.matchedLocation == '/login';
    if (!loggedIn && !goingLogin) return '/login';
    if (loggedIn && goingLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(
      path: '/pengumuman/:id',
      builder: (_, s) =>
          AnnouncementPage(id: s.pathParameters['id'] ?? ''),
    ),
  ],
);