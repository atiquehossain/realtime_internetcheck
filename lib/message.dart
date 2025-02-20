import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool sent;

  Message({required this.text, this.sent = false});
}
