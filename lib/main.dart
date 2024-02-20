import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51OY6sbG8J4zJltRhGT6uAdeTXvUS4T5d0a8L0RNHzPIB8ozVwULdZG262R6kfWqYec5oEP2Uxxfyog7O6OkNiKOm00dxAQaVfj';
  await Stripe.instance.applySettings();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PrefsManager().init();
  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _displayLocalNotification(message.notification!);

  print('Handling a background message: ${message.messageId}');
}

// Method to handle foreground messages
void _configureFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // Display local notification
      _displayLocalNotification(message.notification!);
    }
  });
}

// Method to display local notification
Future<void> _displayLocalNotification(RemoteNotification notification) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'Tutor Connect',
    'notification',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0, // notification id
    notification.title, // notification title
    notification.body, // notification body
    platformChannelSpecifics,
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
          _configureFirebaseMessaging(); // Initialize Firebase Messaging
          SizeConfig.initSize(context);
          return SplashScreen();
        }));
  }
}
