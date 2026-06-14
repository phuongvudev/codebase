import 'package:codebase/codebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_base/src/bloc/permission_bloc.dart';
import 'package:permission_base/src/bloc/permission_bloc_data.dart';
import 'package:permission_base/src/bloc/permission_event.dart';
import 'package:permission_base/src/core/abstract_permission_handler.dart';
import 'package:permission_base/src/core/permission_access.dart';
import 'package:permission_base/src/core/permission_type.dart';

void main() {
  group('PermissionBloc', () {
    test('emits loading and granted result when check succeeds', () async {
      final handler = _FakePermissionHandler(
        checkResult: PermissionAccess.granted,
      );
      final bloc = PermissionBloc(permissionHandler: handler);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LoadingState<PermissionBlocData>>(),
          predicate<BaseState<PermissionBlocData>>((state) {
            if (state is! SuccessState<PermissionBlocData>) {
              return false;
            }

            final data = state.data;
            return data is PermissionStatusResult &&
                data.permission == PermissionType.notifications &&
                data.access == PermissionAccess.granted &&
                data.message.isEmpty;
          }),
        ]),
      );

      bloc.add(const CheckPermissionRequested(PermissionType.notifications));
      await expectation;
      await bloc.close();
    });

    test('emits loading and denied result with permission-specific message', () async {
      final handler = _FakePermissionHandler(
        requestResult: PermissionAccess.denied,
      );
      final bloc = PermissionBloc(permissionHandler: handler);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LoadingState<PermissionBlocData>>(),
          predicate<BaseState<PermissionBlocData>>((state) {
            if (state is! SuccessState<PermissionBlocData>) {
              return false;
            }

            final data = state.data;
            return data is PermissionStatusResult &&
                data.permission == PermissionType.camera &&
                data.access == PermissionAccess.denied &&
                data.message == PermissionType.camera.messages.denied;
          }),
        ]),
      );

      bloc.add(const RequestPermissionRequested(PermissionType.camera));
      await expectation;
      await bloc.close();
    });

    test('emits processing then failure when opening settings fails', () async {
      final handler = _FakePermissionHandler(openSettingsResult: false);
      final bloc = PermissionBloc(permissionHandler: handler);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProcessingState<PermissionBlocData>>(),
          predicate<BaseState<PermissionBlocData>>((state) {
            return state is FailureState<PermissionBlocData> &&
                state.message ==
                    'Could not open app settings. Please open manually.';
          }),
        ]),
      );

      bloc.add(
        const OpenPermissionSettingsRequested(permission: PermissionType.camera),
      );
      await expectation;
      await bloc.close();
    });
  });
}

final class _FakePermissionHandler implements AbstractPermissionHandler {
  _FakePermissionHandler({
    this.checkResult = PermissionAccess.granted,
    this.requestResult = PermissionAccess.granted,
    this.openSettingsResult = true,
  });

  final PermissionAccess checkResult;
  final PermissionAccess requestResult;
  final bool openSettingsResult;

  @override
  Future<PermissionAccess> check(PermissionType permission) async => checkResult;

  @override
  Future<bool> openSettings() async => openSettingsResult;

  @override
  Future<PermissionAccess> request(PermissionType permission) async =>
      requestResult;
}


