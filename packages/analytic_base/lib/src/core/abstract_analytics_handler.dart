import 'package:analytic_base/src/core/analytics_event.dart';
import 'package:analytic_base/src/core/analytics_user.dart';

/// Contract for all analytics operations.
///
/// Concrete adapters implement this interface for each analytics backend
/// (Firebase Analytics, Amplitude, Mixpanel, etc.).
/// Keep widgets and BLoCs independent of any specific analytics SDK.
abstract interface class AbstractAnalyticsHandler {
  /// Tracks a named event with optional parameters.
  Future<void> trackEvent(AnalyticsEvent event);

  /// Logs a screen view with the given [screenName] and optional [parameters].
  Future<void> trackScreen(
    String screenName, {
    Map<String, Object?>? parameters,
  });

  /// Associates subsequent events with the given [user].
  Future<void> identify(AnalyticsUser user);

  /// Clears the current user identity and resets analytics state.
  ///
  /// Call this on logout to prevent cross-session contamination.
  Future<void> reset();
}
