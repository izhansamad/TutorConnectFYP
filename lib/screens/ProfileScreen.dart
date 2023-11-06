import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/LoginScreen.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';

import '../data/json.dart';
import '../utils/Student.dart';
import '../utils/Teacher.dart';
import '../widget/avatar_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificaionsValue = true;
  bool isTeacher = false;
  var data;
  @override
  void initState() {
    isTeacher = PrefsManager().getBool('isTeacher');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isTeacher) {
      final teacherDataProvider = Provider.of<TeacherDataProvider>(context);
      data = teacherDataProvider.teacherData;
    } else {
      final studentDataProvider = Provider.of<StudentDataProvider>(context);
      data = studentDataProvider.studentData;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Edit',
                style: TextStyle(color: primaryColor),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    AvatarImage(
                      data?.image ?? teachers[1]['image'].toString(),
                      width: 140,
                      height: 140,
                      radius: 100,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "${FirebaseAuth.instance.currentUser?.displayName}",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? "",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text("Notifications"),
                secondary: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_active),
                ), //can this be selected?
                dense: true,
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                value: notificaionsValue,
                onChanged: (bool value) {
                  setState(() {
                    notificaionsValue = value;
                  });
                },
              ),
              SizedBox(height: 10),
              ListTile(
                onTap: () async {
                  _showLogoutConfirmationDialog();
                },
                title: Text("Logout"),
                dense: true,
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.logout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout Confirmation"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(
                "Logout",
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  print("Error signing out: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
