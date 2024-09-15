import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/colors.dart';

class MyVideoGroupMessageCard extends StatefulWidget {
  final String videoUrl;
  final String time;
  final List<dynamic> isRead;

  const MyVideoGroupMessageCard({
    super.key,
    required this.videoUrl,
    required this.time,
    required this.isRead,
  });

  @override
  State<MyVideoGroupMessageCard> createState() =>
      _MyVideoGroupMessageCardState();
}

class _MyVideoGroupMessageCardState extends State<MyVideoGroupMessageCard> {
  late CachedVideoPlayerPlusController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.videoUrl),
      invalidateCacheIfOlderThan: const Duration(days: 60),
    )..initialize().then((value) async {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAllRead = false;

    for (var i = 0; i < widget.isRead.length; i++) {
      if (widget.isRead[i]['isRead'] == false) {
        isAllRead = false;
        break;
      } else {
        isAllRead = true;
      }
    }

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
          minWidth: 120,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: messageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 30, top: 5, bottom: 20),
                child: Stack(
                  children: [
                    SizedBox(
                      width: _videoPlayerController.value.size.height * 0.8,
                      height: _videoPlayerController.value.size.width * 0.8,
                      child: _videoPlayerController.value.isInitialized
                          ? RotatedBox(
                              quarterTurns: 1,
                              child: AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: CachedVideoPlayerPlus(
                                    _videoPlayerController),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                    if (!_videoPlayerController.value.isInitialized)
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
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      widget.time.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    const Gap(5),
                    if (isAllRead)
                      const Icon(
                        Icons.done_all,
                        size: 20,
                        color: Colors.white60,
                      )
                    else
                      const Icon(
                        Icons.done,
                        size: 20,
                        color: Colors.white60,
                      ),
                  ],
                ),
              ),
              if (_videoPlayerController.value.isInitialized)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
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
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
