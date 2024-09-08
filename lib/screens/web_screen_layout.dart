import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/web_settings_screen.dart';
import 'package:whatsapp_clone/utils/utilities_box.dart';

import '../services/chat/chat_service.dart';
import '../widgets/chat_list.dart';
import '../widgets/contacts_list.dart';
import '../widgets/web_chat_appbar.dart';
import '../widgets/web_profile_bar.dart';
import '../widgets/web_search_bar.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  ValueNotifier<bool> settingsOpen = ValueNotifier(false);

  void sendMessage(String receiverId) async {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        receiverId,
        _messageController.text.trim(),
      );

      _messageController.clear();

      scrollToBottom();
    }
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    settingsOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ValueListenableBuilder<bool>(
                valueListenable: settingsOpen,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      WebProfileBar(
                        openSettings: () {
                          settingsOpen.value = !settingsOpen.value;
                        },
                      ),
                      if (value)
                        WebSettingsScreen()
                      else
                        Column(
                          children: [
                            const WebSearchBar(),
                            ContactsList(),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundImage.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ValueListenableBuilder(
              valueListenable: UtilitiesBox.watchSelectedUser(),
              builder: (context, box, child) {
                if (box.get('selectedUser') != null) {
                  return Column(
                    children: [
                      WebChatAppbar(
                        selectedUserPhoneNumber:
                            box.get('selectedUser')['phone'],
                        selectedUserProfilePic:
                            box.get('selectedUser')['profilePic'],
                      ),
                      Expanded(
                        child: ChatList(
                          receiverId: box.get('selectedUser')['uid'],
                          senderId: _auth.currentUser!.uid,
                          scrollController: _scrollController,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: chatBarMessage,
                          border: Border(
                            top: BorderSide(
                              color: dividerColor,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 15),
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (value) {
                                    sendMessage(
                                      box.get('selectedUser')['uid'],
                                    );

                                    _focusNode.requestFocus();
                                  },
                                  decoration: InputDecoration(
                                    fillColor: searchBarColor,
                                    filled: true,
                                    hintText: 'Type a message',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.only(left: 20),
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _messageController,
                              builder: (context, value, child) {
                                if (_messageController.text.isNotEmpty) {
                                  return IconButton(
                                    onPressed: () {
                                      sendMessage(
                                        box.get('selectedUser')['uid'],
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.grey,
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.mic,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
