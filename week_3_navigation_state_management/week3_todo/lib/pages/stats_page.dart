import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model sederhana untuk satu item statistik.
/// Dibuat immutable (final fields) sesuai praktik umum di Riverpod.
class StatItem {
  final String label;
  final int value;

  const StatItem({required this.label, required this.value});
}

/// -----------------------------------------------------------------------
/// NOTIFIER
/// -----------------------------------------------------------------------
/// `AsyncNotifier<T>` adalah kelas dasar Riverpod untuk mengelola state
/// asynchronous (`AsyncValue<T>`: AsyncLoading, AsyncData, AsyncError).
///
/// Kelebihan dibanding StateNotifier biasa:
/// - `build()` otomatis dijalankan saat provider pertama kali di-watch,
///   dan hasilnya otomatis dibungkus AsyncLoading -> AsyncData/AsyncError.
/// - Ada method `state = const AsyncLoading()` dan `AsyncValue.guard()`
///   untuk memudahkan retry / refresh manual.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  /// Fungsi pengambil data bisa di-inject untuk keperluan testing.
  /// Default-nya memakai simulasi delay + random failure.
  /// (Lihat constructor kosong: Riverpod mengharuskan default constructor
  /// tanpa argumen untuk AsyncNotifier, jadi kita pakai field statis /
  /// override method _fetch, bukan constructor parameter.)
  final Random _random = Random();

  /// Method ini dipisah agar mudah di-override/mock saat unit test
  /// (lihat stats_page_test.dart, di mana kita membuat subclass
  /// FakeStatsNotifier yang meng-override method ini).
  Future<List<StatItem>> fetchStats() async {
    // Simulasi latency jaringan/API selama 2 detik.
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi kegagalan acak dengan probabilitas 30%.
    // random.nextDouble() menghasilkan angka [0.0, 1.0).
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik. Coba lagi.');
    }

    // Data dummy jika berhasil.
    return const [
      StatItem(label: 'Total Pengguna', value: 1523),
      StatItem(label: 'Sesi Aktif', value: 342),
      StatItem(label: 'Pendapatan Harian', value: 8750),
    ];
  }

  /// `build()` dipanggil otomatis oleh Riverpod ketika provider pertama
  /// kali dibaca (watch/read). Return value-nya otomatis jadi AsyncData
  /// jika sukses, atau AsyncError jika exception dilempar.
  @override
  Future<List<StatItem>> build() async {
    return fetchStats();
  }

  /// Method untuk tombol "Retry".
  /// - `state = const AsyncLoading()` membuat UI kembali menampilkan
  ///   spinner selagi request baru berjalan.
  /// - `AsyncValue.guard()` otomatis menangkap exception dan mengubahnya
  ///   menjadi AsyncError, sehingga kita tidak perlu try-catch manual.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchStats());
  }
}

/// Provider yang akan di-watch oleh UI.
/// `AsyncNotifierProvider<Notifier, T>` menghubungkan StatsNotifier
/// dengan tipe data yang dikelolanya (`List<StatItem>`).
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);

/// -----------------------------------------------------------------------
/// UI
/// -----------------------------------------------------------------------
/// ConsumerWidget memberi akses ke `WidgetRef ref` pada method build(),
/// sehingga kita bisa melakukan ref.watch(provider) untuk mendengarkan
/// perubahan state dan otomatis rebuild saat state berubah.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch mengembalikan AsyncValue<List<StatItem>>.
    // AsyncValue punya method `.when()` untuk menangani 3 kondisi:
    // loading, error, dan data (success) secara eksplisit dan type-safe.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // 1) LOADING: tampilkan spinner di tengah layar.
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2) ERROR: tampilkan pesan error + tombol retry.
        //    `error` adalah object exception, `stackTrace` bisa dipakai
        //    untuk logging/debugging.
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // Memanggil method retry() pada notifier melalui
                  // ref.read(provider.notifier), bukan ref.watch,
                  // karena di sini kita hanya perlu memanggil method,
                  // bukan mendengarkan perubahan state.
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),

        // 3) SUCCESS: tampilkan ListView berisi 3 item statistik.
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(item.label),
              trailing: Text(
                item.value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}