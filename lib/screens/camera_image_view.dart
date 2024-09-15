import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/services/chat_service.dart';
import 'package:whatsapp_clone/services/group_chat_service.dart';
import 'package:whatsapp_clone/services/storage_service.dart';

class CameraImageViewScreen extends StatefulWidget {
  final XFile image;
  final String? receiverId;
  final bool isGroup;
  final String? groupId;

  const CameraImageViewScreen({
    super.key,
    required this.image,
    required this.receiverId,
    this.isGroup = false,
    this.groupId,
  });

  @override
  State<CameraImageViewScreen> createState() => _CameraImageViewScreenState();
}

class _CameraImageViewScreenState extends State<CameraImageViewScreen> {
  late XFile previewImage;

  final TextEditingController _captionController = TextEditingController();

  final ValueNotifier<bool> isUploading = ValueNotifier(false);

  final StorageService _storageService = StorageService();
  final ChatService _chatService = ChatService();
  final GroupChatService _groupChatService = GroupChatService();

  @override
  void initState() {
    previewImage = widget.image;
    super.initState();
  }

  Future<void> _uploadImage() async {
    isUploading.value = true;
    final caption = _captionController.text.trim().isEmpty
        ? null
        : _captionController.text.trim();

    if (kIsWeb) {
      if (widget.isGroup) {
        // todo handle group image upload
      }

      final urls = await _storageService.uploadFilesWeb(
        widget.receiverId!,
        [File(previewImage.path).readAsBytesSync()],
        [previewImage.name],
      );

      _chatService.sendImages(
        receiverId: widget.receiverId!,
        imagesUrl: urls,
        imageNames: [previewImage.name],
        captions: [caption],
      );
    } else {
      if (widget.isGroup) {
        final urls = await _storageService.uploadGroupFiles(
          widget.groupId!,
          [File(previewImage.path)],
          [previewImage.name],
        );

        _groupChatService.sendImages(
          groupId: widget.groupId!,
          imagesUrl: urls,
          imageNames: [previewImage.name],
          captions: [caption],
        );
      } else {
        final urls = await _storageService.uploadFiles(
          widget.receiverId!,
          [File(previewImage.path)],
          [previewImage.name],
        );

        _chatService.sendImages(
          receiverId: widget.receiverId!,
          imagesUrl: urls,
          imageNames: [previewImage.name],
          captions: [caption],
        );
      }
    }

    isUploading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileChatBoxColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            onPressed: () async {
              // final img.Image image = img.decodeImage(File(previewImage.path).readAsBytesSync())!;
              // final img.Image rotatedImage = img.copyRotate(image, angle: 90);
              //
              // final File rotatedFile = File(previewImage.path)..writeAsBytesSync(img.encodeJpg(rotatedImage));
              //
              // setState(() {
              //   previewImage = XFile(rotatedFile.path);
              // });
            },
            icon: const Icon(
              Icons.rotate_left,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.emoji_emotions,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.title,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit,
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(previewImage.path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: mobileChatBoxColor,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_photo_alternate,
                      color: textColor,
                      size: 28,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        maxLines: 6,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(
                            color: textColor,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: textColor,
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: isUploading,
                      builder: (context, value, child) {
                        return CircleAvatar(
                          radius: 25,
                          backgroundColor: tabColor,
                          child: IconButton(
                            onPressed: () async {
                              if (value) return;

                              await _uploadImage();

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            icon: value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
