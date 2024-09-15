import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/camera_screen.dart';
import 'package:whatsapp_clone/utils/format_time.dart';

class MobileMessageBox extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final FlutterSoundRecorder soundRecorder;
  final ValueNotifier<bool> isUploading;
  final ValueNotifier<bool> isRecording;
  final ValueNotifier<Duration> recordingDuration;
  final String? receiverId;
  final void Function() pickFiles;
  final void Function(String filePath) sendVoiceMessage;
  final void Function() sendMessage;
  final bool isGroup;
  final String? groupId;

  const MobileMessageBox({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.soundRecorder,
    required this.isUploading,
    required this.isRecording,
    required this.recordingDuration,
    required this.receiverId,
    required this.pickFiles,
    required this.sendVoiceMessage,
    required this.sendMessage,
    this.isGroup = false,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                            builder: (context, recordingDurationValue, child) {
                              return TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: mobileChatBoxColor,
                                  prefixIcon: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      Icons.mic_none,
                                      color: Colors.red,
                                    ),
                                  ),
                                  hintText: formatTime(recordingDurationValue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                              );
                            }),
                      )
                    else
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: mobileChatBoxColor,
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            suffixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => pickFiles(),
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
                                            receiverId: receiverId,
                                            isGroup: isGroup,
                                            groupId: groupId,
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
                            hintText:
                                AppLocalizations.of(context)!.typeAMessage,
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
                      valueListenable: messageController,
                      builder: (context, value, child) {
                        if (messageController.text.isNotEmpty) {
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
                            radius: isRecordingValue ? 30 : 20,
                            backgroundColor: tabColor,
                            child: GestureDetector(
                              onLongPress: () async {
                                final tempDir = await getTemporaryDirectory();
                                final path =
                                    '${tempDir.path}/audio_${DateTime.now()}.aac';

                                await soundRecorder.startRecorder(
                                  toFile: path,
                                );

                                isRecording.value = true;
                              },
                              onLongPressEnd: (details) async {
                                String? filePath =
                                    await soundRecorder.stopRecorder();

                                sendVoiceMessage(filePath!);

                                isRecording.value = false;
                              },
                              child: Icon(
                                isRecordingValue ? Icons.close : Icons.mic,
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
    );
  }
}
