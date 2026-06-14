# permission_base

A Flutter package for decoupled and predictable runtime permission management.

## Overview

`permission_base` provides an architectural layer that separates your application's business logic from concrete permission plugins (like `permission_handler`). It uses the **Adapter Pattern** to define a stable contract and **BLoC** for state management, ensuring that permission flows are deterministic and easy to test.

## Features

- **Decoupled Architecture**: Interface-driven design using `AbstractPermissionHandler`.
- **Predefined Permissions**: Out-of-the-box support for common permissions (Camera, Microphone, Photos, Location, Notifications).
- **Extensible**: Easily add custom permission types using `PermissionType.custom`.
- **Standardized Statuses**: Unified `PermissionAccess` enum across all platforms and plugins.
- **BLoC Integration**: Predictable state management for permission checks and requests.
- **User-Centric**: Predefined rationale and error messages for common permissions.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  permission_base:
    path: packages/permission_base
```

## Usage

### 1. Register the Adapter

Initialize the `PermissionHandlerAdapter` (which wraps the `permission_handler` plugin) and register it in your service locator (e.g., `GetIt`).

```dart
import 'package:get_it/get_it.dart';
import 'package:permission_base/permission_base.dart';

final getIt = GetIt.instance;

void setupPermissions() {
  getIt.registerLazySingleton<AbstractPermissionHandler>(
    () => PermissionHandlerAdapter(),
  );
}
```

### 2. Custom Permission Mapping

If you use `PermissionType.custom`, you must provide a mapping between your custom key and the corresponding `permission_handler` constant.

```dart
import 'package:permission_handler/permission_handler.dart' as ph;

void setupPermissions() {
  final customMap = {
    'my_custom_key': ph.Permission.bluetooth,
  };

  getIt.registerLazySingleton<AbstractPermissionHandler>(
    () => PermissionHandlerAdapter(permissionMap: customMap),
  );
}
```

### 3. Use PermissionType

`PermissionType` defines both the permission key and its associated user-facing messages.

```dart
// Predefined
final cameraPermission = PermissionType.camera;

// Custom
final bluetoothPermission = PermissionType.custom(
  key: 'my_custom_key', // Must match the key in PermissionHandlerAdapter mapping
  messages: PermissionMessages(
    rationale: 'Bluetooth is needed to connect to devices.',
    denied: 'Bluetooth access denied.',
    permanentlyDenied: 'Please enable Bluetooth in Settings.',
    restricted: 'Bluetooth access is restricted.',
    limited: 'Bluetooth access is limited.',
  ),
);
```

### 4. PermissionBloc

Use the `PermissionBloc` to handle permission logic in your UI.

#### Requesting Permission

```dart
// Requesting a predefined permission
context.read<PermissionBloc>().add(
  RequestPermissionRequested(PermissionType.camera),
);

// Requesting a custom permission
context.read<PermissionBloc>().add(
  RequestPermissionRequested(bluetoothPermission),
);
```

#### Handling State

```dart
BlocBuilder<PermissionBloc, BaseState<PermissionBlocData>>(
  builder: (context, state) {
    if (state is SuccessState<PermissionStatusResult>) {
      final result = state.data;
      if (result.access == PermissionAccess.granted) {
        // Proceed with feature
      } else {
        // Show result.message to the user
      }
    }
    return const SizedBox.shrink();
  },
);
```

## Architecture

The package follows the project's standard architecture:

- **Core**: Defines the `AbstractPermissionHandler` contract and domain models (`PermissionType`, `PermissionAccess`).
- **Adapter**: `PermissionHandlerAdapter` implements the contract using the `permission_handler` plugin.
- **Presentation**: `PermissionBloc` manages the UI state for permission operations.

## Additional information

This package is part of the core architectural foundation. For platform-specific setup (like `AndroidManifest.xml` or `Info.plist` entries), refer to the [permission_handler](https://pub.dev/packages/permission_handler) documentation.
