/// Contract for all crash reporting operations.
///
/// Concrete adapters implement this interface for each backend
/// (Firebase Crashlytics, Sentry, etc.).
abstract interface class CrashReporter {
  /// Initializes the crash reporting service.
  Future<void> initialize();

  /// Records a caught exception or error.
  ///
  /// [error] is the error object captured.
  /// [stack] is the stack trace associated with the error.
  /// [reason] is an optional description of the error context.
  /// [fatal] indicates if the error caused the app to crash or stop.
  Future<void> recordError(
    dynamic error,
    StackTrace stack, {
    dynamic reason,
    bool fatal = false,
  });

  /// Logs a custom message to be included in the next crash report.
  Future<void> log(String message);

  /// Associates subsequent reports with the given [identifier].
  Future<void> setUserIdentifier(String identifier);
}
