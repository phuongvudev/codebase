---
name: flutter-use-permission-handler
description: Use `permission_handler` to request and manage runtime permissions in Flutter with production-safe UX flows and platform-specific configuration.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Sun, 14 Jun 2026 00:00:00 GMT
---
# Runtime Permissions with permission_handler

## Contents
- [When to Use](#when-to-use)
- [Setup](#setup)
- [Architecture Guidance](#architecture-guidance)
- [Permission Flow Best Practices](#permission-flow-best-practices)
- [Workflow](#workflow)
- [Example](#example)

## When to Use

Use this skill when your feature depends on runtime-gated capabilities, such as:
- Camera (`Permission.camera`)
- Microphone (`Permission.microphone`)
- Photos/media (`Permission.photos`, `Permission.videos`)
- Location (`Permission.locationWhenInUse`, `Permission.locationAlways`)
- Notifications (`Permission.notification`)

Treat permissions as part of feature logic, not direct UI concern.

## Setup

1. Add dependency:
```bash
flutter pub add permission_handler
```

2. Configure iOS permission usage descriptions in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice input.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo access to upload images.</string>
```

3. Configure Android permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

4. If targeting modern Android SDKs, align requested permissions with SDK behavior (for example, Android 13+ notification runtime prompt).

## Architecture Guidance

Follow Clean Architecture + Feature-First:

- **Domain**: Define a contract (for example, `PermissionRepository`) and explicit result types.
- **Data**: Implement contract via `permission_handler` plugin API.
- **Presentation/BLoC**: Trigger checks/requests through use cases and emit UI states.

Avoid calling `Permission.*.request()` directly inside widgets.

Example contract:

```dart
abstract interface class PermissionRepository {
  Future<PermissionResult> check(PermissionType permission);
  Future<PermissionResult> request(PermissionType permission);
  Future<void> openSettings();
}
```

## Permission Flow Best Practices

- **Pre-check before request:** Call `status` first; avoid duplicate prompts.
- **Handle denied vs permanentlyDenied:** If permanently denied, route user to app settings.
- **Explain before prompting:** Show a short rationale UI before system dialog.
- **Request at point-of-need:** Ask only when user triggers relevant action.
- **Keep permission mapping centralized:** Convert plugin status to domain result in one place.

Recommended domain mapping:
- `granted`
- `denied`
- `permanentlyDenied`
- `restricted` (iOS)
- `limited` (iOS photo library)

## Workflow

**Task Progress:**
- [ ] 1. Add `permission_handler` dependency.
- [ ] 2. Configure iOS `Info.plist` usage strings for required capabilities.
- [ ] 3. Configure Android `AndroidManifest.xml` permissions.
- [ ] 4. Create domain contract + sealed result model.
- [ ] 5. Implement data repository using plugin and status mapping.
- [ ] 6. Register repository in GetIt.
- [ ] 7. Add BLoC events/states for check/request/open-settings.
- [ ] 8. Update UI flow to show rationale and fallback states.
- [ ] 9. Add widget tests for granted/denied/permanently denied states.

## Example

```dart
import 'package:permission_handler/permission_handler.dart' as ph;

sealed class PermissionResult {
  const PermissionResult();
}

final class PermissionGranted extends PermissionResult {
  const PermissionGranted();
}

final class PermissionDenied extends PermissionResult {
  const PermissionDenied();
}

final class PermissionPermanentlyDenied extends PermissionResult {
  const PermissionPermanentlyDenied();
}

class PermissionRepositoryImpl implements PermissionRepository {
  const PermissionRepositoryImpl();

  @override
  Future<PermissionResult> check(PermissionType permission) async {
    final status = await _map(permission).status;
    return _toDomain(status);
  }

  @override
  Future<PermissionResult> request(PermissionType permission) async {
    final status = await _map(permission).request();
    return _toDomain(status);
  }

  @override
  Future<void> openSettings() async {
    await ph.openAppSettings();
  }

  ph.Permission _map(PermissionType permission) {
    return switch (permission) {
      PermissionType.camera => ph.Permission.camera,
      PermissionType.microphone => ph.Permission.microphone,
      PermissionType.photos => ph.Permission.photos,
      PermissionType.location => ph.Permission.locationWhenInUse,
      PermissionType.notifications => ph.Permission.notification,
    };
  }

  PermissionResult _toDomain(ph.PermissionStatus status) {
    if (status.isGranted) return const PermissionGranted();
    if (status.isPermanentlyDenied) return const PermissionPermanentlyDenied();
    return const PermissionDenied();
  }
}
```

Use BLoC to orchestrate this flow and keep permission state transitions deterministic and testable.

