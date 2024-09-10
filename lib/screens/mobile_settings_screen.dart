import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../colors.dart';
import '../features/authentication/cubit/auth_cubit.dart';
import '../l10n/l10n.dart';
import '../utils/utilities_box.dart';

class MobileSettingsScreen extends StatelessWidget {
  MobileSettingsScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
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
              leading: const Icon(Icons.key_outlined),
              title: Text(
                AppLocalizations.of(context)!.account,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context)!.accountDescription),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(
                AppLocalizations.of(context)!.privacy,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context)!.privacyDescription),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: Text(
                AppLocalizations.of(context)!.chats,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context)!.chatsDescription),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(
                AppLocalizations.of(context)!.notifications,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle:
                  Text(AppLocalizations.of(context)!.notificationsDescription),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                AppLocalizations.of(context)!.appLanguage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context)!.language),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return ValueListenableBuilder(
                      valueListenable: UtilitiesBox.watchLanguage(),
                      builder: (context, value, child) {
                        final currentLanguage = UtilitiesBox.getLanguage();

                        return ListView.builder(
                          itemCount: L10n.locals.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: L10n.locals[index].languageCode ==
                                      currentLanguage
                                  ? const Icon(Icons.radio_button_checked)
                                  : const Icon(Icons.radio_button_unchecked),
                              title: Text(L10n.languages[index]),
                              onTap: () {
                                UtilitiesBox.setLanguage(
                                    L10n.locals[index].languageCode);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const Divider(
              color: dividerColor,
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: Text(
                AppLocalizations.of(context)!.signOut,
                style: const TextStyle(
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
