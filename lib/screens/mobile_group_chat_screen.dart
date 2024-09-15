import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/services/group_chat_service.dart';
import 'package:whatsapp_clone/services/storage_service.dart';
import 'package:whatsapp_clone/widgets/group_chat_list.dart';
import 'package:whatsapp_clone/widgets/mobile_message_box.dart';

class MobileGroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupProfilePic;

  const MobileGroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupProfilePic,
  });

  @override
  State<MobileGroupChatScreen> createState() => _MobileGroupChatScreenState();
}

class _MobileGroupChatScreenState extends State<MobileGroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final GroupChatService _groupChatService = GroupChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  bool isRecorderInitialised = false;

  final ValueNotifier<bool> isUploading = ValueNotifier(false);
  final ValueNotifier<bool> isRecording = ValueNotifier(false);
  Timer recordingDurationTimer = Timer(Duration.zero, () {});
  final ValueNotifier<Duration> recordingDuration =
      ValueNotifier(Duration.zero);

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _groupChatService.sendGroupMessage(
        widget.groupId,
        _messageController.text.trim(),
      );

      _messageController.clear();
    }
  }

  void _sendVoiceMessage(String filePath) async {
    isUploading.value = true;

    // extract the file name from the file path
    final List<String> pathParts = filePath.split('/');
    final String fileName = pathParts.last;

    // Upload the file to firestore and get link
    List<String> fileUrls = await StorageService().uploadGroupFiles(
      widget.groupId,
      [File(filePath)],
      [fileName],
    );

    // Send the FileMessage
    _groupChatService.sendVoiceMessages(
      groupId: widget.groupId,
      voiceMessagesUrl: fileUrls,
      voiceMessageNames: [fileName],
    );

    isUploading.value = false;
  }

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null) return;

    List<File> files = result.paths.map((path) => File(path!)).toList();
    List<String> fileNames = result.files.map((file) => file.name).toList();

    isUploading.value = true;

    // Upload the files to firestore and get link
    List<String> fileUrls = await StorageService().uploadGroupFiles(
      widget.groupId,
      files,
      fileNames,
    );

    // Send the FileMessage
    _groupChatService.sendGroupFiles(
      groupId: widget.groupId,
      fileUrls: fileUrls,
      fileNames: fileNames,
    );

    isUploading.value = false;
  }

  @override
  void initState() {
    _openAudio();
    isRecording.addListener(() {
      if (isRecording.value) {
        recordingDurationTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            recordingDuration.value += const Duration(seconds: 1);
          },
        );
      } else {
        recordingDurationTimer.cancel();
        recordingDuration.value = const Duration();
      }
    });
    super.initState();
  }

  void _openAudio() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _soundRecorder.openRecorder();
    isRecorderInitialised = true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _soundRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: InkWell(
          onTap: () {},
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                child: widget.groupProfilePic != null
                    ? Image.network(widget.groupProfilePic!)
                    : const Icon(Icons.group),
              ),
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 1,
                  child: Text('View Contact'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Media, links, and docs'),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text('Search'),
                ),
                const PopupMenuItem(
                  value: 4,
                  child: Text('Mute notifications'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 1:
                  break;
                case 2:
                  break;
                case 3:
                  break;
                case 4:
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupChatList(
              groupId: widget.groupId,
              scrollController: _scrollController,
              senderId: _auth.currentUser!.uid,
            ),
          ),
          MobileMessageBox(
            messageController: _messageController,
            focusNode: _focusNode,
            soundRecorder: _soundRecorder,
            isUploading: isUploading,
            isRecording: isRecording,
            recordingDuration: recordingDuration,
            receiverId: null,
            pickFiles: _pickFiles,
            sendVoiceMessage: _sendVoiceMessage,
            sendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
