import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';

class WebChatAppbar extends StatelessWidget {
  final String selectedUserPhoneNumber;
  final String selectedUserProfilePic;

  const WebChatAppbar({
    super.key,
    required this.selectedUserPhoneNumber,
    required this.selectedUserProfilePic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.077,
      padding: const EdgeInsets.all(10),
      color: webAppBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(selectedUserProfilePic),
            radius: 30,
          ),
          Text(
            selectedUserPhoneNumber,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
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
