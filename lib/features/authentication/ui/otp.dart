import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/features/authentication/cubit/auth_cubit.dart';

import '../../../colors.dart';

class OtpScreen extends StatefulWidget {
  final String? verificationId;
  final ConfirmationResult? confirmationResult;

  const OtpScreen({super.key, this.verificationId, this.confirmationResult});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();


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
            const Text('Enter the OTP sent to your phone',
                style: TextStyle(fontSize: 20)),
            const Gap(20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(20),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthLoggedInState) {
                  Navigator.pop(context);
                } else if (state is AuthErrorState) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
              builder: (context, state) {
                if (state is AuthLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ElevatedButton(
                  onPressed: () async {
                    if (_otpController.text.isEmpty) {
                      return;
                    }

                    BlocProvider.of<AuthCubit>(context).verifyOTP(
                      _otpController.text,
                      verificationId: widget.verificationId,
                      confirmationResult: widget.confirmationResult,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWeb ? webAppBarColor : appBarColor,
                  ),
                  child: const Text('Verify'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
