import 'package:flutter/widgets.dart';
import 'package:flutter_agentic_starter/core/permissions/permission_service.dart';
import 'package:flutter_agentic_starter/core/permissions/permission_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('updates status after request and rechecks it on app resume', () async {
    final service = _PermissionService();
    final viewModel = PermissionViewModel(service);
    addTearDown(viewModel.dispose);

    final status = await viewModel.checkAndRequest(AppPermission.camera);
    expect(status, AppPermissionStatus.granted);
    expect(viewModel.isGranted(AppPermission.camera), isTrue);

    service.checkedStatus = AppPermissionStatus.permanentlyDenied;
    viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    expect(
      viewModel.statuses.value[AppPermission.camera],
      AppPermissionStatus.permanentlyDenied,
    );
  });
}

final class _PermissionService implements PermissionService {
  AppPermissionStatus checkedStatus = AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> check(AppPermission permission) async =>
      checkedStatus;

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async =>
      AppPermissionStatus.granted;
}
