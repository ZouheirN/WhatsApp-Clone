import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/services/storage_service.dart';

import '../colors.dart';
import '../features/authentication/cubit/auth_cubit.dart';
import '../l10n/l10n.dart';
import '../utils/utilities_box.dart';

class MobileSettingsScreen extends StatefulWidget {
  const MobileSettingsScreen({super.key});

  @override
  State<MobileSettingsScreen> createState() => _MobileSettingsScreenState();
}

class _MobileSettingsScreenState extends State<MobileSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ValueNotifier<bool> isUploading = ValueNotifier(false);

  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            ListTile(
              title: ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                  );

                  if (image == null) return;

                  isUploading.value = true;

                  if (!context.mounted) return;
                  Navigator.of(context).pop();

                  final status = await StorageService()
                      .uploadProfilePicture(File(image.path));

                  isUploading.value = false;

                  if (status) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile picture uploaded successfully'),
                      ),
                    );
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to upload profile picture'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Upload Profile Picture',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: StreamBuilder(
          stream: _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            final profilePicture = snapshot.data!.data()?['profilePic'];

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: isUploading,
                          builder: (context, value, child) {
                            if (value) {
                              return const CircleAvatar(
                                radius: 40,
                                backgroundColor: tabColor,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            return CachedNetworkImage(
                              imageUrl: profilePicture,
                              placeholder: (context, url) => const CircleAvatar(
                                radius: 40,
                                backgroundColor: tabColor,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              imageBuilder: (context, imageProvider) {
                                return CircleAvatar(
                                  radius: 40,
                                  backgroundImage: imageProvider,
                                );
                              },
                            );
                          },
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
                          onPressed: () => _showEditProfileDialog(context),
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
                    subtitle:
                        Text(AppLocalizations.of(context)!.accountDescription),
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
                    subtitle:
                        Text(AppLocalizations.of(context)!.privacyDescription),
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
                    subtitle:
                        Text(AppLocalizations.of(context)!.chatsDescription),
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
                    subtitle: Text(
                        AppLocalizations.of(context)!.notificationsDescription),
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
                              final currentLanguage =
                                  UtilitiesBox.getLanguage();

                              return ListView.builder(
                                itemCount: L10n.locals.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: L10n.locals[index].languageCode ==
                                            currentLanguage
                                        ? const Icon(Icons.radio_button_checked)
                                        : const Icon(
                                            Icons.radio_button_unchecked),
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
            );
          }),
    );
  }
}
