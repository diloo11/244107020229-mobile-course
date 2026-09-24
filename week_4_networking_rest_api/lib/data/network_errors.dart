import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi terlalu lama. Silakan coba lagi.';

      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 404) {
          return 'Data tidak ditemukan.';
        }

        if (statusCode == 500) {
          return 'Server sedang bermasalah. Silakan coba lagi nanti.';
        }

        return 'Terjadi kesalahan pada server.';

      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }

  return 'Terjadi kesalahan yang tidak diketahui.';
}
