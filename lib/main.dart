import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  List<ConnectivityResult> _connectionStatus = [];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      setState(() {
        _connectionStatus = result;
      });
    });
  }

  Future<void> _checkInternet() async {
    List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String connectionType;
    if (_connectionStatus.isEmpty) {
      connectionType = "No Internet";
    } else {
      connectionType = _connectionStatus.map((e) => e.name).join(', ');
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Internet Connection Type")),
        body: Center(
          child: Text(
            "Connection: $connectionType",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
