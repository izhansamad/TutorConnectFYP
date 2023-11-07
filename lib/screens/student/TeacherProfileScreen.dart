import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../data/json.dart';
import '../../utils/Teacher.dart';
import '../../widget/avatar_image.dart';
import '../../widget/contact_box.dart';
import '../../widget/mybutton.dart';
import '../../widget/teacher_info_box.dart';

class TeacherProfileScreen extends StatefulWidget {
  Teacher teacher;
  TeacherProfileScreen({required this.teacher, Key? key}) : super(key: key);

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
    );
  }

  getBody() {
    var teacher = widget.teacher;
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Available hours 8:00am - 5:00pm",
              style: TextStyle(fontSize: 14, color: Colors.green)),
          SizedBox(
            height: 25,
          ),
          AvatarImage(
            height: 100,
            width: 100,
            teacher.image ?? teachers[0]['image'].toString(),
            radius: 40,
          ),
          SizedBox(
            height: 15,
          ),
          Text(teacher.fullName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(
            height: 5,
          ),
          Text(
            teacher.about,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
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
                value: teacher.speciality,
                info: "Speciality",
                icon: CupertinoIcons.book_fill,
                color: Colors.blue,
              ),
              TeacherInfoBox(
                value: teacher.experience,
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
                value: teacher.qualification,
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
