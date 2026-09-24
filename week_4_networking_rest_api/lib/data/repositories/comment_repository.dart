import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Handles communication with the JSONPlaceholder API.
///
/// Keeping API logic inside a repository makes it easier for
/// the UI and Riverpod providers to use the data without
/// knowing how the HTTP request works.
class CommentRepository {
  final Dio dio;

  CommentRepository(this.dio);

  /// Fetches comments belonging to a specific post.
  ///
  /// Example:
  /// fetchComments(1)
  /// -> GET /comments?postId=1
  ///
  /// The request has a maximum timeout of 10 seconds.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await dio.get(
      '/comments',
      queryParameters: {
        'postId': postId,
      },
      options: Options(
        // If the server takes longer than 10 seconds,
        // Dio throws a timeout exception.
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
      ),
    );

    /// JSONPlaceholder returns a JSON array.
    ///
    /// Convert every JSON object into a Comment model.
    return (response.data as List)
        .map(
          (json) => Comment.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}