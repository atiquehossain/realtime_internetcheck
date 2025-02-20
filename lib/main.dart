import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'message.dart';
import 'message_service.dart';
import 'messages_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initializes Hive with default directory

  // Register your Hive adapter
  Hive.registerAdapter(MessageAdapter());

  // Open the Hive box named 'messages'
  await Hive.openBox<Message>('messages');

  // Initialize Workmanager for background tasks
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    'retryMessagesTask', // Unique name for the task
    'retryMessages', // Task identifier
    frequency: const Duration(minutes: 15),
  );

  runApp(MyApp());
}


/// Background task callback to resend messages.
/// Note: In background isolates, you might need to reinitialize Hive if you encounter issues.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Ensure Flutter bindings are initialized in the background isolate.
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Initialize Hive for Flutter
    //    If you prefer a custom path, use Hive.init(path) instead.
    await Hive.initFlutter();

    // 3. Register adapters again if needed
    Hive.registerAdapter(MessageAdapter());

    // 4. Open any boxes your background task needs
    await Hive.openBox<Message>('messages');

    // 5. Now call your function that uses Hive
    await retrySendingMessages();

    return Future.value(true);
  });
}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start monitoring connectivity to trigger message retries when online
    monitorInternetConnection();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Chat App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Chat App')),
        body: Column(
          children: [
            Expanded(child: MessagesList()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _controller.text;
                      if (text.trim().isEmpty) return;
                      await sendMessage(text);
                      _controller.clear();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
