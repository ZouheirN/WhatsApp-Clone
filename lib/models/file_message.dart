import 'package:cloud_firestore/cloud_firestore.dart';

class FileMessage {
  final String senderId;
  final String senderPhoneNumber;
  final String receiverId;
  final String fileUrl;
  final String fileName;
  final Timestamp timestamp;
  final bool isRead;

  FileMessage({
    required this.senderId,
    required this.senderPhoneNumber,
    required this.receiverId,
    required this.fileUrl,
    required this.fileName,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderPhoneNumber': senderPhoneNumber,
      'receiverId': receiverId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
