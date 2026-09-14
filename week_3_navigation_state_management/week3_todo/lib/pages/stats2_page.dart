import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);

    final total = todos.length;
    final completed =
        todos.where((todo) => todo.done).length;
    final unfinished = total - completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Tasks: $total',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Completed: $completed',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Unfinished: $unfinished',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}