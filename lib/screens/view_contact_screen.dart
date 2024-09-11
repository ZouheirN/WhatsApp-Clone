import 'package:flutter/material.dart';
import 'package:whatsapp_clone/utils/contacts_box.dart';

class ViewContactScreen extends StatelessWidget {
  final String contactId;
  final String contactPhoneNumber;
  final String contactProfilePic;

  const ViewContactScreen({
    super.key,
    required this.contactId,
    required this.contactPhoneNumber,
    required this.contactProfilePic,
  });

  void _addContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController = TextEditingController();

        if (ContactsBox.getContactName(contactId) != null) {
          nameController.text = ContactsBox.getContactName(contactId).toString();
        }

        return AlertDialog(
          title: const Text('Add Contact'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                ContactsBox.addContact(contactId, nameController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ContactsBox.watchContact(contactId),
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact Info'),
            actions: [
              IconButton(
                onPressed: () => _addContact(context),
                icon: ContactsBox.getContactName(contactId) == null
                    ? const Icon(Icons.person_add_alt_1)
                    : const Icon(Icons.edit),
              ),
              if (ContactsBox.getContactName(contactId) != null)
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Contact'),
                          content: const Text('Are you sure you want to delete this contact?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                ContactsBox.removeContact(contactId);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(contactProfilePic),
                  ),
                  const SizedBox(height: 20),
                  if (ContactsBox.getContactName(contactId) == null)
                    ElevatedButton(
                      onPressed: () => _addContact(context),
                      child: const Text('Add Contact'),
                    )
                  else
                    Text(
                      ContactsBox.getContactName(contactId).toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    contactPhoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
