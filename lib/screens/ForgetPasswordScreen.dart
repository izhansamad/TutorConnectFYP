import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text_style.dart';
import '../widget/main_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String verificationId = '';

  Future<void> sendEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          content: Text(
              "Password reset email sent successfully please reset using link"),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send reset email: $error"),
        ),
      );
    }
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: otpController.text,
        newPassword: newPasswordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset successful"),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to reset password: $error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Container(
                height: 60.0,
                padding: EdgeInsets.only(left: 20.0, right: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 105,
                      child: TextFormField(
                        controller: emailController,
                        textAlignVertical: TextAlignVertical.center,
                        validator: null,
                        decoration: InputDecoration(
                          helperText: ' ',
                          contentPadding: EdgeInsets.only(bottom: 3),
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle: hintStyle,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.email,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: MainButton(
                onTap: () async {
                  if (emailController.text.isNotEmpty) {
                    await sendEmail();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Email is required"),
                      ),
                    );
                  }
                },
                text: 'Send Email',
                btnColor: primaryColor,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 20.0,
            //     vertical: 8.0,
            //   ),
            //   child: TextFormField(
            //     controller: otpController,
            //     textAlignVertical: TextAlignVertical.center,
            //     decoration: InputDecoration(
            //       labelText: 'Enter OTP',
            //       hintText: 'Enter the OTP received in your email',
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 20.0,
            //     vertical: 8.0,
            //   ),
            //   child: TextFormField(
            //     controller: newPasswordController,
            //     obscureText: true,
            //     textAlignVertical: TextAlignVertical.center,
            //     decoration: InputDecoration(
            //       labelText: 'New Password',
            //       hintText: 'Enter your new password',
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 20.0,
            //     vertical: 8.0,
            //   ),
            //   child: TextFormField(
            //     controller: confirmPasswordController,
            //     obscureText: true,
            //     textAlignVertical: TextAlignVertical.center,
            //     decoration: InputDecoration(
            //       labelText: 'Confirm New Password',
            //       hintText: 'Re-enter your new password',
            //     ),
            //   ),
            // ),
            // MainButton(
            //   onTap: () async {
            //     if (otpController.text.isNotEmpty &&
            //         newPasswordController.text.isNotEmpty &&
            //         confirmPasswordController.text.isNotEmpty) {
            //       if (newPasswordController.text ==
            //           confirmPasswordController.text) {
            //         await resetPassword();
            //       } else {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             content: Text("Passwords do not match"),
            //           ),
            //         );
            //       }
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text("All fields are required"),
            //         ),
            //       );
            //     }
            //   },
            //   text: 'Reset Password',
            //   btnColor: primaryColor,
            // ),
          ],
        ),
      ),
    );
  }
}
