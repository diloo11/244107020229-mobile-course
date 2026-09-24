import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/post.dart';
import '../data/providers.dart';

class PostDetailPage extends ConsumerWidget {
  final int postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: postsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Failed to load post.',
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (posts) {
          Post? post;

          for (final item in posts) {
            if (item.id == postId) {
              post = item;
              break;
            }
          }

          if (post == null) {
            return const Center(
              child: Text('Post not found.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 24),

                Text(
                  post.body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}