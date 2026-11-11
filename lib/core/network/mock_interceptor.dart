import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class MockNetworkInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final Random _random = Random();

  MockNetworkInterceptor(this._prefs);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Check if simulated latency is enabled
    final configuredLatency =
        _prefs.getInt(AppConstants.keySimulatedLatency) ?? 450;
    final jitter = _random.nextInt(150);
    final latency = (configuredLatency + jitter).clamp(200, 2000);
    await Future<void>.delayed(Duration(milliseconds: latency));

    // 2. Check if HTTP 503 is forced via Recruiter Debug Drawer
    final force503 = _prefs.getBool(AppConstants.keySimulate503) ?? false;
    if (force503) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'Simulated 503 Service Unavailable (PayVault Core Ledger Maintenance)',
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    // 3. Return simulated mock response for FinTech endpoints
    final path = options.path;
    if (path.contains('/api/v1/fx/rates')) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'status': 'success',
            'base': 'USD',
            'rates': {
              'USD': 1.0,
              'EUR': 0.92,
              'GBP': 0.79,
              'PKR': 278.50,
              'AED': 3.67,
            },
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }

    handler.next(options);
  }
}
