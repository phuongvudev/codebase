import 'package:codebase/src/core/error/exceptions.dart';
import 'package:codebase/src/core/error/failures.dart';
import 'package:codebase/src/core/utils/result.dart';
import 'package:flutter/foundation.dart';

/// Executes [call] and wraps the outcome in a [Result].
///
/// This is the standard repository helper — it catches every known
/// [AppException] (thrown by the data layer / [ErrorInterceptor]) and maps
/// it to the matching [Failure], keeping the domain layer exception-free.
///
/// ### Usage
/// ```dart
/// Future<Result<List<Post>>> getPosts() =>
///     executeOrFailure(() => _remoteDataSource.getPosts());
/// ```
Future<Result<T>> executeOrFailure<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } on RequestCancelledException catch (e) {
    return ResultFailure(RequestCancelledFailure(e.message));
  } on NoInternetException catch (e) {
    return ResultFailure(NoInternetFailure(e.message));
  } on UnauthorizedException catch (e) {
    return ResultFailure(UnauthorizedFailure(e.message));
  } on ForbiddenException catch (e) {
    return ResultFailure(ForbiddenFailure(e.message));
  } on NotFoundException catch (e) {
    return ResultFailure(NotFoundFailure(e.message));
  } on ServerException catch (e) {
    return ResultFailure(ServerFailure(e.message, code: e.code));
  } on NetworkException catch (e) {
    return ResultFailure(NetworkFailure(e.message, code: e.code));
  } on ParseException catch (e) {
    return ResultFailure(ParseFailure(e.message));
  } on CacheException catch (e) {
    return ResultFailure(CacheFailure(e.message));
  } on AppException catch (e) {
    return ResultFailure(UnexpectedFailure(e.message));
  } catch (e, stack) {
    debugPrint('Unhandled error: $e\n$stack');
    return ResultFailure(UnexpectedFailure(e.toString()));
  }
}

