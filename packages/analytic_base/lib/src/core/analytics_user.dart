/// Represents an identified analytics user.
///
/// Pass [userId] to associate events with a specific user.
/// [properties] are forwarded to the backend as user-level attributes
/// (e.g. subscription plan, locale).
final class AnalyticsUser {
  const AnalyticsUser({
    required this.userId,
    this.properties = const {},
  });

  final String userId;
  final Map<String, Object?> properties;
}
