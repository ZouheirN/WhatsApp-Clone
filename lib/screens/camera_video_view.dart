import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/services/chat_service.dart';
import 'package:whatsapp_clone/services/storage_service.dart';

class CameraVideoViewScreen extends StatefulWidget {
  final XFile video;
  final String? receiverId;

  const CameraVideoViewScreen({super.key, required this.video, required this.receiverId});

  @override
  State<CameraVideoViewScreen> createState() => _CameraVideoViewScreenState();
}

class _CameraVideoViewScreenState extends State<CameraVideoViewScreen> {
  late VideoPlayerController _videoPlayerController;

  final TextEditingController _captionController = TextEditingController();

  final ValueNotifier<bool> isUploading = ValueNotifier(false);

  final StorageService _storageService = StorageService();
  final ChatService _chatService = ChatService();

  Future<void> _uploadVideo() async {
    isUploading.value = true;
    final caption = _captionController.text.trim().isEmpty
        ? null
        : _captionController.text.trim();

    if (kIsWeb) {
      final urls = await _storageService.uploadFilesWeb(
        widget.receiverId!,
        [File(widget.video.path).readAsBytesSync()],
        [widget.video.name],
      );

      _chatService.sendVideos(
        receiverId: widget.receiverId!,
        videosUrl: urls,
        videoNames: [widget.video.name],
        captions: [caption],
      );
    } else {
      final urls = await _storageService.uploadFiles(
        widget.receiverId!,
        [File(widget.video.path)],
        [widget.video.name],
      );

      _chatService.sendVideos(
        receiverId: widget.receiverId!,
        videosUrl: urls,
        videoNames: [widget.video.name],
        captions: [caption],
      );
    }

    isUploading.value = false;
  }

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(File(widget.video.path))
      ..initialize().then((_) {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileChatBoxColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: _videoPlayerController.value.isInitialized
                  ? RotatedBox(
                      quarterTurns: 1,
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    )
                  : Container(),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: mobileChatBoxColor,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Row(
                  children: [
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

                                await _uploadVideo();

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
                        })
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ValueListenableBuilder(
                valueListenable: _videoPlayerController,
                builder: (context, value, child) => IconButton(
                  onPressed: () {
                    setState(() {
                      if (_videoPlayerController.value.isPlaying) {
                        _videoPlayerController.pause();
                      } else {
                        _videoPlayerController.play();
                      }
                    });
                  },
                  icon: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: Icon(
                      _videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
