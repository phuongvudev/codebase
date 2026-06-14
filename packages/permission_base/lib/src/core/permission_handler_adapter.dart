import 'package:permission_base/src/core/abstract_permission_handler.dart';
import 'package:permission_base/src/core/permission_access.dart';
import 'package:permission_base/src/core/permission_type.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Concrete adapter for the `permission_handler` plugin.
final class PermissionHandlerAdapter implements AbstractPermissionHandler {
  PermissionHandlerAdapter({Map<String, ph.Permission>? permissionMap})
      : _permissionMap = {
          ...defaultPermissionMap,
          ...?permissionMap,
        };

  final Map<String, ph.Permission> _permissionMap;

  static final Map<String, ph.Permission> defaultPermissionMap = {
    PermissionType.camera.key: ph.Permission.camera,
    PermissionType.microphone.key: ph.Permission.microphone,
    PermissionType.photos.key: ph.Permission.photos,
    PermissionType.locationWhenInUse.key: ph.Permission.locationWhenInUse,
    PermissionType.locationAlways.key: ph.Permission.locationAlways,
    PermissionType.notifications.key: ph.Permission.notification,
  };

  @override
  Future<PermissionAccess> check(PermissionType permission) async {
    final status = await _mapPermission(permission).status;
    return _mapStatus(status);
  }

  @override
  Future<PermissionAccess> request(PermissionType permission) async {
    final status = await _mapPermission(permission).request();
    return _mapStatus(status);
  }

  @override
  Future<bool> openSettings() => ph.openAppSettings();

  ph.Permission _mapPermission(PermissionType permission) {
    final mappedPermission = _permissionMap[permission.key];
    if (mappedPermission == null) {
      throw UnsupportedError(
        'Permission key "${permission.key}" is not mapped in PermissionHandlerAdapter.',
      );
    }

    return mappedPermission;
  }

  PermissionAccess _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted) return PermissionAccess.granted;
    if (status.isPermanentlyDenied) return PermissionAccess.permanentlyDenied;
    if (status.isRestricted) return PermissionAccess.restricted;
    if (status.isLimited) return PermissionAccess.limited;
    return PermissionAccess.denied;
  }
}

