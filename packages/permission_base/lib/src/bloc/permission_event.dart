import 'package:permission_base/src/core/permission_type.dart';

sealed class PermissionEvent {
  const PermissionEvent();
}

final class CheckPermissionRequested extends PermissionEvent {
  const CheckPermissionRequested(this.permission);

  final PermissionType permission;
}

final class RequestPermissionRequested extends PermissionEvent {
  const RequestPermissionRequested(this.permission);

  final PermissionType permission;
}

final class OpenPermissionSettingsRequested extends PermissionEvent {
  const OpenPermissionSettingsRequested({this.permission});

  final PermissionType? permission;
}

