import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String senderId;
  final String senderPhoneNumber;
  final String senderProfileUrl;
  final String groupChatId;
  final String message;
  final Timestamp timestamp;
  final List<GroupReadStatus> isRead;

  GroupMessage({
    required this.senderId,
    required this.senderPhoneNumber,
    required this.senderProfileUrl,
    required this.groupChatId,
    required this.message,
    required this.timestamp,
    this.isRead = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderPhoneNumber': senderPhoneNumber,
      'senderProfileUrl': senderProfileUrl,
      'groupChatId': groupChatId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}

class GroupReadStatus {
  final String userId;
  final bool isRead;

  GroupReadStatus({
    required this.userId,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isRead': isRead,
    };
  }

}
