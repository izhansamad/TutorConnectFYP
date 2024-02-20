import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/LoginScreen.dart';
import 'package:tutor_connect_app/screens/student/Home.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHome.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  void initState() {
    super.initState();
    bool isTeacher = PrefsManager().getBool('isTeacher');
    _timer = Timer(const Duration(seconds: 1), () {
      FirebaseAuth.instance.currentUser == null
          ? Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen(),
              ),
            )
          : isTeacher
              ? Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (builder) => TeacherHome()))
              : Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (builder) => Home()));
    });
  }

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // void registerNotification() {
  //   firebaseMessaging.requestPermission();
  //
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('onMessage: $message');
  //     if (message.notification != null) {
  //       showNotification(message.notification!);
  //     }
  //     return;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.school, size: 60, color: Colors.black),
                // SizedBox(height: 25),
                // Text(
                //   "Tutor Connect",
                //   style: TextStyle(
                //       fontSize: 28,
                //       fontWeight: FontWeight.w700,
                //       color: Colors.black),
                // ),
                // Text(
                //   "Education, Simplified",
                //   style: TextStyle(
                //     color: Colors.blueGrey[700],
                //     fontSize: 14,
                //   ),
                // ),
                Image.asset(
                  "assets/image/logo.png",
                  width: 230,
                )
              ],
            ),
          ),
          Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                  child: CircularProgressIndicator(
                color: primaryColor,
              )))
        ]),
      ),
    );
  }
}
