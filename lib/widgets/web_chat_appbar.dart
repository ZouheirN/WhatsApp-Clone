import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/services/chat_service.dart';
import 'package:whatsapp_clone/utils/contacts_box.dart';

class WebChatAppbar extends StatefulWidget {
  final String selectedUserId;
  final String selectedUserPhoneNumber;
  final String selectedUserProfilePic;

  const WebChatAppbar({
    super.key,
    required this.selectedUserPhoneNumber,
    required this.selectedUserProfilePic,
    required this.selectedUserId,
  });

  @override
  State<WebChatAppbar> createState() => _WebChatAppbarState();
}

class _WebChatAppbarState extends State<WebChatAppbar> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.077,
      padding: const EdgeInsets.all(8),
      color: webAppBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.selectedUserProfilePic),
            radius: 30,
          ),
          ValueListenableBuilder(
            valueListenable: ContactsBox.watchContact(widget.selectedUserId),
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedUserPhoneNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  StreamBuilder(
                    stream: _chatService.isUserOnline(widget.selectedUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        final bool isOnline = snapshot.data as bool;

                        if (isOnline) {
                          return Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              AppLocalizations.of(context)!.online,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                      }

                      return const SizedBox();
                    },
                  ),
                ],
              );
            }
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
