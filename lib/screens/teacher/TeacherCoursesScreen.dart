import 'package:flutter/material.dart';
import 'package:tutor_connect_app/core/colors.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({Key? key}) : super(key: key);

  @override
  _TeacherCoursesScreenState createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
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
          onPressed: () {},
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                child: Center(
                  child: Text("No Courses Available"),
                ),
              ),
            ])));
  }
}
