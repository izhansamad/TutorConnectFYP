import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../utils/Course.dart';
import '../../utils/Teacher.dart';
import '../../widget/avatar_image.dart';
import '../../widget/mybutton.dart';
import '../../widget/popular_teacher.dart';
import '../../widget/teacher_info_box.dart';
import 'TeacherProfileScreen.dart';

class CourseDetailScreen extends StatefulWidget {
  CourseDetailScreen({super.key, required this.course});
  Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Teacher? teacherData;
  @override
  void initState() {
    getTeacherInfo(widget.course.teacherId);
    super.initState();
  }

  void getTeacherInfo(String teacherDocId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('teacher');
    DocumentSnapshot userDoc = await usersCollection.doc(teacherDocId).get();
    if (userDoc.exists) {
      teacherData = Teacher.fromDocument(userDoc);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AvatarImage(
                height: 170,
                width: 400,
                course.courseImage == ""
                    ? 'https://blogassets.leverageedu.com/blog/wp-content/uploads/2019/10/23170101/List-of-Professional-Courses-after-Graduation.gif'
                    : course.courseImage,
                radius: 5,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(course.courseName,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  course.courseDesc,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //   child: Text(
            //     course.courseDesc,
            //     style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            //   ),
            // ),
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
                TeacherInfoBox(
                  value: course.courseDuration,
                  info: "Duration",
                  icon: Icons.timelapse,
                  color: Colors.blue,
                ),
                TeacherInfoBox(
                  value: course.courseFee,
                  info: "Fee",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     TeacherInfoBox(
            //       value: teacher.qualification,
            //       info: "Qualification",
            //       icon: Icons.card_membership_rounded,
            //       color: Colors.orange,
            //     ),
            //     TeacherInfoBox(
            //       value: "1000+",
            //       info: "Students",
            //       icon: Icons.groups_rounded,
            //       color: Colors.green,
            //     ),
            //   ],
            // ),
            // SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Instructor",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            if (teacherData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => TeacherProfileScreen(
                                  teacher: teacherData!,
                                )));
                  },
                  child: PopularTeacher(
                    teacher: teacherData!,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: MyButton(
                  disableButton: false,
                  bgColor: primaryColor,
                  title: "Enroll Now",
                  onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
