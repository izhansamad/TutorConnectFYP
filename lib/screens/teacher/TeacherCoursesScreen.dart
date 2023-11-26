import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/student/CourseDetailScreen.dart';
import 'package:tutor_connect_app/screens/teacher/AddCourseScreen.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';
import 'package:tutor_connect_app/widget/CourseBox.dart';

import '../../utils/Course.dart';
import '../../widget/searchBar.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({Key? key}) : super(key: key);

  @override
  _TeacherCoursesScreenState createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  List<Course> courses = [];
  bool loading = false;
  bool isTeacher = false;

  @override
  void initState() {
    isTeacher = PrefsManager().getBool('isTeacher');
    if (isTeacher) {
      getTeacherCourses();
    } else {
      getAllCourses();
    }
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
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : getBody(),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              tooltip: "Add Course",
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => AddCourseScreen()))
                    .then((_) => setState(() {}));
              },
              backgroundColor: primaryColor,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ))
          : null,
    );
  }

  getBody() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            if (!isTeacher)
              Row(
                children: [
                  Expanded(child: CustomSearch()),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: primaryColor,
                      size: 35,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            if (!isTeacher)
              SizedBox(
                height: 10,
              ),
            courses.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text("No Courses Available"),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (BuildContext context, int index) =>
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              CourseDetailScreen(
                                                  course: courses[index])));
                                },
                                child: CourseBox(course: courses[index]))),
                  ),
          ],
        ));
  }

  Future<List<Course>> getTeacherCourses() async {
    setState(() {
      loading = true;
    });

    var userUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(userUid)
          .collection('teacherCourses')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        courses = querySnapshot.docs
            .map((doc) => Course.fromMap({...doc.data()}))
            .toList();

        setState(() {
          loading = false;
        });

        return courses;
      } else {
        setState(() {
          loading = false;
        });
        return [];
      }
    } catch (e) {
      // Handle errors
      setState(() {
        loading = false;
      });
      print('Error retrieving courses: $e');
      return [];
    }
  }

  // Future<List<Course>> getTeacherCourses() async {
  //   setState(() {
  //     loading = true;
  //   });
  //
  //   var userUid = FirebaseAuth.instance.currentUser!.uid;
  //
  //   try {
  //     var snapshot = await FirebaseFirestore.instance
  //         .collection('courses')
  //         .doc(userUid)
  //         .get();
  //
  //     if (snapshot.exists) {
  //       var data = snapshot.data() as Map<String, dynamic>;
  //       var courseData = data['courses'] as List<dynamic>;
  //
  //       courses =
  //           courseData.map((courseMap) => Course.fromMap(courseMap)).toList();
  //
  //       setState(() {
  //         loading = false;
  //       });
  //
  //       return courses;
  //     } else {
  //       setState(() {
  //         loading = false;
  //       });
  //       return [];
  //     }
  //   } catch (e) {
  //     // Handle errors
  //     setState(() {
  //       loading = false;
  //     });
  //     print('Error retrieving courses: $e');
  //     return [];
  //   }
  // }
  Future<List<Course>> getAllCourses() async {
    setState(() {
      loading = true;
    });

    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var teacherDoc in querySnapshot.docs) {
          var teacherUid = teacherDoc.id;

          var teacherCoursesQuery = await FirebaseFirestore.instance
              .collection('courses')
              .doc(teacherUid)
              .collection('teacherCourses')
              .get();

          if (teacherCoursesQuery.docs.isNotEmpty) {
            var teacherCourses = teacherCoursesQuery.docs
                .map((courseDoc) => Course.fromMap({...courseDoc.data()}))
                .toList();

            courses.addAll(teacherCourses);
            print(teacherCourses);
          }
        }

        loading = false;
        setState(() {});

        return courses;
      } else {
        setState(() {
          loading = false;
        });
        // If no documents or courses are found, return an empty list
        return [];
      }
    } catch (e) {
      // Handle errors
      setState(() {
        loading = false;
      });
      print('Error retrieving teachers and courses: $e');
      return [];
    }
  }

  // Future<List<Course>> getAllCourses() async {
  //   setState(() {
  //     loading = true;
  //   });
  //
  //   try {
  //     var querySnapshot =
  //         await FirebaseFirestore.instance.collection('courses').get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       courses = querySnapshot.docs
  //           .expand((doc) => (doc.data()!['courses'] as List<dynamic>)
  //               .map((courseMap) => Course.fromMap(courseMap)))
  //           .toList();
  //
  //       setState(() {
  //         loading = false;
  //       });
  //
  //       return courses;
  //     } else {
  //       setState(() {
  //         loading = false;
  //       });
  //       // If no documents or courses are found, return an empty list
  //       return [];
  //     }
  //   } catch (e) {
  //     // Handle errors
  //     setState(() {
  //       loading = false;
  //     });
  //     print('Error retrieving courses: $e');
  //     return [];
  //   }
  // }
}
