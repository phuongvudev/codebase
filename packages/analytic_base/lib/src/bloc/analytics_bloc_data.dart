import 'package:analytic_base/src/core/analytics_event.dart';
import 'package:analytic_base/src/core/analytics_user.dart';

/// Result data emitted by [AnalyticsBloc] on success.
sealed class AnalyticsBlocData {
  const AnalyticsBlocData();
}

/// Emitted when an analytics event was successfully tracked.
final class AnalyticsEventTracked extends AnalyticsBlocData {
  const AnalyticsEventTracked({required this.event});

  final AnalyticsEvent event;
}

/// Emitted when a screen view was successfully tracked.
final class AnalyticsScreenTracked extends AnalyticsBlocData {
  const AnalyticsScreenTracked({required this.screenName});

  final String screenName;
}

/// Emitted when a user was successfully identified.
final class AnalyticsUserIdentified extends AnalyticsBlocData {
  const AnalyticsUserIdentified({required this.user});

  final AnalyticsUser user;
}

/// Emitted when analytics state was successfully reset.
final class AnalyticsResetCompleted extends AnalyticsBlocData {
  const AnalyticsResetCompleted();
}
