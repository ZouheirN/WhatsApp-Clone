import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/services/group_chat_service.dart';
import 'package:whatsapp_clone/utils/contacts_box.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  final Map contacts = ContactsBox.getAllContacts();
  final List<String> selectedMembers = [];

  final GroupChatService _groupChatService = GroupChatService();

  bool isLoading = false;

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty || selectedMembers.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await _groupChatService.createGroupChat(groupName, null, selectedMembers);

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // todo picture
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
              ),
            ),
            const Gap(16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Members',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: contacts.keys.map((userId) {
                final contact = contacts[userId];
                return ListTile(
                  title: Text(contact['name']),
                  leading: const CircleAvatar(
                      // todo add profile picture
                      ),
                  trailing: selectedMembers.contains(userId)
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    if (selectedMembers.contains(userId)) {
                      selectedMembers.remove(userId);
                    } else {
                      selectedMembers.add(userId);
                    }
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const Gap(16),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: _createGroup,
                    child: const Text('Create Group'),
                  ),
          ],
        ),
      ),
    );
  }
}
