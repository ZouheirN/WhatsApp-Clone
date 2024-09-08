import 'package:flutter/material.dart';

import '../screens/mobile_screen_layout.dart';
import '../screens/web_screen_layout.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const WebScreenLayout();
        } else {
          return const MobileScreenLayout();
        }
      },
    );
  }
}
