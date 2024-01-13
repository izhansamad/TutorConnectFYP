import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/screens/SpashScreen.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';
import 'package:tutor_connect_app/utils/Student.dart';
import 'package:tutor_connect_app/utils/Teacher.dart';
import 'package:tutor_connect_app/utils/chat_provider.dart';
import 'package:tutor_connect_app/utils/size_confige.dart';

import 'firebase_options.dart';

class UserData {
  final Student studentData;
  final Teacher teacherData;

  UserData({required this.studentData, required this.teacherData});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51OY6sbG8J4zJltRhGT6uAdeTXvUS4T5d0a8L0RNHzPIB8ozVwULdZG262R6kfWqYec5oEP2Uxxfyog7O6OkNiKOm00dxAQaVfj';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PrefsManager().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StudentDataProvider()),
        ChangeNotifierProvider(create: (context) => TeacherDataProvider()),
        ChangeNotifierProvider(create: (context) => AllTeachersDataProvider()),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tutor Connect',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Builder(builder: (context) {
          SizeConfig.initSize(context);
          return SplashScreen();
        }));
  }
}
