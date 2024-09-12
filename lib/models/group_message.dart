import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String senderId;
  final String senderPhoneNumber;
  final String groupChatId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  GroupMessage({
    required this.senderId,
    required this.senderPhoneNumber,
    required this.groupChatId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderPhoneNumber': senderPhoneNumber,
      'groupChatId': groupChatId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
