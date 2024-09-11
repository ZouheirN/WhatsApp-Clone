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

  Stream<bool> isUserOnline(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
      (snapshot) {
        final user = snapshot.data() as Map<String, dynamic>;

        return user['isOnline'];
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
    String receiverId,
    List<String> filesUrl,
    List<String> fileNames,
  ) async {
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
        type: 'file',
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

  Future<void> sendImages({
    required String receiverId,
    required List<String> imagesUrl,
    required List<String> imageNames,
    required List<String?> captions,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    for (String imageUrl in imagesUrl) {
      FileMessage newImageMessage = FileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        receiverId: receiverId,
        fileUrl: imageUrl,
        fileName: imageNames[imagesUrl.indexOf(imageUrl)],
        timestamp: timestamp,
        caption: captions[imagesUrl.indexOf(imageUrl)],
        type: 'image',
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatId = ids.join('_');

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newImageMessage.toMap());
    }
  }

  Future<void> sendVideos({
    required String receiverId,
    required List<String> videosUrl,
    required List<String> videoNames,
    required List<String> captions,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    for (String videoUrl in videosUrl) {
      FileMessage newVideoMessage = FileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        receiverId: receiverId,
        fileUrl: videoUrl,
        fileName: videoNames[videosUrl.indexOf(videoUrl)],
        timestamp: timestamp,
        caption: captions[videosUrl.indexOf(videoUrl)],
        type: 'video',
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatId = ids.join('_');

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newVideoMessage.toMap());
    }
  }

  Future<void> sendVoiceMessages({
    required String receiverId,
    required List<String> voiceMessagesUrl,
    required List<String> voiceMessageNames,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    for (String voiceMessageUrl in voiceMessagesUrl) {
      FileMessage newVoiceMessage = FileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        receiverId: receiverId,
        fileUrl: voiceMessageUrl,
        fileName: voiceMessageNames[voiceMessagesUrl.indexOf(voiceMessageUrl)],
        timestamp: timestamp,
        type: 'voice',
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatId = ids.join('_');

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newVoiceMessage.toMap());
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatId = ids.join('_');

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
