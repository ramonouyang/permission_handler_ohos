import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:flutter/services.dart';

/// HarmonyOS NEXT implementation of PermissionHandlerPlatform.
class PermissionHandlerOhos extends PermissionHandlerPlatform {
  /// Method channel for communication with native layer.
  static const MethodChannel _channel = MethodChannel('plugins.flutter.io/permission_handler');

  /// Registers this class as the default instance of [PermissionHandlerPlatform].
  static void registerWith() {
    PermissionHandlerPlatform.instance = PermissionHandlerOhos();
  }

  @override
  Future<bool> openAppSettings() async {
    final bool? result = await _channel.invokeMethod<bool>('openAppSettings');
    return result ?? false;
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    final int? status = await _channel.invokeMethod<int>(
      'checkPermissionStatus',
      <String, dynamic>{'permission': permission.value},
    );
    return _parseStatus(status ?? 0);
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    final Map<Permission, PermissionStatus> result = {};
    
    for (final permission in permissions) {
      final int? status = await _channel.invokeMethod<int>(
        'requestPermission',
        <String, dynamic>{'permission': permission.value},
      );
      result[permission] = _parseStatus(status ?? 0);
    }
    
    return result;
  }

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    final bool? isEnabled = await _channel.invokeMethod<bool>(
      'checkServiceStatus',
      <String, dynamic>{'permission': permission.value},
    );
    return isEnabled == true ? ServiceStatus.enabled : ServiceStatus.disabled;
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(Permission permission) async {
    // HarmonyOS doesn't have a direct equivalent for shouldShowRequestPermissionRationale
    // Return false as default
    return false;
  }

  PermissionStatus _parseStatus(int status) {
    switch (status) {
      case 0:
        return PermissionStatus.denied;
      case 1:
        return PermissionStatus.granted;
      case 2:
        return PermissionStatus.restricted;
      case 3:
        return PermissionStatus.limited;
      case 4:
        return PermissionStatus.permanentlyDenied;
      default:
        return PermissionStatus.denied;
    }
  }
}
