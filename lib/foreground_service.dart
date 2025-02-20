import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> checkConnectivityTask() async {
  List<ConnectivityResult> results = await Connectivity().checkConnectivity();
  bool isConnected = results.contains(ConnectivityResult.mobile) ||
      results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.ethernet);

  print("Background Connectivity Check: ${isConnected ? 'Connected' : 'No Internet'}");
}

class MyForegroundTask extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await checkConnectivityTask();
    });
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // This method is required but can be empty if not needed
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _timer?.cancel();
  }
}
