import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/screens/create_group_screen.dart';
import 'package:whatsapp_clone/screens/mobile_settings_screen.dart';

import '../widgets/contacts_list.dart';

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.grey),
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    child: Text('New group'),
                    value: 1,
                  ),
                  const PopupMenuItem(
                    child: Text('Settings'),
                    value: 2,
                  ),
                ];
              },
              onSelected: (int value) {
                if (value == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CreateGroupScreen()));
                } else if (value == 2) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MobileSettingsScreen()));
                }
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: tabColor,
            dividerColor: dividerColor,
            indicatorWeight: 3,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'CHATS'),
              Tab(text: 'STATUS'),
              Tab(text: 'CALLS'),
            ],
          ),
        ),
        body: ContactsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: tabColor,
          child: const Icon(Icons.add_comment, color: Colors.white),
        ),
      ),
    );
  }
}
