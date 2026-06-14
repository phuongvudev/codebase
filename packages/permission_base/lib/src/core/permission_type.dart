
import 'package:permission_base/src/core/permission_access.dart';

/// User-facing copy for one permission capability.
final class PermissionMessages {
  const PermissionMessages({
    required this.rationale,
    required this.denied,
    required this.permanentlyDenied,
    required this.restricted,
    required this.limited,
  });

  final String rationale;
  final String denied;
  final String permanentlyDenied;
  final String restricted;
  final String limited;

  String forAccess(PermissionAccess access) {
    return switch (access) {
      PermissionAccess.granted => '',
      PermissionAccess.denied => denied,
      PermissionAccess.permanentlyDenied => permanentlyDenied,
      PermissionAccess.restricted => restricted,
      PermissionAccess.limited => limited,
    };
  }
}

/// Runtime permission descriptor.
///
/// This stays extensible via [PermissionType.custom] while keeping predefined
/// constants for common app permissions.
final class PermissionType {
  const PermissionType._({required this.key, required this.messages});

  final String key;
  final PermissionMessages messages;

  static const camera = PermissionType._(
    key: 'camera',
    messages: PermissionMessages(
      rationale: 'Camera access is required to capture photos and scan codes.',
      denied: 'Camera access was denied. Please allow camera permission to continue.',
      permanentlyDenied:
          'Camera access is permanently denied. Please enable it in Settings.',
      restricted: 'Camera access is restricted on this device.',
      limited: 'Camera access is limited on this device.',
    ),
  );

  static const microphone = PermissionType._(
    key: 'microphone',
    messages: PermissionMessages(
      rationale: 'Microphone access is required for voice recording.',
      denied: 'Microphone access was denied. Please allow it to continue.',
      permanentlyDenied:
          'Microphone access is permanently denied. Please enable it in Settings.',
      restricted: 'Microphone access is restricted on this device.',
      limited: 'Microphone access is limited on this device.',
    ),
  );

  static const photos = PermissionType._(
    key: 'photos',
    messages: PermissionMessages(
      rationale: 'Photo access is required to pick images from your library.',
      denied: 'Photo access was denied. Please allow it to continue.',
      permanentlyDenied:
          'Photo access is permanently denied. Please enable it in Settings.',
      restricted: 'Photo access is restricted on this device.',
      limited: 'Only limited photo access is granted.',
    ),
  );

  static const locationWhenInUse = PermissionType._(
    key: 'locationWhenInUse',
    messages: PermissionMessages(
      rationale: 'Location access is required while using this feature.',
      denied: 'Location access was denied. Please allow it to continue.',
      permanentlyDenied:
          'Location access is permanently denied. Please enable it in Settings.',
      restricted: 'Location access is restricted on this device.',
      limited: 'Location access is limited on this device.',
    ),
  );

  static const locationAlways = PermissionType._(
    key: 'locationAlways',
    messages: PermissionMessages(
      rationale: 'Always-on location access is required for background updates.',
      denied:
          'Always-on location access was denied. Please allow it to continue.',
      permanentlyDenied:
          'Always-on location access is permanently denied. Enable it in Settings.',
      restricted: 'Always-on location access is restricted on this device.',
      limited: 'Always-on location access is limited on this device.',
    ),
  );

  static const notifications = PermissionType._(
    key: 'notifications',
    messages: PermissionMessages(
      rationale: 'Notification access is required to receive important updates.',
      denied: 'Notification access was denied. Please allow it to continue.',
      permanentlyDenied:
          'Notification access is permanently denied. Please enable it in Settings.',
      restricted: 'Notification access is restricted on this device.',
      limited: 'Notification access is limited on this device.',
    ),
  );

  factory PermissionType.custom({
    required String key,
    required PermissionMessages messages,
  }) {
    return PermissionType._(key: key, messages: messages);
  }
}

