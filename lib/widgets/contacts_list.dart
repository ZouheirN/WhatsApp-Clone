import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/services/chat/chat_service.dart';

class ContactsList extends StatelessWidget {
  ContactsList({super.key});

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: StreamBuilder(
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

          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 8),
            children: snapshot.data!
                .map<Widget>((userData) => _buildListItem(userData, context))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData['phone'] != _auth.currentUser!.phoneNumber) {
      return Column(
        children: [
          InkWell(
            onTap: MediaQuery.of(context).size.width > 600
                ? null
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
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage(userData['profilePic'].toString()),
              ),
              title: Text(
                userData['phone'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  userData['phone'].toString(),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              trailing: Text(
                userData['time'].toString(),
                style: const TextStyle(
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
    } else {
      return Container();
    }
  }
}
