import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/main.dart';

import '../features/authentication/ui/auth.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobileScreenLayout,
    required this.webScreenLayout,
  });

  final Widget mobileScreenLayout;
  final Widget webScreenLayout;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return webScreenLayout;
                } else {
                  return mobileScreenLayout;
                }
              },
            );
          }
        }

        return const AuthScreen();
      },
    );
  }
}
