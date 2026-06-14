import 'package:permission_base/src/core/permission_access.dart';
import 'package:permission_base/src/core/permission_type.dart';

/// Contract for runtime permission operations.
///
/// Keep UI and business logic independent from concrete permission plugins.
abstract interface class AbstractPermissionHandler {
  Future<PermissionAccess> check(PermissionType permission);

  Future<PermissionAccess> request(PermissionType permission);

  Future<bool> openSettings();
}

