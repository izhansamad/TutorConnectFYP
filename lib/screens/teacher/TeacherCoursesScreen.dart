import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/teacher/AddCourseScreen.dart';

import '../../utils/Course.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({Key? key}) : super(key: key);

  @override
  _TeacherCoursesScreenState createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  @override
  void initState() {
    getCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Courses",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
          tooltip: "Add Course",
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => AddCourseScreen()));
          },
          backgroundColor: primaryColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
          )),
    );
  }

  getBody() {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(children: [
              Container(
                child: Center(
                  child: Text("No Courses Available"),
                ),
              ),
            ])));
  }

  Future<List<Course>> getCourses() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Get courses data from Firestore
      var snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(userUid)
          .get();

      if (snapshot.exists) {
        // If the document exists, parse the course data into a List<Course>
        List<Course> courses = [Course.fromDocument(snapshot)];

        print(courses[0].courseName);
        return courses;
      } else {
        // If the document doesn't exist, return an empty list
        return [];
      }
    } catch (e) {
      // Handle errors
      print('Error retrieving courses: $e');
      return [];
    }
  }
}
