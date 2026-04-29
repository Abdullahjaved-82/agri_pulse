import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const String routeName = '/otp';

  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String email =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We sent a 6-digit code to $email',
              style: const TextStyle(color: kTextLight, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: Icon(Icons.lock_clock_outlined),
              ),
            ),
            TextButton(
              onPressed: _secondsLeft == 0 ? _startTimer : null,
              child: Text(
                _secondsLeft == 0 ? 'Resend OTP' : 'Resend in ${_secondsLeft}s',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ResetPasswordScreen.routeName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                ),
                child: const Text('Verify OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

