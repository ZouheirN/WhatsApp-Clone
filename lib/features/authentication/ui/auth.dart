import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:whatsapp_clone/colors.dart';

import '../cubit/auth_cubit.dart';
import 'otp.dart';

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
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthCodeSentState) {
                  if (state.verificationId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OtpScreen(
                              verificationId: state.verificationId);
                        },
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OtpScreen(
                            confirmationResult: state.confirmationResult,
                          );
                        },
                      ),
                    );
                  }
                }
              },
              builder: (context, state) {
                if (state is AuthLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWeb ? webAppBarColor : appBarColor,
                  ),
                  onPressed: () {
                    BlocProvider.of<AuthCubit>(context)
                        .sendOTP(_phoneNumber.toString());
                  },
                  child: const Text('Next'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
