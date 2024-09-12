import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_clone/main.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> uploadFilesWeb(
      String receiverId, List<Uint8List> files, List<String> fileNames) async {
    final String currentUserId = _auth.currentUser!.uid;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');

    List<String> fileUrls = [];

    for (int i = 0; i < files.length; i++) {
      final String fileName = fileNames[i];
      final Uint8List file = files[i];

      try {
        final Reference ref = _storage.ref().child('chats/$chatId/$fileName');
        final UploadTask uploadTask = ref.putData(file);

        await uploadTask.whenComplete(() async {
          final String fileUrl = await ref.getDownloadURL();
          fileUrls.add(fileUrl);
        });
      } on PlatformException catch (e) {
        logger.e('Failed to upload file: $e');
      }
    }

    return fileUrls;
  }

  Future<List<String>> uploadFiles(
      String receiverId, List<File> files, List<String> fileNames) async {
    final String currentUserId = _auth.currentUser!.uid;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join('_');

    List<String> fileUrls = [];

    for (int i = 0; i < files.length; i++) {
      final File file = files[i];
      final String fileName = fileNames[i];

      try {
        final Reference ref = _storage.ref().child('chats/$chatId/$fileName');
        final UploadTask uploadTask = ref.putFile(file);

        await uploadTask.whenComplete(() async {
          final String fileUrl = await ref.getDownloadURL();
          fileUrls.add(fileUrl);
        });
      } on PlatformException catch (e) {
        logger.e('Failed to upload file: $e');
      }
    }

    return fileUrls;
  }

  Future<bool> uploadProfilePicture(File file) async {
    final String currentUserId = _auth.currentUser!.uid;

    try {
      final Reference ref =
          _storage.ref().child('profile_pictures/$currentUserId.jpg');
      final UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        final String fileUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .update({'profilePic': fileUrl});

        return true;
      });
    } on PlatformException catch (e) {
      logger.e('Failed to upload file: $e');
    }

    return false;
  }

  Future<String?> uploadGroupProfilePicture(String groupId, File file) async {
    try {
      final Reference ref =
          _storage.ref().child('group_chat_pictures/$groupId.jpg');
      final UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        final String fileUrl = await ref.getDownloadURL();
        return fileUrl;
      });
    } on PlatformException catch (e) {
      logger.e('Failed to upload file: $e');
    }

    return null;
  }

  Future<List<String>> uploadGroupFiles(
      String groupId, List<File> files, List<String> fileNames) async {
    List<String> fileUrls = [];

    for (int i = 0; i < files.length; i++) {
      final File file = files[i];
      final String fileName = fileNames[i];

      try {
        final Reference ref =
            _storage.ref().child('group_chats/$groupId/$fileName');
        final UploadTask uploadTask = ref.putFile(file);

        await uploadTask.whenComplete(() async {
          final String fileUrl = await ref.getDownloadURL();
          fileUrls.add(fileUrl);
        });
      } on PlatformException catch (e) {
        logger.e('Failed to upload file: $e');
      }
    }

    return fileUrls;
  }
}
