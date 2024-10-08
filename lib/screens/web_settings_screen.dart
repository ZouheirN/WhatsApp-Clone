import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../colors.dart';
import '../features/authentication/cubit/auth_cubit.dart';

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
          title:  Text(
            AppLocalizations.of(context)!.account,
            style: const TextStyle(
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
          title:  Text(
            AppLocalizations.of(context)!.privacy,
            style: const TextStyle(
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
          title: Text(
            AppLocalizations.of(context)!.chats,
            style: const TextStyle(
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
          title: Text(
            AppLocalizations.of(context)!.notifications,
            style: const TextStyle(
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
          title: Text(
            AppLocalizations.of(context)!.logOut,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          onTap: () {
            BlocProvider.of<AuthCubit>(context).signOut();
          },
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
