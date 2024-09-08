import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../colors.dart';
import '../features/authentication/cubit/auth_cubit.dart';

class MobileSettingsScreen extends StatelessWidget {
  MobileSettingsScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
            const Divider(
              color: dividerColor,
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key_outlined),
              title: const Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Security notifications, change number'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Block contacts, disappearing messages'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text(
                'Chats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Theme, wallpapers, chat history'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Message, group & call tones'),
              onTap: () {},
            ),
            const Divider(
              color: dividerColor,
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                BlocProvider.of<AuthCubit>(context).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
