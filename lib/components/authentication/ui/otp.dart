import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../colors.dart';
import '../../../main.dart';

class Otp extends StatefulWidget {
  final String? verificationId;
  final ConfirmationResult? confirmationResult;

  const Otp({super.key, this.verificationId, this.confirmationResult});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        backgroundColor: isWeb ? webAppBarColor : appBarColor,
      ),
      body: Column(
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
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    if (_otpController.text.isEmpty || _isLoading) {
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    if (widget.confirmationResult != null) {
                      // Web
                      try {
                        await widget.confirmationResult!
                            .confirm(_otpController.text);

                        Navigator.pop(context);
                      } catch (e) {
                        logger.e(e.toString());
                      }
                    } else {
                      try {
                        final cred = PhoneAuthProvider.credential(
                            verificationId: widget.verificationId!,
                            smsCode: _otpController.text);

                        await FirebaseAuth.instance.signInWithCredential(cred);
                      } catch (e) {
                        logger.e(e.toString());
                      }
                    }

                    setState(() {
                      _isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWeb ? webAppBarColor : appBarColor,
                  ),
                  child: const Text('Verify'),
                ),
        ],
      ),
    );
  }
}
