import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/utils/format_time.dart';

class SenderVoiceMessage extends StatefulWidget {
  final String voiceUrl;
  final String time;

  const SenderVoiceMessage({
    super.key,
    required this.voiceUrl,
    required this.time,
  });

  @override
  State<SenderVoiceMessage> createState() => _SenderVoiceMessageState();
}

class _SenderVoiceMessageState extends State<SenderVoiceMessage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = const Duration();
  Duration position = const Duration();

  @override
  void initState() {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.setSource(UrlSource(widget.voiceUrl));

    audioPlayer.onPlayerStateChanged.listen(
      (event) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });
      },
    );

    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    audioPlayer.onPositionChanged.listen((event) {
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
      alignment: Alignment.centerLeft,
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
          color: senderMessageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 30, top: 5, bottom: 20),
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
                      ],
                    ),
                    Text(
                      isPlaying ? formatTime(position) : formatTime(duration),
                      style: const TextStyle(
                        fontSize: 13,
                        color: textColor,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Text(
                  widget.time.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
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
