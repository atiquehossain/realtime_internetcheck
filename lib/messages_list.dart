import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'message.dart';

class MessagesList extends StatefulWidget {
  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  late Box<Message> messagesBox;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    messagesBox = await Hive.openBox<Message>('messages');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Message>('messages').listenable(),
      builder: (context, Box<Message> box, _) {
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final message = box.getAt(index);
            if (message == null) return const SizedBox.shrink();
            return ListTile(
              title: Text(message.text),
              subtitle: Text(message.sent ? "Sent" : "Pending..."),
            );
          },
        );
      },
    );
  }
}
