import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/pages/stats_page.dart';


class FakeSuccessStatsNotifier extends StatsNotifier {
  @override
  Future<List<StatItem>> fetchStats() async {
    return const [
      StatItem(label: 'A', value: 1),
      StatItem(label: 'B', value: 2),
      StatItem(label: 'C', value: 3),
    ];
  }
}

class FakeFailingStatsNotifier extends StatsNotifier {
  @override
  Future<List<StatItem>> fetchStats() async {
    throw Exception('Simulated failure');
  }
}

class FakeRetryStatsNotifier extends StatsNotifier {
  bool _shouldFail = true;

  @override
  Future<List<StatItem>> fetchStats() async {
    if (_shouldFail) {
      _shouldFail = false;
      throw Exception('First attempt failed');
    }

    return const [
      StatItem(label: 'Recovered', value: 99),
    ];
  }
}

void main() {
  group('StatsNotifier', () {
    test('build() mengembalikan 3 item saat sukses', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(FakeSuccessStatsNotifier.new),
        ],
      );

      addTearDown(container.dispose);

      final result = await container.read(statsProvider.future);

      expect(result.length, 3);
      expect(result[0].label, 'A');
      expect(result[2].value, 3);
    });

    test('build() menghasilkan AsyncError saat fetch gagal', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(FakeFailingStatsNotifier.new),
        ],
      );

      addTearDown(container.dispose);

      final completer = Completer<AsyncValue<List<StatItem>>>();

      final subscription = container.listen(
        statsProvider,
        (previous, next) {
          if (next.hasError && !completer.isCompleted) {
            completer.complete(next);
          }
        },
        fireImmediately: true,
      );

      addTearDown(subscription.close);

      final state = await completer.future;

      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
    });

    test('retry() mengubah state menjadi AsyncData jika berhasil', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(FakeRetryStatsNotifier.new),
        ],
      );

      addTearDown(container.dispose);

      final errorCompleter = Completer<AsyncValue<List<StatItem>>>();

      final subscription = container.listen(
        statsProvider,
        (previous, next) {
          if (next.hasError && !errorCompleter.isCompleted) {
            errorCompleter.complete(next);
          }
        },
        fireImmediately: true,
      );

      addTearDown(subscription.close);

      // Tunggu sampai percobaan pertama benar-benar menghasilkan AsyncError.
      await errorCompleter.future;

      final notifier = container.read(statsProvider.notifier);

      // Retry harus berhasil.
      await notifier.retry();

      final state = container.read(statsProvider);

      expect(state.hasValue, isTrue);
      expect(state.value!.first.label, 'Recovered');
      expect(state.value!.first.value, 99);
    });
  });
}