import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/camera_screen.dart';
import 'package:whatsapp_clone/screens/view_contact_screen.dart';
import 'package:whatsapp_clone/services/chat_service.dart';
import 'package:whatsapp_clone/utils/contacts_box.dart';
import 'package:whatsapp_clone/utils/format_time.dart';
import 'package:whatsapp_clone/widgets/mobile_message_box.dart';

import '../services/storage_service.dart';
import '../widgets/chat_list.dart';

class MobileChatScreen extends StatefulWidget {
  final String receiverPhoneNumber;
  final String receiverId;
  final String receiverProfilePic;

  const MobileChatScreen({
    super.key,
    required this.receiverPhoneNumber,
    required this.receiverId,
    required this.receiverProfilePic,
  });

  @override
  State<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends State<MobileChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
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
      await _chatService.sendMessage(
        widget.receiverId,
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
    List<String> fileUrls = await StorageService().uploadFiles(
      widget.receiverId,
      [File(filePath)],
      [fileName],
    );

    // Send the FileMessage
    _chatService.sendVoiceMessages(
      receiverId: widget.receiverId,
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
    List<String> fileUrls = await StorageService().uploadFiles(
      widget.receiverId,
      files,
      fileNames,
    );

    // Send the FileMessage
    _chatService.sendFiles(
      widget.receiverId,
      fileUrls,
      fileNames,
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ViewContactScreen(
                  contactId: widget.receiverId,
                  contactPhoneNumber: widget.receiverPhoneNumber,
                  contactProfilePic: widget.receiverProfilePic,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.receiverProfilePic),
              ),
              const Gap(10),
              ValueListenableBuilder(
                  valueListenable: ContactsBox.watchContact(widget.receiverId),
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ContactsBox.getContactName(widget.receiverId) ??
                              widget.receiverPhoneNumber,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        StreamBuilder(
                          stream: _chatService.isUserOnline(widget.receiverId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              bool? isOnline = snapshot.data;
                              isOnline ??= false;

                              if (isOnline) {
                                return Text(
                                  AppLocalizations.of(context)!.online,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                            }

                            return const SizedBox();
                          },
                        ),
                      ],
                    );
                  }),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewContactScreen(
                        contactId: widget.receiverId,
                        contactPhoneNumber: widget.receiverPhoneNumber,
                        contactProfilePic: widget.receiverProfilePic,
                      ),
                    ),
                  );
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
            child: ChatList(
              senderId: _auth.currentUser!.uid,
              receiverId: widget.receiverId,
              scrollController: _scrollController,
            ),
          ),
          MobileMessageBox(
            focusNode: _focusNode,
            receiverId: widget.receiverId,
            isRecording: isRecording,
            isUploading: isUploading,
            messageController: _messageController,
            pickFiles: _pickFiles,
            recordingDuration: recordingDuration,
            sendMessage: _sendMessage,
            sendVoiceMessage: _sendVoiceMessage,
            soundRecorder: _soundRecorder,
            isGroup: false,
            groupId: null,
          ),
        ],
      ),
    );
  }
}
