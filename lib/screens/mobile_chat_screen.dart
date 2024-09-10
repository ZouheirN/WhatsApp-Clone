import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/camera_screen.dart';
import 'package:whatsapp_clone/services/chat_service.dart';

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

  final ValueNotifier<bool> isUploading = ValueNotifier(false);

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverId,
        _messageController.text.trim(),
      );

      _messageController.clear();
    }
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
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.receiverProfilePic),
            ),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverPhoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                StreamBuilder(
                  stream: _chatService.isUserOnline(widget.receiverId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      final bool isOnline = snapshot.data as bool;

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
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: ValueListenableBuilder(
              valueListenable: isUploading,
              builder: (context, value, child) {
                if (value) {
                  return const LinearProgressIndicator();
                }

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: mobileChatBoxColor,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _pickFiles(),
                                  icon: const Icon(
                                    Icons.attach_file,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CameraScreen(
                                          receiverId: widget.receiverId,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: AppLocalizations.of(context)!.typeAMessage,
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
                              onPressed: sendMessage,
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: tabColor,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.mic,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      },
                    )
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
