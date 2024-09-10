import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/features/authentication/cubit/auth_cubit.dart';
import 'package:whatsapp_clone/l10n/l10n.dart';
import 'package:whatsapp_clone/utils/home_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:whatsapp_clone/utils/utilities_box.dart';

import 'firebase_options.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.openBox('utilities').then(
    (value) {
      value.put('selectedUser', null);
    },
  );

  await Hive.openBox('downloadedFiles');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: ValueListenableBuilder(
        valueListenable: UtilitiesBox.watchLanguage(),
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: L10n.locals,
            locale: Locale(UtilitiesBox.getLanguage()),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: backgroundColor,
            ),
            home: const HomeBuilder(),
          );
        },
      ),
    );
  }
}
