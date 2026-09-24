import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/post_list_page.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Posts API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const PostListPage();
      },
    ),

    GoRoute(
      path: '/paged',
      builder: (context, state) {
        return const PagedPostPage();
      },
    ),

    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final postId = int.tryParse(
          state.pathParameters['id'] ?? '',
        );

        if (postId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid post ID.'),
            ),
          );
        }

        return PostDetailPage(
          postId: postId,
        );
      },
    ),
  ],
);
