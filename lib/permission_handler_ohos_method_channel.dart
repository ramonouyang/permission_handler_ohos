import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'permission_handler_ohos_platform_interface.dart';

/// An implementation of [PermissionHandlerOhosPlatform] that uses method channels.
class MethodChannelPermissionHandlerOhos extends PermissionHandlerOhosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('permission_handler_ohos');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
