import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/utils/format_time.dart';

class MyVoiceMessage extends StatefulWidget {
  final String voiceUrl;
  final String time;
  final bool isRead;

  const MyVoiceMessage({
    super.key,
    required this.voiceUrl,
    required this.time,
    required this.isRead,
  });

  @override
  State<MyVoiceMessage> createState() => _MyVoiceMessageState();
}

class _MyVoiceMessageState extends State<MyVoiceMessage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = const Duration();
  Duration position = const Duration();
  List<double> speeds = [1.0, 1.5, 2.0];
  late double selectedSpeed;

  @override
  void initState() {
    selectedSpeed = speeds.first;

    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.setSource(UrlSource(widget.voiceUrl));

    audioPlayer.onPlayerStateChanged.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          isPlaying = event == PlayerState.playing;
        });
      },
    );

    audioPlayer.onDurationChanged.listen((event) {
      if (!mounted) return;
      setState(() {
        duration = event;
      });
    });

    audioPlayer.onPositionChanged.listen((event) {
      if (!mounted) return;
      setState(() {
        position = event;
      });
    });
    super.initState();
  }

  @override
  dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    left: 10, right: 20, top: 5, bottom: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 30,
                        ),
                        IconButton(
                          onPressed: () async {
                            if (isPlaying) {
                              await audioPlayer.pause();
                            } else {
                              await audioPlayer.resume();
                            }
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Slider(
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble(),
                          activeColor: tabColor,
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await audioPlayer.seek(position);
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final index = speeds.indexOf(selectedSpeed);
                              if (index == speeds.length - 1) {
                                selectedSpeed = speeds.first;
                              } else {
                                selectedSpeed = speeds[index + 1];
                              }
                              audioPlayer.setPlaybackRate(selectedSpeed);
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: dividerColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${selectedSpeed % 1 == 0 ? selectedSpeed.toStringAsFixed(0) : selectedSpeed.toString()}x',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Text(
                      isPlaying ? formatTime(position) : formatTime(duration),
                      style: const TextStyle(
                        fontSize: 13,
                        color: textColor,
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
                    if (widget.isRead)
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
