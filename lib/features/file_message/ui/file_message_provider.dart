import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  const FileMessageProvider({
    super.key,
    required this.isCurrentUser,
    required this.fileName,
    required this.fileUrl,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFileDownloaded = DownloadedFilesBox.isFileDownloaded(fileUrl);

    return BlocProvider(
      create: (context) => FileMessageCubit(isFileDownloaded ? 1.0 : 0.0),
      child: isCurrentUser
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
            ),
    );
  }
}
