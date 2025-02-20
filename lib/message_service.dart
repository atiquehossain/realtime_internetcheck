import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'message.dart';

/// Sends a message. If offline, it is saved locally.
Future<void> sendMessage(String text) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  final messagesBox = await Hive.openBox<Message>('messages');

  if (connectivityResult == ConnectivityResult.none) {
    // Save message locally if offline
    await messagesBox.add(Message(text: text, sent: false));
    print("Saved message offline: $text");
  } else {
    // Attempt to send the message immediately
    bool success = await sendToBackend(text);
    if (!success) {
      await messagesBox.add(Message(text: text, sent: false));
      print("Sending failed, saved message offline: $text");
    }
  }
}

/// Simulates sending a message to your backend.


Future<bool> sendToBackend(String text) async {
  try {
    Dio dio = Dio();

    // First POST without following redirects.
    Response response = await dio.post(
      'https://script.google.com/macros/s/AKfycbwBBJBkE5vhN0PtP0pGZL1e9lzpsvqzXNOko7eAoXkle4ZJy5zdQqm6BVrmJL1Fkao/exec',
      data: {
        "message": text,
        "timestamp": DateTime.now().toIso8601String(),
        "senderId": "user123",
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        followRedirects: false, // disable automatic redirects
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    // Check if the response is a 302 redirect.
    if (response.statusCode == 302) {
      String? redirectUrl = response.headers.value("location");
      if (redirectUrl != null) {
        // Follow the redirect by making another POST request.
        Response finalResponse = await dio.post(
          redirectUrl,
          data: {
            "message": text,
            "timestamp": DateTime.now().toIso8601String(),
            "senderId": "user123",
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true, // allow redirects on this request
            validateStatus: (status) => status != null && status < 400,
          ),
        );
        print("Final Response: ${finalResponse.data}");
        return finalResponse.statusCode == 200;
      } else {
        print("Redirect URL not found.");
        return false;
      }
    } else {
      // If no redirect occurred, print and return normally.
      print("Response: ${response.data}");
      return response.statusCode == 200;
    }
  } catch (e) {
    print("Error sending message: $e");
    return false;
  }
}





/// Retries sending all unsent messages.
Future<void> retrySendingMessages() async {
  final messagesBox = await Hive.openBox<Message>('messages');
  for (var i = 0; i < messagesBox.length; i++) {
    Message? msg = messagesBox.getAt(i);
    if (msg != null && !msg.sent) {
      bool success = await sendToBackend(msg.text);
      if (success) {
        msg.sent = true;
        await messagesBox.putAt(i, msg);
        print("Resent message: ${msg.text}");
      }
    }
  }
}

/// Listens for connectivity changes and retries sending messages when online.
void monitorInternetConnection() {
  Connectivity().onConnectivityChanged.listen((status) {
    if (status != ConnectivityResult.none) {
      retrySendingMessages();
    }
  });
}
