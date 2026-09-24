import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import '../repositories/comment_repository.dart';

/// Provides the Dio HTTP client.
///
/// The base URL is the JSONPlaceholder API.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
    ),
  );
});

/// Provides the CommentRepository.
///
/// The repository receives the Dio instance from Riverpod.
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return CommentRepository(dio);
});

/// Handles loading comments for one post.
///
/// `AsyncNotifier<List<Comment>>` means the provider can
/// automatically represent:
/// - AsyncLoading
/// - AsyncData
/// - AsyncError
class CommentNotifier extends AsyncNotifier<List<Comment>> {
  late final int postId;

  CommentNotifier(this.postId);

  @override
  Future<List<Comment>> build() async {
    final repository = ref.read(commentRepositoryProvider);

    return repository.fetchComments(postId);
  }

  String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The request took too long. Please try again.';

        case DioExceptionType.connectionError:
          return 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;

          if (statusCode == 404) {
            return 'The comments could not be found.';
          }

          if (statusCode == 500) {
            return 'The server is currently having a problem. Please try again later.';
          }

          return 'Something went wrong while loading the comments.';

        default:
          return 'Something went wrong. Please try again.';
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Family provider.
///
/// The `int` represents the postId.
///
/// Example:
/// ref.watch(commentProvider(1))
/// means:
/// GET /comments?postId=1
final commentProvider =
    AsyncNotifierProvider.family<CommentNotifier, List<Comment>, int>(
  CommentNotifier.new,
);