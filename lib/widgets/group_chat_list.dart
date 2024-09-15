import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/file_message/ui/file_message_provider.dart';
import 'package:whatsapp_clone/main.dart';
import 'package:whatsapp_clone/services/group_chat_service.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/my_group_message_card.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/group/sender_group_message_card.dart';

class GroupChatList extends StatelessWidget {
  final String groupId;
  final String senderId;
  final ScrollController scrollController;

  GroupChatList({
    super.key,
    required this.groupId,
    required this.scrollController,
    required this.senderId,
  });

  final GroupChatService _groupChatService = GroupChatService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _groupChatService.getMessages(groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Set the isRead status to true
        _groupChatService.markMessagesAsRead(senderId, groupId);

        return ListView(
          controller: scrollController,
          reverse: true,
          children: snapshot.data!.docs
              .map(
                (doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                  final isCurrentUser = data['senderId'] == senderId;

                  // Convert timestamp to string as HH:MM
                  final String parsedTime =
                      data['timestamp'].toDate().toString().substring(11, 16);

                  logger.d(data);

                  if (data['type'] != null) {
                    return FileMessageProvider(
                      isCurrentUser: isCurrentUser,
                      fileUrl: data['fileUrl'],
                      fileName: data['fileName'],
                      time: parsedTime,
                      isGroupRead: data['isRead'],
                      type: data['type'],
                      caption: data['caption'],
                      isGroup: true,
                      senderProfileUrl: data['senderProfileUrl'],
                    );
                  }

                  if (isCurrentUser) {
                    return MyGroupMessageCard(
                      message: data['message'],
                      time: parsedTime,
                      isRead: data['isRead'],
                    );
                  } else {
                    return SenderGroupMessageCard(
                      message: data['message'],
                      senderProfileUrl: data['senderProfileUrl'],
                      time: parsedTime,
                    );
                  }
                },
              )
              .toList()
              .reversed
              .toList(),
        );
      },
    );
  }
}
