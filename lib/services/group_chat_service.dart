import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_clone/models/group_file_message.dart';
import 'package:whatsapp_clone/models/group_message.dart';

class GroupChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getGroupChatsStream() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('group_chats')
        .where('memberIds', arrayContains: currentUserId)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            final groupChat = doc.data();

            return groupChat;
          },
        ).toList();
      },
    );
  }

  Future<void> createGroupChat(
      String groupName, File? groupImage, List<String> members) async {
    final String currentUserId = _auth.currentUser!.uid;

    final Map membersMap = {
      for (var member in members)
        member: {
          'isAdmin': false,
          'isMuted': false,
        }
    };

    membersMap[currentUserId] = {
      'isAdmin': true,
      'isMuted': false,
    };

    final DocumentReference groupDocRef =
        _firestore.collection('group_chats').doc();

    final String groupId = groupDocRef.id;

    await groupDocRef.set({
      'groupName': groupName,
      'groupId': groupId,
      'groupImageUrl': null,
      'members': membersMap,
      'memberIds': [currentUserId, ...members]
    });

    await _firestore.collection('users').doc(currentUserId).update({
      'groupChats': FieldValue.arrayUnion([groupId]),
    });

    for (final member in members) {
      await _firestore.collection('users').doc(member).update({
        'groupChats': FieldValue.arrayUnion([groupId]),
      });
    }
  }

  Stream<QuerySnapshot> getMessages(String groupId) {
    return _firestore
        .collection('group_chats')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendGroupMessage(String groupId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    final DocumentReference groupChatDocRef =
        _firestore.collection('group_chats').doc(groupId);

    final senderProfileUrl = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.data()!['profilePic']);

    GroupMessage newGroupMessage = GroupMessage(
      senderId: currentUserId,
      senderPhoneNumber: currentUserPhoneNumber,
      senderProfileUrl: senderProfileUrl,
      groupId: groupId,
      message: message,
      timestamp: timestamp,
    );

    await groupChatDocRef.collection('messages').add(newGroupMessage.toMap());
  }

  Future<void> sendGroupFiles({
    required String groupId,
    required List<String> fileUrls,
    required List<String> fileNames,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    final senderProfileUrl = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.data()!['profilePic']);

    for (String fileUrl in fileUrls) {
      GroupFileMessage newFileMessage = GroupFileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        groupId: groupId,
        fileUrl: fileUrl,
        fileName: fileNames[fileUrls.indexOf(fileUrl)],
        timestamp: timestamp,
        type: 'file',
        senderProfileUrl: senderProfileUrl,
      );

      await _firestore
          .collection('group_chats')
          .doc(groupId)
          .collection('messages')
          .add(newFileMessage.toMap());
    }
  }

  Future<void> sendImages({
    required String groupId,
    required List<String> imagesUrl,
    required List<String> imageNames,
    required List<String?> captions,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    final senderProfileUrl = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.data()!['profilePic']);

    for (String imageUrl in imagesUrl) {
      GroupFileMessage newImageMessage = GroupFileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        groupId: groupId,
        fileUrl: imageUrl,
        fileName: imageNames[imagesUrl.indexOf(imageUrl)],
        timestamp: timestamp,
        caption: captions[imagesUrl.indexOf(imageUrl)],
        type: 'image',
        senderProfileUrl: senderProfileUrl,
      );

      await _firestore
          .collection('group_chats')
          .doc(groupId)
          .collection('messages')
          .add(newImageMessage.toMap());
    }
  }

  Future<void> sendVoiceMessages({
    required String groupId,
    required List<String> voiceMessagesUrl,
    required List<String> voiceMessageNames,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    final senderProfileUrl = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.data()!['profilePic']);

    for (String voiceMessageUrl in voiceMessagesUrl) {
      GroupFileMessage newVoiceMessage = GroupFileMessage(
        senderId: currentUserId,
        senderPhoneNumber: currentUserPhoneNumber,
        groupId: groupId,
        fileUrl: voiceMessageUrl,
        fileName: voiceMessageNames[voiceMessagesUrl.indexOf(voiceMessageUrl)],
        timestamp: timestamp,
        type: 'voice',
        senderProfileUrl: senderProfileUrl,
      );

      await _firestore
          .collection('group_chats')
          .doc(groupId)
          .collection('messages')
          .add(newVoiceMessage.toMap());
    }
  }

  void markMessagesAsRead(String userId, String groupId) {
    GroupReadStatus newReadStatus = GroupReadStatus(
      userId: userId,
      isRead: true,
    );

    _firestore
        .collection('group_chats')
        .doc(groupId)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (final doc in snapshot.docs) {
        if (doc.data()['senderId'] != userId) {
          doc.reference.update({
            'isRead': FieldValue.arrayUnion([newReadStatus.toMap()]),
          });
        }
      }
    });
  }
}
