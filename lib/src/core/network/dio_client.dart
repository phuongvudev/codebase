import 'package:codebase/src/core/network/interceptors/cancel_token_interceptor.dart';
import 'package:codebase/src/core/network/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A managed Dio client that supports a factory construction pattern and
/// automatic [CancelToken] injection for every outgoing request.
///
/// Usage:
/// ```dart
/// final client = DioClient.create(baseUrl: 'https://api.example.com');
///
/// // Access the configured [Dio] instance (e.g. for Retrofit).
/// final apiClient = ApiClient(client.dio);
///
/// // Cancel all in-flight requests (e.g. on logout or screen dispose).
/// client.cancelAll(reason: 'User logged out');
/// ```
class DioClient {
  DioClient._(this._dio);

  /// Creates a fully configured [DioClient] for the given [baseUrl].
  factory DioClient.create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    final client = DioClient._(dio);

    dio.interceptors.addAll([
      // Automatically injects the current cancel token into every request.
      CancelTokenInterceptor(client),
      // Maps DioExceptions → typed AppExceptions before they reach repositories.
      ErrorInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    ]);

    return client;
  }

  final Dio _dio;

  /// The active cancel token. Replaced with a fresh token after each
  /// [cancelAll] call so subsequent requests are unaffected.
  CancelToken _cancelToken = CancelToken();

  /// The configured [Dio] instance. Pass this directly to Retrofit clients.
  Dio get dio => _dio;

  /// The cancel token that is currently injected into every request.
  CancelToken get cancelToken => _cancelToken;

  /// Cancels all in-flight requests associated with the current token and
  /// immediately issues a new token for future requests.
  ///
  /// [reason] is forwarded to [CancelToken.cancel] and will surface as
  /// [DioException.message] on the caller side.
  void cancelAll({String? reason}) {
    _cancelToken.cancel(reason ?? 'Requests cancelled');
    _cancelToken = CancelToken();
  }
}

