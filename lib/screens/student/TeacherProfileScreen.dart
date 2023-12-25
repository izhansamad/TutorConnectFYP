import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/screens/chat_page.dart';

import '../../core/colors.dart';
import '../../data/json.dart';
import '../../utils/Course.dart';
import '../../utils/GetFirestore.dart';
import '../../utils/Teacher.dart';
import '../../widget/CourseBox.dart';
import '../../widget/avatar_image.dart';
import '../../widget/contact_box.dart';
import '../../widget/mybutton.dart';
import '../../widget/teacher_info_box.dart';
import 'CourseDetailScreen.dart';

class TeacherProfileScreen extends StatefulWidget {
  Teacher teacher;
  TeacherProfileScreen({required this.teacher, Key? key}) : super(key: key);

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  List<Course>? courses;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, dynamic>> customFields = [];

  @override
  void initState() {
    getCourses();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    super.initState();
  }

  void getCourses() async {
    GetFirestore getFirestore = GetFirestore();
    courses = await getFirestore.getTeacherCourses(widget.teacher.id);
    setState(() {});
  }

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
    customFields = teacher.customFields ?? [];
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => ChatPage(
                              arguments: ChatPageArguments(
                                  peerAvatar: teacher.image ?? "",
                                  peerId: teacher.id,
                                  peerName: teacher.fullName))));
                },
                child: ContactBox(
                  icon: Icons.chat_rounded,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          for (int i = 0; i < customFields.length; i++)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customFields[i]['heading'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(customFields[i]['value'],
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          SizedBox(
            height: 20,
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
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text("Courses Offered",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          if (courses != null)
            Container(
              height: 250, // Adjust the height as needed
              child: PageView(
                controller: _pageController,
                children: [
                  for (Course course in courses!)
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      CourseDetailScreen(course: course)));
                        },
                        child: CourseBox(course: course)),
                ],
              ),
            ),
          if (courses != null)
            DotsIndicator(
              dotsCount: courses!.length,
              position: _currentPage,
              decorator: DotsDecorator(
                color: Colors.grey,
                activeColor: primaryColor,
              ),
            ),
          if (courses != null) SizedBox(height: 8),
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
