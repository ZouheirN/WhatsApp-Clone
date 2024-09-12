import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

class ContactsBox {
  static final _contactsBox = Hive.box('contacts');

  static void addContact(String userId, String name) {
    _contactsBox.put(userId, {
      'name': name,
    });
  }

  static void removeContact(String userId) {
    _contactsBox.delete(userId);
  }

  static String? getContactName(String userId) {
    final contact = _contactsBox.get(userId);
    if (contact != null) {
      return contact['name'];
    }
    return null;
  }

  static ValueListenable watchContact(String userId) {
    return _contactsBox.listenable(keys: [userId]);
  }

  static Map getAllContacts() {
    final contacts = _contactsBox.toMap();
    return contacts;
  }
}
