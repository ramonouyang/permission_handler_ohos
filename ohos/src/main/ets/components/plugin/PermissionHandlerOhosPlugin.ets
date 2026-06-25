import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import hilog from '@ohos.hilog';

const TAG = 'PermissionHandlerOhos';
const CHANNEL_NAME = 'plugins.flutter.io/permission_handler';

let moduleContext: Context | null = null;

/**
 * Permission status constants (matching Dart side).
 */
const PERMISSION_DENIED = 0;
const PERMISSION_GRANTED = 1;
const PERMISSION_RESTRICTED = 2;
const PERMISSION_LIMITED = 3;
const PERMISSION_PERMANENTLY_DENIED = 4;

/**
 * HarmonyOS permission name mapping from Flutter permission enum values.
 * Flutter permission_handler uses integer values for permissions.
 */
const PERMISSION_MAP: Map<number, abilityAccessCtrl.Permissions> = new Map([
  [4, 'ohos.permission.CAMERA'],
  [7, 'ohos.permission.READ_MEDIA'],
  [8, 'ohos.permission.WRITE_MEDIA'],
  [14, 'ohos.permission.LOCATION'],
  [15, 'ohos.permission.APPROXIMATELY_LOCATION'],
  [16, 'ohos.permission.LOCATION_IN_BACKGROUND'],
  [23, 'ohos.permission.MICROPHONE'],
  [27, 'ohos.permission.READ_CALENDAR'],
  [28, 'ohos.permission.WRITE_CALENDAR'],
  [31, 'ohos.permission.READ_CONTACTS'],
  [32, 'ohos.permission.WRITE_CONTACTS'],
  [36, 'ohos.permission.SEND_MESSAGES'],
  [37, 'ohos.permission.RECEIVE_SMS'],
  [38, 'ohos.permission.READ_SMS'],
  [40, 'ohos.permission.READ_PHONE_NUMBERS'],
  [41, 'ohos.permission.ANSWER_PHONE_CALLS'],
  [44, 'ohos.permission.BLUETOOTH'],
  [49, 'ohos.permission.READ_IMAGEVIDEO'],
  [50, 'ohos.permission.WRITE_IMAGEVIDEO'],
  [51, 'ohos.permission.READ_AUDIO'],
  [52, 'ohos.permission.WRITE_AUDIO'],
  [53, 'ohos.permission.READ_DOCUMENT'],
  [54, 'ohos.permission.WRITE_DOCUMENT'],
  [55, 'ohos.permission.READ_WHOLE_CALENDAR'],
  [56, 'ohos.permission.WRITE_WHOLE_CALENDAR'],
]);

/**
 * HarmonyOS NEXT implementation of permission_handler.
 */
export default class PermissionHandlerOhosPlugin
  implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'PermissionHandlerOhosPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    hilog.info(0x0001, TAG, 'Attached to engine');
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
    moduleContext = null;
    hilog.info(0x0001, TAG, 'Detached from engine');
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    moduleContext = binding.getAbility().context;
    hilog.info(0x0001, TAG, 'Attached to ability');
  }

  onDetachedFromAbility(): void {
    moduleContext = null;
    hilog.info(0x0001, TAG, 'Detached from ability');
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    hilog.info(0x0001, TAG, `onMethodCall: ${call.method}`);
    switch (call.method) {
      case 'checkPermissionStatus':
        this.handleCheckPermissionStatus(call, result);
        break;
      case 'requestPermission':
        this.handleRequestPermission(call, result);
        break;
      case 'checkServiceStatus':
        this.handleCheckServiceStatus(call, result);
        break;
      case 'openAppSettings':
        this.handleOpenAppSettings(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private async handleCheckPermissionStatus(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      const args: Record<string, Object> = call.args as Record<string, Object>;
      const permissionEnum: number = args.permission as number;
      const permissionName: abilityAccessCtrl.Permissions | undefined = PERMISSION_MAP.get(permissionEnum);

      if (permissionName === undefined) {
        hilog.warn(0x0001, TAG, `Unknown permission enum: ${permissionEnum}`);
        result.success(PERMISSION_DENIED);
        return;
      }

      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const tokenId: number = this.getAccessTokenId();
      const grantStatus: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(tokenId, permissionName);

      result.success(grantStatus ? PERMISSION_GRANTED : PERMISSION_DENIED);
    } catch (e) {
      const err: Error = e as Error;
      hilog.error(0x0001, TAG, `checkPermissionStatus error: ${err.message}`);
      result.success(PERMISSION_DENIED);
    }
  }

  private async handleRequestPermission(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      const args: Record<string, Object> = call.args as Record<string, Object>;
      const permissionEnum: number = args.permission as number;
      const permissionName: abilityAccessCtrl.Permissions | undefined = PERMISSION_MAP.get(permissionEnum);

      if (permissionName === undefined) {
        hilog.warn(0x0001, TAG, `Unknown permission enum: ${permissionEnum}`);
        result.success(PERMISSION_DENIED);
        return;
      }

      if (moduleContext === null) {
        hilog.error(0x0001, TAG, 'Context not available');
        result.success(PERMISSION_DENIED);
        return;
      }

      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const permissions: Array<abilityAccessCtrl.Permissions> = [permissionName];

      const requestResult: abilityAccessCtrl.PermissionRequestResult = await atManager.requestPermissionsFromUser(
        moduleContext,
        permissions
      );

      if (requestResult.authResults.length > 0 && requestResult.authResults[0] === 0) {
        result.success(PERMISSION_GRANTED);
      } else {
        result.success(PERMISSION_DENIED);
      }
    } catch (e) {
      const err: Error = e as Error;
      hilog.error(0x0001, TAG, `requestPermission error: ${err.message}`);
      result.success(PERMISSION_DENIED);
    }
  }

  private async handleCheckServiceStatus(call: MethodCall, result: MethodResult): Promise<void> {
    // HarmonyOS doesn't have a direct equivalent for checking service status
    // For now, we assume services are enabled if permission is granted
    try {
      const args: Record<string, Object> = call.args as Record<string, Object>;
      const permissionEnum: number = args.permission as number;
      const permissionName: abilityAccessCtrl.Permissions | undefined = PERMISSION_MAP.get(permissionEnum);

      if (permissionName === undefined) {
        result.success(false);
        return;
      }

      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const tokenId: number = this.getAccessTokenId();
      const grantStatus: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(tokenId, permissionName);

      result.success(grantStatus);
    } catch (e) {
      result.success(false);
    }
  }

  private handleOpenAppSettings(result: MethodResult): void {
    // Opening app settings is not directly supported in HarmonyOS NEXT
    // The user needs to manually navigate to app settings
    hilog.warn(0x0001, TAG, 'openAppSettings not directly supported on HarmonyOS');
    result.success(false);
  }

  private getAccessTokenId(): number {
    try {
      if (moduleContext === null) {
        return 0;
      }
      const bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      return bundleInfo.appInfo.accessTokenId;
    } catch (e) {
      const err: Error = e as Error;
      hilog.error(0x0001, TAG, `getAccessTokenId error: ${err.message}`);
      return 0;
    }
  }
}
