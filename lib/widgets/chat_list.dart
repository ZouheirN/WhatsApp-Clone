import 'package:flutter/material.dart';
import 'package:whatsapp_clone/services/chat/chat_service.dart';
import 'package:whatsapp_clone/widgets/sender_message_card.dart';

import 'my_message_card.dart';

class ChatList extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final ScrollController scrollController;

  const ChatList({super.key, required this.senderId, required this.receiverId, required this.scrollController});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverId, widget.senderId),
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

        return ListView(
          controller: widget.scrollController,
          children: snapshot.data!.docs.map(
            (doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              final isCurrentUser = data['senderId'] == widget.senderId;

              // convert timestamp to string as HH:MM
              final String parsedTime = data['timestamp'].toDate().toString().substring(11, 16);

              if (isCurrentUser) {
                return MyMessageCard(
                  message: data['message'],
                  time: parsedTime,
                );
              } else {
                return SenderMessageCard(
                    message: data['message'], time: parsedTime);
              }
            },
          ).toList(),
        );
      },
    );
  }
}
