import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi lambat (Timeout). Silakan coba lagi.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Sesi Anda telah berakhir. Silakan login kembali.';
          } else if (statusCode == 403) {
            return 'Anda tidak memiliki akses ke fitur ini.';
          } else if (statusCode == 404) {
            return 'Data tidak ditemukan.';
          } else if (statusCode == 500) {
            return 'Terjadi kesalahan pada server.';
          }
          return 'Terjadi kesalahan HTTP ($statusCode).';
        case DioExceptionType.connectionError:
          return 'Perangkat Anda offline. Periksa koneksi internet.';
        default:
          return 'Terjadi masalah pada jaringan.';
      }
    }
    return 'Terjadi kesalahan yang tidak terduga.';
  }
}