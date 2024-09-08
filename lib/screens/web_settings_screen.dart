import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class WebSettingsScreen extends StatelessWidget {
  WebSettingsScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                // backgroundImage: NetworkImage(_auth.currentUser.photoURL),
              ),
              Expanded(
                child: Text(
                  _auth.currentUser!.phoneNumber.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text(
            'Account',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onTap: () {},
          minLeadingWidth: 30,
        ),
        const Divider(
          color: dividerColor,
          indent: 58,
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text(
            'Privacy',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onTap: () {},
          minLeadingWidth: 30,
        ),
        const Divider(
          color: dividerColor,
          indent: 58,
        ),
        ListTile(
          leading: const Icon(Icons.chat),
          title: const Text(
            'Chats',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onTap: () {},
          minLeadingWidth: 30,
        ),
        const Divider(
          color: dividerColor,
          indent: 58,
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onTap: () {},
          minLeadingWidth: 30,
        ),
        const Divider(
          color: dividerColor,
          indent: 58,
        ),
        ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.red,
          ),
          title: const Text(
            'Log out',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          onTap: () {},
          minLeadingWidth: 30,
        ),
        const Divider(
          color: dividerColor,
          indent: 58,
        ),
      ],
    );
  }
}
