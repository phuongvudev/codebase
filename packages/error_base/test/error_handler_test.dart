import 'package:error_base/error_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('executeOrFailure', () {
    test('wraps successful values in Success', () async {
      final result = await executeOrFailure(() async => 42);

      expect(result, isA<Success<int>>());
      expect(result.valueOrNull, 42);
    });

    test('maps typed app exceptions to typed failures', () async {
      final result = await executeOrFailure<int>(
        () async => throw const UnauthorizedException('denied'),
      );

      expect(result, isA<ResultFailure<int>>());
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(result.failureOrNull?.message, 'denied');
      expect(result.failureOrNull?.code, 401);
    });
  });
}
