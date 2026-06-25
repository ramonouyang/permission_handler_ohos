import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'permission_handler_ohos_method_channel.dart';

abstract class PermissionHandlerOhosPlatform extends PlatformInterface {
  /// Constructs a PermissionHandlerOhosPlatform.
  PermissionHandlerOhosPlatform() : super(token: _token);

  static final Object _token = Object();

  static PermissionHandlerOhosPlatform _instance = MethodChannelPermissionHandlerOhos();

  /// The default instance of [PermissionHandlerOhosPlatform] to use.
  ///
  /// Defaults to [MethodChannelPermissionHandlerOhos].
  static PermissionHandlerOhosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PermissionHandlerOhosPlatform] when
  /// they register themselves.
  static set instance(PermissionHandlerOhosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
