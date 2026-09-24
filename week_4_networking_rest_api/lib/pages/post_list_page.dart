import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_errors.dart';
import '../data/providers.dart';
import '../data/widgets/post_tile.dart';

class PostListPage extends ConsumerWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(postListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: postsAsync.when(
        // Loading
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        // Error
        error: (err, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    friendlyErrorMessage(err),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(postListProvider.notifier)
                          .refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },

        // Empty / Success
        data: (posts) {
          // Empty
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data dari server.',
              ),
            );
          }

          // Success
          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(postListProvider.notifier)
                  .refresh();
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostTile(
                  post: posts[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
