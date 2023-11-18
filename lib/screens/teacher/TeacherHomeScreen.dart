import 'package:badges/badges.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherEditProfileScreen.dart';

import '../../core/colors.dart';
import '../../data/json.dart';
import '../../utils/Teacher.dart';
import '../../widget/avatar_image.dart';
import '../../widget/mybutton.dart';
import '../../widget/teacher_info_box.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Teacher? teacherData;
  List<Map<String, dynamic>> customFields = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? ""}",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                ),
              ),
              Text(
                "Share Knowledge, Build Futures",
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 17),
            child: badges.Badge(
              position: BadgePosition.topEnd(top: -9, end: -7),
              badgeContent: Text(
                '2',
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(
                Icons.notifications_sharp,
                color: primaryColor,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Consumer<TeacherDataProvider>(
          builder: (context, teacherDataProvider, child) {
            if (teacherDataProvider.teacherData == null) {
              return CircularProgressIndicator();
            } else {
              Teacher teacherData = teacherDataProvider.teacherData!;
              customFields = teacherData.customFields ?? [];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Available hours 8:00am - 5:00pm",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.green)),
                          SizedBox(
                            height: 25,
                          ),
                          AvatarImage(
                            height: 100,
                            width: 100,
                            teacherData.image ??
                                teachers[0]['image'].toString(),
                            radius: 40,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(teacherData.fullName,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            teacherData.about,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.orangeAccent,
                              ),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.orangeAccent,
                              ),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.orangeAccent,
                              ),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.orangeAccent,
                              ),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text("4.0 Out of 5.0",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "340 Students review",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          for (int i = 0; i < customFields.length; i++)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customFields[i]['heading'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(customFields[i]['value'],
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14)),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TeacherInfoBox(
                                value: "${teacherData!.speciality}",
                                info: "Speciality",
                                icon: CupertinoIcons.book_fill,
                                color: Colors.blue,
                              ),
                              TeacherInfoBox(
                                value: teacherData.experience,
                                info: "Experience",
                                icon: Icons.medical_services_rounded,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TeacherInfoBox(
                                value: teacherData.qualification,
                                info: "Qualification",
                                icon: Icons.card_membership_rounded,
                                color: Colors.orange,
                              ),
                              TeacherInfoBox(
                                value: "1000+",
                                info: "Students",
                                icon: Icons.groups_rounded,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: MyButton(
                                icon: CupertinoIcons.pencil,
                                disableButton: false,
                                bgColor: primaryColor,
                                title: "Edit Profile",
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              TeacherEditProfileScreen(
                                                  teacherData: teacherData)));
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
