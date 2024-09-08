import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';

class WebProfileBar extends StatelessWidget {
  final void Function()? openSettings;

  const WebProfileBar({super.key, required this.openSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.077,
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: dividerColor,
          ),
        ),
        color: webAppBarColor,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            // backgroundImage: NetworkImage(_auth.currentUser.photoURL),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.comment, color: Colors.grey)),
          IconButton(
              onPressed: openSettings,
              icon: const Icon(Icons.more_vert, color: Colors.grey)),
        ],
      ),
    );
  }
}
