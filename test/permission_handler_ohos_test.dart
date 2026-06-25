import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_ohos/permission_handler_ohos.dart';
import 'package:permission_handler_ohos/permission_handler_ohos_platform_interface.dart';
import 'package:permission_handler_ohos/permission_handler_ohos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionHandlerOhosPlatform
    with MockPlatformInterfaceMixin
    implements PermissionHandlerOhosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PermissionHandlerOhosPlatform initialPlatform = PermissionHandlerOhosPlatform.instance;

  test('$MethodChannelPermissionHandlerOhos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPermissionHandlerOhos>());
  });

  test('getPlatformVersion', () async {
    PermissionHandlerOhos permissionHandlerOhosPlugin = PermissionHandlerOhos();
    MockPermissionHandlerOhosPlatform fakePlatform = MockPermissionHandlerOhosPlatform();
    PermissionHandlerOhosPlatform.instance = fakePlatform;

    expect(await permissionHandlerOhosPlugin.getPlatformVersion(), '42');
  });
}
