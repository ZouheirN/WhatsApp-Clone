import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/screens/mobile_group_chat_screen.dart';
import 'package:whatsapp_clone/services/chat_service.dart';
import 'package:whatsapp_clone/services/group_chat_service.dart';
import 'package:whatsapp_clone/utils/contacts_box.dart';
import 'package:whatsapp_clone/utils/utilities_box.dart';

class ContactsList extends StatelessWidget {
  ContactsList({super.key});

  final ChatService _chatService = ChatService();
  final GroupChatService _groupChatService = GroupChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: StreamBuilder(
          stream: _groupChatService.getGroupChatsStream(),
          builder: (context, groupSnapshot) {
            if (groupSnapshot.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            }

            if (groupSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final groups = ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: groupSnapshot.data!
                  .map<Widget>(
                      (groupData) => _buildGroupListItem(groupData, context))
                  .toList(),
            );

            return StreamBuilder(
              stream: _chatService.getUsersStream(),
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

                return Column(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 8),
                      children: snapshot.data!
                          .map<Widget>(
                              (userData) => _buildListItem(userData, context))
                          .toList(),
                    ),
                    groups,
                  ],
                );
              },
            );
          }),
    );
  }

  Widget _buildGroupListItem(
      Map<String, dynamic> groupData, BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return MobileGroupChatScreen(
                    groupId: groupData['groupId'],
                    groupName: groupData['groupName'],
                    groupProfilePic: groupData['groupImageUrl'],
                  );
                },
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: groupData['groupImageUrl'] != null
                  ? Image.network(groupData['groupImageUrl'].toString())
                  : const Icon(Icons.group),
            ),
            title: Text(
              groupData['groupName'].toString(),
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Text(
                '',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            trailing: const Text(
              '',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const Divider(
          color: dividerColor,
          indent: 85,
        ),
      ],
    );
  }

  Widget _buildListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData['phone'] != _auth.currentUser!.phoneNumber) {
      return Column(
        children: [
          InkWell(
            onTap: MediaQuery.of(context).size.width > 600
                ? () {
                    final selectedUser = UtilitiesBox.getSelectedUser();

                    if (selectedUser == null ||
                        selectedUser['uid'] != userData['uid']) {
                      UtilitiesBox.setSelectedUser(userData['uid'],
                          userData['phone'], userData['profilePic']);
                    }
                  }
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return MobileChatScreen(
                            receiverPhoneNumber: userData['phone'],
                            receiverId: userData['uid'],
                            receiverProfilePic: userData['profilePic'],
                          );
                        },
                      ),
                    );
                  },
            child: _buildListTile(userData),
          ),
          const Divider(
            color: dividerColor,
            indent: 85,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildListTile(userData) {
    return StreamBuilder(
      stream: _chatService.getLatestMessage(
          _auth.currentUser!.uid, userData['uid']),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userData['profilePic'].toString()),
            ),
            title: Text(
              userData['phone'].toString(),
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Text(
                '',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            trailing: const Text(
              '',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          );
        }

        final latestMessage =
            snapshot.data?.docs.last.data() as Map<String, dynamic>?;

        String message = latestMessage?['message'] ?? '';
        final time = latestMessage?['timestamp'] ?? '';
        String parsedTime = '';
        if (time != '') {
          parsedTime = time.toDate().toString().substring(11, 16);
        }

        if (latestMessage!['type'] == 'file') {
          message = latestMessage['fileName'];
        } else if (latestMessage['type'] == 'image') {
          if (latestMessage['caption'] != null) {
            message = latestMessage['caption'];
          } else {
            message = 'Image';
          }
        } else if (latestMessage['type'] == 'video') {
          message = 'Video';
        } else if (latestMessage['type'] == 'voice') {
          message = 'Voice Message';
        }

        final isNewMessage =
            latestMessage['senderId'] != _auth.currentUser!.uid &&
                !latestMessage['isRead'];

        return ValueListenableBuilder(
          valueListenable: ContactsBox.watchContact(userData['uid']),
          builder: (context, value, child) {
            return ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage(userData['profilePic'].toString()),
              ),
              title: Text(
                ContactsBox.getContactName(userData['uid']) ??
                    userData['phone'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    if (latestMessage['type'] == 'file')
                      const Icon(Icons.description)
                    else if (latestMessage['type'] == 'image')
                      const Icon(Icons.image)
                    else if (latestMessage['type'] == 'video')
                      const Icon(Icons.videocam)
                    else if (latestMessage['type'] == 'voice')
                      const Icon(Icons.mic),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      parsedTime,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isNewMessage)
                    const Column(
                      children: [
                        Gap(5),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                        )
                      ],
                    )
                  else
                    const Gap(10),
                  if (_auth.currentUser!.uid == latestMessage['senderId'])
                    if (latestMessage['isRead'])
                      const Icon(
                        Icons.done_all,
                        color: Colors.grey,
                        size: 20,
                      )
                    else
                      const Icon(
                        Icons.done,
                        color: Colors.grey,
                        size: 20,
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
