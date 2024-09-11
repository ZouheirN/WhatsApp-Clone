import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/my_image_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/my_video_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/my_voice_message.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/sender_image_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/sender_voice_message.dart';

import '../../../utils/downloaded_files_box.dart';
import '../../../widgets/chat_bubbles/my_file_message_card.dart';
import '../../../widgets/chat_bubbles/sender_file_message_card.dart';
import '../cubit/file_message_cubit.dart';

class FileMessageProvider extends StatelessWidget {
  final bool isCurrentUser;
  final String fileName;
  final String fileUrl;
  final String time;
  final bool isRead;
  final String type;
  final String? caption;

  const FileMessageProvider({
    super.key,
    required this.isCurrentUser,
    required this.fileName,
    required this.fileUrl,
    required this.time,
    this.isRead = false,
    required this.type,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final isFileDownloaded = DownloadedFilesBox.isFileDownloaded(fileUrl);

    return BlocProvider(
      create: (context) => FileMessageCubit(isFileDownloaded ? 1.0 : 0.0),
      child: getAppropriateMessageType(),
    );
  }

  Widget getAppropriateMessageType() {
    switch (type) {
      case 'file':
        return isCurrentUser
            ? MyFileMessageCard(
                fileName: fileName,
                fileUrl: fileUrl,
                isRead: isRead,
                time: time,
              )
            : SenderFileMessageCard(
                fileName: fileName,
                fileUrl: fileUrl,
                time: time,
              );
      case 'image':
        return isCurrentUser
            ? MyImageMessageCard(
                imageUrl: fileUrl,
                caption: caption,
                time: time,
                isRead: isRead,
              )
            : SenderImageMessageCard(
                imageUrl: fileUrl,
                caption: caption,
                time: time,
              );
      case 'video':
        return isCurrentUser
            ? MyVideoMessageCard(
                videoUrl: fileUrl,
                time: time,
                isRead: isRead,
              )
            : MyVideoMessageCard(
                videoUrl: fileUrl,
                time: time,
                isRead: isRead,
              );
      case 'voice':
        return isCurrentUser
            ? MyVoiceMessage(
                voiceUrl: fileUrl,
                time: time,
                isRead: isRead,
              )
            : SenderVoiceMessage(
                voiceUrl: fileUrl,
                time: time,
              );
      default:
        return const SizedBox();
    }
  }
}
