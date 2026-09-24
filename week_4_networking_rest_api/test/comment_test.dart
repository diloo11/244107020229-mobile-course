import 'package:flutter_test/flutter_test.dart';

import 'package:week_4_networking_rest_api/data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('handles missing fields safely', () {
      // Only provide one field.
      //
      // postId, id, name, and body are intentionally missing.
      final json = {
        'email': 'test@example.com',
      };

      final comment = Comment.fromJson(json);

      // Missing integer fields should use 0.
      expect(comment.postId, 0);
      expect(comment.id, 0);

      // Missing String fields should use an empty String.
      expect(comment.name, '');
      expect(comment.body, '');

      // Existing field should still be parsed correctly.
      expect(comment.email, 'test@example.com');
    });
  });
}