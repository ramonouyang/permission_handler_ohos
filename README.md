# permission_handler_ohos

[![pub package](https://img.shields.io/pub/v/permission_handler_ohos.svg)](https://pub.dev/packages/permission_handler_ohos)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

HarmonyOS NEXT implementation of Flutter's [permission_handler](https://pub.dev/packages/permission_handler) plugin.

## Features

- ✅ Check permission status
- ✅ Request permissions at runtime
- ✅ Check service status
- ⚠️ Open app settings (limited support)
- ✅ Support for common permissions:
  - Camera
  - Storage (Media, Documents)
  - Location
  - Microphone
  - Calendar
  - Contacts
  - SMS
  - Phone
  - Bluetooth

## Requirements

- HarmonyOS NEXT (API 12+)
- Flutter for HarmonyOS (3.24.0+)
- DevEco Studio 5.0+

## Installation

```yaml
dependencies:
  permission_handler_ohos:
    git:
      url: https://github.com/ramonouyang/permission_handler_ohos.git
      ref: main
```

## Usage

The plugin implements `PermissionHandlerPlatform`, so it works transparently with the `permission_handler` API:

```dart
import 'package:permission_handler/permission_handler.dart';

// Check permission status
PermissionStatus status = await Permission.camera.status;

// Request permission
PermissionStatus status = await Permission.camera.request();

// Check if permission is granted
if (await Permission.camera.isGranted) {
  // Permission granted
}

// Request multiple permissions
Map<Permission, PermissionStatus> statuses = await [
  Permission.camera,
  Permission.microphone,
  Permission.storage,
].request();
```

## Platform-Specific Notes

### Permission Mapping

This plugin maps Flutter permission enum values to HarmonyOS permission names. The mapping includes the most commonly used permissions:

| Flutter Permission | HarmonyOS Permission |
|---|---|
| Permission.camera | ohos.permission.CAMERA |
| Permission.microphone | ohos.permission.MICROPHONE |
| Permission.location | ohos.permission.LOCATION |
| Permission.storage | ohos.permission.READ_MEDIA, ohos.permission.WRITE_MEDIA |
| Permission.contacts | ohos.permission.READ_CONTACTS, ohos.permission.WRITE_CONTACTS |
| Permission.calendar | ohos.permission.READ_CALENDAR, ohos.permission.WRITE_CALENDAR |

### App Settings

Opening app settings is not directly supported in HarmonyOS NEXT. The `openAppSettings()` method will return `false` and log a warning.

## Architecture

```
permission_handler_ohos/
├── lib/
│   └── permission_handler_ohos.dart          # Dart implementation
├── ohos/
│   └── src/main/ets/
│       └── components/plugin/
│           └── PermissionHandlerOhosPlugin.ets  # ArkTS native layer
└── example/
    └── lib/main.dart                            # Example app
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
