import 'package:permission_base/src/core/permission_access.dart';
import 'package:permission_base/src/core/permission_type.dart';

sealed class PermissionBlocData {
  const PermissionBlocData();
}

final class PermissionStatusResult extends PermissionBlocData {
  const PermissionStatusResult({
    required this.permission,
    required this.access,
    required this.message,
  });

  final PermissionType permission;
  final PermissionAccess access;
  final String message;
}

final class PermissionSettingsResult extends PermissionBlocData {
  const PermissionSettingsResult({
    required this.opened,
    this.permission,
  });

  final bool opened;
  final PermissionType? permission;
}

