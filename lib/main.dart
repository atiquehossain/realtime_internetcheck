import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'foreground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _startForegroundTask();
  }

  void _startForegroundTask() async {
    await FlutterForegroundTask.startService(
      notificationTitle: "Connectivity Monitor",
      notificationText: "Checking connectivity every 10 seconds",
      callback: () => MyForegroundTask(),  // Updated to match latest API
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Connectivity Check',
      home: Scaffold(
        appBar: AppBar(title: Text('Background Connectivity')),
        body: Center(
          child: Text(
            'Connectivity check is running in the background.\nCheck logs for updates.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
