import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/services/group_chat_service.dart';
import 'package:whatsapp_clone/services/storage_service.dart';
import 'package:whatsapp_clone/utils/format_time.dart';
import 'package:whatsapp_clone/widgets/group_chat_list.dart';

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

  // void _pickFiles() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.any,
  //   );
  //
  //   if (result == null) return;
  //
  //   List<File> files = result.paths.map((path) => File(path!)).toList();
  //   List<String> fileNames = result.files.map((file) => file.name).toList();
  //
  //   isUploading.value = true;
  //
  //   // Upload the files to firestore and get link
  //   List<String> fileUrls = await StorageService().uploadFiles(
  //     widget.receiverId,
  //     files,
  //     fileNames,
  //   );
  //
  //   // Send the FileMessage
  //   _chatService.sendFiles(
  //     widget.receiverId,
  //     fileUrls,
  //     fileNames,
  //   );
  //
  //   isUploading.value = false;
  // }

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
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: ValueListenableBuilder(
              valueListenable: isUploading,
              builder: (context, value, child) {
                if (value) {
                  return const LinearProgressIndicator();
                }

                return ValueListenableBuilder(
                    valueListenable: isRecording,
                    builder: (context, isRecordingValue, child) {
                      return Row(
                        children: [
                          if (isRecordingValue)
                            Expanded(
                              child: ValueListenableBuilder(
                                  valueListenable: recordingDuration,
                                  builder:
                                      (context, recordingDurationValue, child) {
                                    return TextField(
                                      enabled: false,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: mobileChatBoxColor,
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Icon(
                                            Icons.mic_none,
                                            color: Colors.red,
                                          ),
                                        ),
                                        hintText:
                                            formatTime(recordingDurationValue),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                      ),
                                    );
                                  }),
                            )
                          else
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: mobileChatBoxColor,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.emoji_emotions_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => {},
                                          icon: const Icon(
                                            Icons.attach_file,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  hintText: AppLocalizations.of(context)!
                                      .typeAMessage,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          const Gap(5),
                          ValueListenableBuilder(
                            valueListenable: _messageController,
                            builder: (context, value, child) {
                              if (_messageController.text.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 20,
                                  backgroundColor: tabColor,
                                  child: IconButton(
                                    onPressed: _sendMessage,
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              } else {
                                return CircleAvatar(
                                  radius: isRecordingValue ? 30 : 20,
                                  backgroundColor: tabColor,
                                  child: GestureDetector(
                                    onLongPress: () async {
                                      final tempDir =
                                          await getTemporaryDirectory();
                                      final path =
                                          '${tempDir.path}/audio_${DateTime.now()}.aac';

                                      await _soundRecorder.startRecorder(
                                        toFile: path,
                                      );

                                      isRecording.value = true;
                                    },
                                    onLongPressEnd: (details) async {
                                      String? filePath =
                                          await _soundRecorder.stopRecorder();

                                      _sendVoiceMessage(filePath!);

                                      isRecording.value = false;
                                    },
                                    child: Icon(
                                      isRecordingValue
                                          ? Icons.close
                                          : Icons.mic,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}
