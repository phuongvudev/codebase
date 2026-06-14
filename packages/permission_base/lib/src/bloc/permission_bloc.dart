import 'package:codebase/codebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_base/src/bloc/permission_bloc_data.dart';
import 'package:permission_base/src/bloc/permission_event.dart';

import '../core/abstract_permission_handler.dart';

final class PermissionBloc
    extends BaseAppBloc<PermissionEvent, PermissionBlocData> {
  PermissionBloc({required this._permissionHandler}) {
    on<CheckPermissionRequested>(_onCheckPermissionRequested);
    on<RequestPermissionRequested>(_onRequestPermissionRequested);
    on<OpenPermissionSettingsRequested>(_onOpenPermissionSettingsRequested);
  }

  final AbstractPermissionHandler _permissionHandler;

  Future<void> _onCheckPermissionRequested(
    CheckPermissionRequested event,
    Emitter<BaseState<PermissionBlocData>> emit,
  ) async {
    emit(const LoadingState());

    try {
      final access = await _permissionHandler.check(event.permission);
      emit(
        SuccessState(
          data: PermissionStatusResult(
            permission: event.permission,
            access: access,
            message: event.permission.messages.forAccess(access),
          ),
        ),
      );
    } catch (error) {
      emit(FailureState('Failed to check permission: $error'));
    }
  }

  Future<void> _onRequestPermissionRequested(
    RequestPermissionRequested event,
    Emitter<BaseState<PermissionBlocData>> emit,
  ) async {
    emit(const LoadingState());

    try {
      final access = await _permissionHandler.request(event.permission);
      emit(
        SuccessState(
          data: PermissionStatusResult(
            permission: event.permission,
            access: access,
            message: event.permission.messages.forAccess(access),
          ),
        ),
      );
    } catch (error) {
      emit(FailureState('Failed to request permission: $error'));
    }
  }

  Future<void> _onOpenPermissionSettingsRequested(
    OpenPermissionSettingsRequested event,
    Emitter<BaseState<PermissionBlocData>> emit,
  ) async {
    emit(const ProcessingState('Opening application settings...'));

    try {
      final opened = await _permissionHandler.openSettings();
      if (!opened) {
        emit(const FailureState('Could not open app settings. Please open manually.'));
        return;
      }

      emit(
        SuccessState(
          data: PermissionSettingsResult(
            opened: opened,
            permission: event.permission,
          ),
        ),
      );
    } catch (error) {
      emit(FailureState('Failed to open app settings: $error'));
    }
  }
}

