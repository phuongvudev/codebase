import 'package:codebase/src/core/network/dio_client.dart';
import 'package:dio/dio.dart';

/// An internal interceptor that stamps every outgoing [RequestOptions] with
/// the [DioClient]'s active [CancelToken] — unless the caller already
/// provided their own token.
class CancelTokenInterceptor extends Interceptor {
  CancelTokenInterceptor(this._client);

  final DioClient _client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.cancelToken ??= _client.cancelToken;
    handler.next(options);
  }
}
