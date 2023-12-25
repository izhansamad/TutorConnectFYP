import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/screens/student/ShowModuleDetails.dart';
import 'package:tutor_connect_app/screens/teacher/AddCourseScreen.dart';
import 'package:tutor_connect_app/screens/teacher/AddModulesScreen.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';

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
  bool isEnrolled = false;
  List<Map<String, dynamic>> customFields = [];
  List<Module> modules = [];
  @override
  void initState() {
    getTeacherInfo(widget.course.teacherId);
    getModules();
    checkEnrollmentAndShowModules(
        FirebaseAuth.instance.currentUser?.uid ?? "", widget.course.courseId);
    super.initState();
  }

  void getModules() async {
    try {
      final modulesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.teacherId)
          .collection("teacherCourses")
          .doc(widget.course.courseId)
          .collection('modules');

      QuerySnapshot querySnapshot = await modulesCollection.get();

      modules = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Module(
          // Map the fields according to your Module class structure
          moduleId: data['moduleId'],
          moduleName: data['moduleName'],
          moduleDescription: data['moduleDescription'],
          materials: (data['materials'] as List<dynamic>).map((material) {
            // Map the fields according to your CourseMaterial class structure
            return CourseMaterial(
              materialType: material['materialType'],
              materialUrl: material['materialUrl'],
              materialOrder: material['materialOrder'],
              materialName: material['materialName'] ?? "",
            );
          }).toList(),
        );
      }).toList();
      print("Modules: $modules");
      setState(() {});
    } catch (e) {
      print('Error getting modules data from Firestore: $e');
      // Handle error as needed
    }
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
    customFields = widget.course.customFields ?? [];
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
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Objective",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(course.courseObj,
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < customFields.length; i++)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customFields[i]['heading'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(customFields[i]['value'],
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
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
            if ((PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY) &&
                    modules.isNotEmpty) ||
                isEnrolled)
              // Inside your CourseDetailScreen
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Modules",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Column(
                    children: modules.map((module) {
                      return GestureDetector(
                        onTap: () {
                          if (isEnrolled) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => ShowModuleDetail(
                                  module: module,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => AddModulesScreen(
                                  course: course,
                                  module: module,
                                ),
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          leading: Icon(Icons.view_module),
                          title: Text(module.moduleName),
                          subtitle: Text(module.moduleDescription),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            if (PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY))
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MyButton(
                    disableButton: false,
                    bgColor: primaryColor,
                    title: "Add Modules",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => AddModulesScreen(
                                    course: course,
                                  )));
                    }),
              ),
            PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY)
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: MyButton(
                        disableButton: false,
                        bgColor: primaryColor,
                        title: "Edit Course",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => AddCourseScreen(
                                        course: course,
                                      )));
                        }),
                  )
                : isEnrolled
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        child: MyButton(
                            disableButton: false,
                            bgColor: primaryColor,
                            title: "Enroll Now",
                            onTap: () async {
                              await enrollStudentInCourse(
                                  FirebaseAuth.instance.currentUser?.uid ?? "",
                                  widget.course.courseId);
                            }),
                      ),
          ],
        ),
      ),
    );
  }

  Future<void> enrollStudentInCourse(String studentId, String courseId) async {
    try {
      final enrollmentCollection =
          FirebaseFirestore.instance.collection('enrollments');

      // Check if the enrollment already exists
      QuerySnapshot existingEnrollmentSnapshot = await enrollmentCollection
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (existingEnrollmentSnapshot.docs.isEmpty) {
        // Create a new enrollment document
        await enrollmentCollection.add({
          'studentId': studentId,
          'courseId': courseId,
          'enrollmentDate': FieldValue.serverTimestamp(),
        });
        isEnrolled = true;
        setState(() {});
        print('Student enrolled in the course successfully');
      } else {
        print('Student is already enrolled in the course');
      }
    } catch (e) {
      print('Error enrolling student in the course: $e');
      // Handle error as needed
    }
  }

  Future<void> checkEnrollmentAndShowModules(
      String studentUid, String courseId) async {
    try {
      final enrollmentCollection =
          FirebaseFirestore.instance.collection('enrollments');

      QuerySnapshot enrollmentSnapshot = await enrollmentCollection
          .where('studentId', isEqualTo: studentUid)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (enrollmentSnapshot.docs.isNotEmpty) {
        // User is enrolled in the course, show modules
        // showCourseModules(courseId);
        isEnrolled = true;
        setState(() {});
        print('User is enrolled in the course');
      } else {
        // User is not enrolled in the course
        print('User is not enrolled in the course');
        // Handle accordingly, e.g., show an error message or redirect to enrollment page
      }
    } catch (e) {
      print('Error checking enrollment: $e');
      // Handle error as needed
    }
  }
}
