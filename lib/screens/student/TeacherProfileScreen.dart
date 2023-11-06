import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../data/json.dart';
import '../../widget/avatar_image.dart';
import '../../widget/contact_box.dart';
import '../../widget/mybutton.dart';
import '../../widget/teacher_info_box.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({Key? key}) : super(key: key);

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Teacher's Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: getBody(),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      //   child: MyButton(
      //       disableButton: false,
      //       bgColor: primaryColor,
      //       title: "Connect Tutor",
      //       onTap: () {}),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  getBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Available time 8:00am - 5:00pm",
              style: TextStyle(fontSize: 13, color: Colors.green)),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sir. Adam Zampa",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Computer",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              AvatarImage(
                teachers[0]['image'].toString(),
                radius: 10,
              )
            ],
          ),
          SizedBox(
            height: 18,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "About",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing el, ullamex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(
            height: 25,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ContactBox(
              //   icon: Icons.videocam_rounded,
              //   color: Colors.blue,
              // ),
              ContactBox(
                icon: Icons.call_end,
                color: Colors.green,
              ),
              ContactBox(
                icon: Icons.chat_rounded,
                color: Colors.purple,
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TeacherInfoBox(
                value: "500+",
                info: "Students",
                icon: Icons.groups_rounded,
                color: Colors.green,
              ),
              TeacherInfoBox(
                value: "10 Years",
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
              // TeacherInfoBox(
              //   value: "28+",
              //   info: "Successful OT",
              //   icon: Icons.bloodtype_rounded,
              //   color: Colors.blue,
              // ),
              TeacherInfoBox(
                value: "8+",
                info: "Certificates Achieved",
                icon: Icons.card_membership_rounded,
                color: Colors.orange,
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: MyButton(
                disableButton: false,
                bgColor: primaryColor,
                title: "Connect Tutor",
                onTap: () {}),
          ),
        ],
      ),
    );
  }
}
