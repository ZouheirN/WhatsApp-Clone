import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UtilitiesBox {
  static final _utilitiesBox = Hive.box('utilities');

  static void setSelectedUser(String userId, String userPhoneNumber, String userProfilePic) {
    _utilitiesBox.put('selectedUser', {
      'uid': userId,
      'phone': userPhoneNumber,
      'profilePic': userProfilePic,
    });
  }

  static void clearSelectedUser() {
    _utilitiesBox.put('selectedUser', null);
  }

  static Map<String, dynamic>? getSelectedUser() {
    return _utilitiesBox.get('selectedUser');
  }

  static ValueListenable watchSelectedUser() {
    return _utilitiesBox.listenable(keys: ['selectedUser']);
  }
}
