import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/components/authentication/ui/otp.dart';
import 'package:whatsapp_clone/main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String? _phoneNumber;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        backgroundColor: isWeb ? webAppBarColor : appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter your phone number',
                style: TextStyle(fontSize: 20)),
            const Gap(20),
            InternationalPhoneNumberInput(
              onInputChanged: (value) {
                _phoneNumber = value.phoneNumber?.trim();
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
                useBottomSheetSafeArea: true,
              ),
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: () async {
                if (kIsWeb) {
                  // Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
                  ConfirmationResult confirmationResult = await FirebaseAuth
                      .instance
                      .signInWithPhoneNumber(_phoneNumber.toString());

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return Otp(
                          confirmationResult: confirmationResult,
                        );
                      },
                    ),
                  );
                } else {
                  FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: _phoneNumber,
                    verificationCompleted: (phoneAuthCredential) {},
                    verificationFailed: (error) {
                      logger.e(error.toString());
                    },
                    codeSent: (verificationId, forceResendingToken) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Otp(verificationId: verificationId);
                          },
                        ),
                      );
                    },
                    codeAutoRetrievalTimeout: (verificationId) {
                      logger.e('Code auto retrieval timed out');
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isWeb ? webAppBarColor : appBarColor,
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
