import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/file_message/ui/file_message_provider.dart';
import 'package:whatsapp_clone/services/chat_service.dart';
import 'package:whatsapp_clone/widgets/chat_bubbles/sender_message_card.dart';

import 'chat_bubbles/my_message_card.dart';

class ChatList extends StatelessWidget {
  final String senderId;
  final String receiverId;
  final ScrollController scrollController;

  ChatList({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.scrollController,
  });

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getMessages(receiverId, senderId),
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

        // Once the messages are loaded or updated, scroll to the bottom
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (scrollController.hasClients) {
        //     // scrollController.animateTo(
        //     //   scrollController.position.maxScrollExtent + 200,
        //     //   duration: const Duration(milliseconds: 300),
        //     //   curve: Curves.easeOut,
        //     // );
        //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
        //   }
        // });

        // Set the isRead status to true
        _chatService.markMessagesAsRead(receiverId, senderId);

        return ListView(
          controller: scrollController,
          reverse: true,
          children: snapshot.data!.docs.map(
            (doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              final isCurrentUser = data['senderId'] == senderId;

              // Convert timestamp to string as HH:MM
              final String parsedTime =
                  data['timestamp'].toDate().toString().substring(11, 16);

              if (data['type'] != null) {
                return FileMessageProvider(
                  isCurrentUser: isCurrentUser,
                  fileUrl: data['fileUrl'],
                  fileName: data['fileName'],
                  time: parsedTime,
                  isRead: data['isRead'],
                  type: data['type'],
                  caption: data['caption'],
                );
              }

              if (isCurrentUser) {
                return MyMessageCard(
                  message: data['message'],
                  time: parsedTime,
                  isRead: data['isRead'],
                );
              } else {
                return SenderMessageCard(
                  message: data['message'],
                  time: parsedTime,
                );
              }
            },
          ).toList().reversed.toList(),
        );
      },
    );
  }
}
