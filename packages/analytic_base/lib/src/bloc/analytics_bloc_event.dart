import 'package:analytic_base/src/core/analytics_event.dart';
import 'package:analytic_base/src/core/analytics_user.dart';

/// Commands dispatched to [AnalyticsBloc].
sealed class AnalyticsBlocEvent {
  const AnalyticsBlocEvent();
}

/// Request to track a named analytics event.
final class TrackAnalyticsEventRequested extends AnalyticsBlocEvent {
  const TrackAnalyticsEventRequested(this.event);

  final AnalyticsEvent event;
}

/// Request to track a screen view.
final class TrackAnalyticsScreenRequested extends AnalyticsBlocEvent {
  const TrackAnalyticsScreenRequested(
    this.screenName, {
    this.parameters,
  });

  final String screenName;
  final Map<String, Object?>? parameters;
}

/// Request to identify (or re-identify) the current user.
final class IdentifyAnalyticsUserRequested extends AnalyticsBlocEvent {
  const IdentifyAnalyticsUserRequested(this.user);

  final AnalyticsUser user;
}

/// Request to reset analytics state (e.g. on logout).
final class ResetAnalyticsRequested extends AnalyticsBlocEvent {
  const ResetAnalyticsRequested();
}
