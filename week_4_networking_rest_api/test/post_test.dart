import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week_4_networking_rest_api/data/models/post.dart';
import 'package:week_4_networking_rest_api/data/providers.dart';
import 'package:week_4_networking_rest_api/data/repositories/post_repository.dart';
import 'package:week_4_networking_rest_api/data/network_errors.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({
    this.items,
    this.throwError = false,
  }) : super(Dio());

  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/posts',
        ),
        type: DioExceptionType.connectionError,
      );
    }

    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    return fetchPosts();
  }
}

void main() {
  // ============================================================
  // TEST 1: SAFE NULL PARSING
  // ============================================================
  test('fromJson aman terhadap field yang hilang', () {
    final post = Post.fromJson({
      'id': 7,
    });

    expect(post.id, 7);
    expect(post.title, '');
    expect(post.userId, 0);
  });

  // ============================================================
  // TEST 2: ERROR MAPPING
  // ============================================================
  test('friendlyErrorMessage untuk connection error', () {
    final error = DioException(
      requestOptions: RequestOptions(
        path: '/posts',
      ),
      type: DioExceptionType.connectionError,
    );

    expect(
      friendlyErrorMessage(error),
      contains('terhubung'),
    );
  });

  // ============================================================
  // TEST 3: PROVIDER SUCCESS
  // ============================================================
  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(
            items: [
              const Post(
                userId: 1,
                id: 1,
                title: 'Tes',
                body: 'Isi',
              ),
            ],
          ),
        ),
      ],
    );

    addTearDown(container.dispose);

    final posts = await readPostsOnce(container);

    expect(posts.length, 1);
    expect(posts.first.title, 'Tes');
  });

  // ============================================================
  // TEST 4: PROVIDER ERROR
  // ============================================================
  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(
            throwError: true,
          ),
        ),
      ],
    );

    addTearDown(container.dispose);

    final error = await readPostsErrorOnce(container);

    expect(error, isA<DioException>());

    expect(
      friendlyErrorMessage(error!),
      contains('terhubung'),
    );
  });
}

