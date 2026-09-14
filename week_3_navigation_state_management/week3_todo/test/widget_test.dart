import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/pages/stats_page.dart';

// A fake notifier that resolves instantly and deterministically,
// so this widget test doesn't depend on the real 2s delay / 30%
// random failure in StatsNotifier.
class _FakeStatsNotifier extends StatsNotifier {
  @override
  Future<List<StatItem>> fetchStats() async {
    return const [
      StatItem(label: 'A', value: 1),
      StatItem(label: 'B', value: 2),
      StatItem(label: 'C', value: 3),
    ];
  }
}

void main() {
  testWidgets('StatsPage shows loading spinner then data list',
      (WidgetTester tester) async {
    // Any widget that uses ref.watch/ref.read (ConsumerWidget) MUST be
    // wrapped in a ProviderScope, otherwise you get:
    // "Bad state: No ProviderScope found".
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(_FakeStatsNotifier.new),
        ],
        child: const MaterialApp(home: StatsPage()),
      ),
    );

    // Right after the first pump, the notifier's build() hasn't
    // resolved yet, so we expect the loading spinner.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // pumpAndSettle waits for all pending async work (the fake
    // fetchStats future) to complete and the widget tree to rebuild.
    await tester.pumpAndSettle();

    // After resolving, the spinner should be gone and the 3 items
    // from _FakeStatsNotifier should be visible.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });
}