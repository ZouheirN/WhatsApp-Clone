import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_clone/models/file_message.dart';
import 'package:whatsapp_clone/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            final user = doc.data();

            return user;
          },
        ).toList();
      },
    );
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderPhoneNumber: currentUserPhoneNumber,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Future<void> sendFiles(
      String receiverId, List<String> filesUrl, List<String> fileNames) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    for (String fileUrl in filesUrl) {
      FileMessage newFileMessage = FileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        receiverId: receiverId,
        fileUrl: fileUrl,
        fileName: fileNames[filesUrl.indexOf(fileUrl)],
        timestamp: timestamp,
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatId = ids.join('_');

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newFileMessage.toMap());
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatId = ids.join('_');

    // // set the messages as read
    // _firestore
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .where('senderId', isNotEqualTo: otherUserId)
    //     .where('isRead', isEqualTo: false)
    //     .get()
    //     .then((snapshot) {
    //   for (QueryDocumentSnapshot doc in snapshot.docs) {
    //     doc.reference.update({'isRead': true});
    //   }
    // });

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getLatestMessage(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatId = ids.join('_');

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  void markMessagesAsRead(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatId = ids.join('_');

    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: otherUserId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });
  }
}
