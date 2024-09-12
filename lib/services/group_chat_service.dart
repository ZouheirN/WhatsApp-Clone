import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    await groupDocRef.set({
      'groupName': groupName,
      'groupImageUrl': null,
      'members': membersMap,
      'memberIds': [currentUserId, ...members]
    });

    final String groupId = groupDocRef.id;
    await _firestore.collection('users').doc(currentUserId).update({
      'groupChats': FieldValue.arrayUnion([groupId]),
    });

    for (final member in members) {
      await _firestore.collection('users').doc(member).update({
        'groupChats': FieldValue.arrayUnion([groupId]),
      });
    }
  }

  Future<void> sendGroupMessage(String groupId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserPhoneNumber = _auth.currentUser!.phoneNumber!;
    final Timestamp timestamp = Timestamp.now();

    final DocumentReference groupChatDocRef =
        _firestore.collection('group_chats').doc(groupId);

    GroupMessage newGroupMessage = GroupMessage(
      senderId: currentUserId,
      senderPhoneNumber: currentUserPhoneNumber,
      groupChatId: groupId,
      message: message,
      timestamp: timestamp,
    );

    await groupChatDocRef.collection('messages').add(newGroupMessage.toMap());
  }
}
