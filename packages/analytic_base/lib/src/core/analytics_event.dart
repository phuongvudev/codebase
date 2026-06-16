/// A named analytics event with optional typed parameters.
///
/// [name] should follow your analytics taxonomy (e.g. snake_case for Firebase).
/// [parameters] are forwarded as-is to the underlying analytics backend.
final class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    this.parameters = const {},
  });

  final String name;
  final Map<String, Object?> parameters;
}
