import 'package:cloud_firestore/cloud_firestore.dart';

class GroupFileMessage {
  final String senderId;
  final String senderPhoneNumber;
  final String groupId;
  final String fileUrl;
  final String fileName;
  final Timestamp timestamp;
  final bool isRead;
  final String type;
  final String? caption;

  GroupFileMessage({
    required this.senderId,
    required this.senderPhoneNumber,
    required this.groupId,
    required this.fileUrl,
    required this.fileName,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.caption,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderPhoneNumber': senderPhoneNumber,
      'groupId': groupId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
      'caption': caption,
    };
  }
}
