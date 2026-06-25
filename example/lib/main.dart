import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'permission_handler_ohos Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      home: const PermissionDemo(),
    );
  }
}

class PermissionDemo extends StatefulWidget {
  const PermissionDemo({super.key});

  @override
  State<PermissionDemo> createState() => _PermissionDemoState();
}

class _PermissionDemoState extends State<PermissionDemo> {
  String _result = 'No action taken';
  final List<String> _permissionResults = [];

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _result = 'Camera permission: \${status.name}';
      _permissionResults.clear();
      _permissionResults.add('Camera: \${status.name}');
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _result = 'Camera permission request: \${status.name}';
      _permissionResults.clear();
      _permissionResults.add('Camera: \${status.name}');
    });
  }

  Future<void> _requestMultiplePermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.storage,
    ].request();

    setState(() {
      _result = 'Multiple permissions requested';
      _permissionResults.clear();
      statuses.forEach((permission, status) {
        _permissionResults.add('\${permission.toString().split('.').last}: \${status.name}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('permission_handler_ohos Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _checkCameraPermission,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Check Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: _requestCameraPermission,
                  icon: const Icon(Icons.camera),
                  label: const Text('Request Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: _requestMultiplePermissions,
                  icon: const Icon(Icons.security),
                  label: const Text('Request Multiple'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_result),
                  ],
                ),
              ),
            ),
            if (_permissionResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Permission Statuses:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _permissionResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.security),
                        title: Text(
                          _permissionResults[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
