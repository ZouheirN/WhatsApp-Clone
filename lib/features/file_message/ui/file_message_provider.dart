import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/my_file_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/my_image_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/my_video_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/my_voice_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/sender_file_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/sender_image_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/sender_video_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/sender_voice_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/private/my_image_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/private/my_video_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/private/my_voice_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/private/sender_image_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/private/sender_video_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/private/sender_voice_message_card.dart';

import '../../../utils/downloaded_files_box.dart';
import '../../../widgets/chat_bubbles/private/my_file_message_card.dart';
import '../../../widgets/chat_bubbles/private/sender_file_message_card.dart';
import '../cubit/file_message_cubit.dart';

class FileMessageProvider extends StatelessWidget {
  final bool isCurrentUser;
  final String fileName;
  final String fileUrl;
  final String time;
  final bool isRead;
  final String type;
  final String? caption;
  final bool isGroup;
  final List<dynamic> isGroupRead;
  final String? senderProfileUrl;

  const FileMessageProvider({
    super.key,
    required this.isCurrentUser,
    required this.fileName,
    required this.fileUrl,
    required this.time,
    this.isRead = false,
    required this.type,
    this.caption,
    this.isGroup = false,
    this.isGroupRead = const [],
    this.senderProfileUrl,
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
    if (isGroup) {
      switch (type) {
        case 'file':
          return isCurrentUser
              ? MyFileGroupMessageCard(
                  fileName: fileName,
                  fileUrl: fileUrl,
                  isRead: isGroupRead,
                  time: time,
                )
              : SenderFileGroupMessageCard(
                  fileName: fileName,
                  fileUrl: fileUrl,
                  time: time,
                  senderProfileUrl: senderProfileUrl!,
                );
        case 'image':
          return isCurrentUser
              ? MyImageGroupMessageCard(
                  imageUrl: fileUrl,
                  caption: caption,
                  time: time,
                  isRead: isGroupRead,
                )
              : SenderImageGroupMessageCard(
                  imageUrl: fileUrl,
                  caption: caption,
                  time: time,
                  senderProfileUrl: senderProfileUrl!,
                );
        case 'video':
          return isCurrentUser
              ? MyVideoGroupMessageCard(
                  videoUrl: fileUrl,
                  time: time,
                  isRead: isGroupRead,
                )
              : SenderVideoGroupMessageCard(
                  videoUrl: fileUrl,
                  time: time,
                  senderProfileUrl: senderProfileUrl!,
                );
        case 'voice':
          return isCurrentUser
              ? MyVoiceGroupMessageCard(
                  voiceUrl: fileUrl,
                  time: time,
                  isRead: isGroupRead,
                )
              : SenderVoiceGroupMessageCard(
                  voiceUrl: fileUrl,
                  time: time,
                  senderProfileUrl: senderProfileUrl!,
                );
        default:
          return const SizedBox();
      }
    } else {
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
              : SenderVideoMessageCard(
                  videoUrl: fileUrl,
                  time: time,
                );
        case 'voice':
          return isCurrentUser
              ? MyVoiceMessageCard(
                  voiceUrl: fileUrl,
                  time: time,
                  isRead: isRead,
                )
              : SenderVoiceMessageCard(
                  voiceUrl: fileUrl,
                  time: time,
                );
        default:
          return const SizedBox();
      }
    }
  }
}
