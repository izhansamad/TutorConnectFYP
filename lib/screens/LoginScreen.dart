import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/screens/SignUpScreen.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHome.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';
import 'package:tutor_connect_app/widget/main_button.dart';
import 'package:tutor_connect_app/widget/textField.dart';

import '../core/colors.dart';
import '../core/space.dart';
import '../core/text_style.dart';
import 'student/Home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

bool isLoading = false;

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/image/icon_logo.png",
                      width: 130,
                    ),
                    Text(
                      'Welcome to Tutor Connect',
                      style: headline1,
                    ),
                    SpaceVH(height: 5.0),
                    Text(
                      'Please sign in to your account',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    SpaceVH(height: 40.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          textField(
                              controller: userEmail,
                              hintTxt: 'Email',
                              icon: Icons.email,
                              validator: validateRequired),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      controller: userPass,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      obscureText: !isPasswordVisible,
                                      validator: null,
                                      decoration: InputDecoration(
                                        helperText: ' ',
                                        contentPadding:
                                            EdgeInsets.only(bottom: 3),
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle: hintStyle,
                                      ),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                    child: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SpaceVH(height: 10.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ),
                    SpaceVH(height: 50.0),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          MainButton(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await signIn();
                              }
                            },
                            text: 'Sign in',
                            btnColor: primaryColor,
                          ),
                          SpaceVH(height: 20.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SignUpScreen()));
                            },
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey.shade700),
                                ),
                                TextSpan(
                                  text: ' Sign Up',
                                  style: headlineDot.copyWith(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          SpaceVH(
                            height: 10,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black
                .withOpacity(0.5), // Add a semi-transparent overlay.
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail.text,
        password: userPass.text,
      );
      String userType = await getUserTypeFromFirestore(userEmail.text);
      setState(() {
        isLoading = false;
      });
      if (userType == "teacher") {
        PrefsManager().setBool('isTeacher', true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => TeacherHome()),
          (route) => false,
        );
      } else {
        PrefsManager().setBool('isTeacher', false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => Home()),
          (route) => false,
        );
      }
    } catch (error) {
      String errorMessage = "An error occurred.";
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Invalid Email Address";
            break;
          case "user-not-found":
          case "INVALID_LOGIN_CREDENTIALS":
            errorMessage = "Invalid email or password.";
            break;
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.code)));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getUserTypeFromFirestore(String userEmail) async {
    try {
      CollectionReference studentsCollection =
          FirebaseFirestore.instance.collection('student');
      CollectionReference teachersCollection =
          FirebaseFirestore.instance.collection('teacher');

      // Query the "students" collection for the user with the specified email
      QuerySnapshot studentsQuerySnapshot =
          await studentsCollection.where('email', isEqualTo: userEmail).get();

      // Query the "teachers" collection for the user with the specified email
      QuerySnapshot teachersQuerySnapshot =
          await teachersCollection.where('email', isEqualTo: userEmail).get();

      if (studentsQuerySnapshot.docs.isNotEmpty) {
        String? pushToken = await FirebaseMessaging.instance.getToken();
        await studentsCollection
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'pushToken': pushToken});

        return "student";
      } else if (teachersQuerySnapshot.docs.isNotEmpty) {
        String? pushToken = await FirebaseMessaging.instance.getToken();
        await teachersCollection
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'pushToken': pushToken});
        return "teacher";
      } else {
        // User not found in either collection, handle this case as needed (e.g., return a default user type or an error).
        return "unknown"; // or throw an exception
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore queries
      print("Error fetching user type: $error");
      throw error;
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
