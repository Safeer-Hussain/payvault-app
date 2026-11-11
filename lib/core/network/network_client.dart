import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_interceptor.dart';

class NetworkClient {
  late final Dio dio;

  NetworkClient(SharedPreferences prefs) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.payvault.internal',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-PayVault-Enclave-Version': '2026.11',
        },
      ),
    );

    dio.interceptors.add(MockNetworkInterceptor(prefs));
  }
}
