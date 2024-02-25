import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/screens/student/CourseDetailScreen.dart';
import 'package:tutor_connect_app/widget/CourseBox.dart';
import 'package:tutor_connect_app/widget/searchBar.dart';

import '../../utils/Course.dart';
import '../../utils/Teacher.dart';
import '../../widget/popular_teacher.dart';
import 'TeacherProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? changePage;
  HomeScreen({Key? key, this.changePage}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  bool loading = false;
  // List<Teacher>? teachersList = [];
  var teachersList;
  List<Course> allCourses = [];
  List<Course> enrolledCourses = [];

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

            allCourses.addAll(teacherCourses);
            print(teacherCourses);
          }
        }
        List<String>? enrolledCourseIds =
            await getEnrolledCourseIds(FirebaseAuth.instance.currentUser!.uid);

        // Filter the courses list to get only the enrolled courses
        enrolledCourses =
            getEnrolledCourses(allCourses, enrolledCourseIds ?? []);
        loading = false;
        setState(() {});

        return allCourses;
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

  @override
  void initState() {
    userName = FirebaseAuth.instance.currentUser!.displayName ?? "";
    getAllCourses();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final teachersDataProvider = Provider.of<AllTeachersDataProvider>(context);
    teachersList = teachersDataProvider.teachersData;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? userName}",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                ),
              ),
              Text(
                "Lets Find Your Tutor",
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   Container(
        //     padding: EdgeInsets.only(right: 17),
        //     child: badges.Badge(
        //       position: BadgePosition.topEnd(top: -9, end: -7),
        //       badgeContent: Text(
        //         '2',
        //         style: TextStyle(color: Colors.white),
        //       ),
        //       child: Icon(
        //         Icons.notifications_sharp,
        //         color: primaryColor,
        //       ),
        //     ),
        //   )
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: CustomSearch(),
                    ),
                    // SizedBox(height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       "Subjects",
                    //       style: TextStyle(
                    //           fontSize: 20, fontWeight: FontWeight.w700),
                    //     ),
                    //     Text(
                    //       "View All",
                    //       style: TextStyle(
                    //         fontSize: 13,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 10),
                    // SingleChildScrollView(
                    //   padding: EdgeInsets.only(bottom: 5),
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       CategoryBox(
                    //         title: "Maths",
                    //         icon: Icons.calculate_outlined,
                    //         color: Colors.red,
                    //       ),
                    //       CategoryBox(
                    //         title: "Chemistry",
                    //         icon: Icons.science_outlined,
                    //         color: Colors.blue,
                    //       ),
                    //       CategoryBox(
                    //         title: "Biology",
                    //         icon: Icons.monitor_heart_outlined,
                    //         color: Colors.purple,
                    //       ),
                    //       CategoryBox(
                    //         title: "English",
                    //         icon: Icons.abc,
                    //         color: Colors.green,
                    //       ),
                    //       CategoryBox(
                    //         title: "Computer",
                    //         icon: Icons.computer,
                    //         color: Colors.orange,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Popular Teachers",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (builder)=> TeachersScreen()));
                            widget.changePage!(1);
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 5),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (teachersList != null)
                            for (Teacher teacher in teachersList!)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              TeacherProfileScreen(
                                                teacher: teacher,
                                              )));
                                },
                                child: PopularTeacher(
                                  teacher: teacher,
                                ),
                              ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Popular Courses",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 5),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (Course course in allCourses)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CourseDetailScreen(
                                              course: course,
                                            )));
                              },
                              child: CourseBoxHomeScreen(
                                course: course,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Enrolled Courses",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 5),
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          for (Course course in enrolledCourses)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CourseDetailScreen(
                                              course: course,
                                            )));
                              },
                              child: CourseBoxHomeScreen(
                                course: course,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>?> getEnrolledCourseIds(String studentId) async {
    List<String>? enrolledCourseIds;

    try {
      final enrollmentCollection =
          FirebaseFirestore.instance.collection('enrollments');

      QuerySnapshot enrollmentSnapshot = await enrollmentCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      // Convert dynamic elements to strings using map and cast
      enrolledCourseIds = enrollmentSnapshot.docs
          .map((doc) => doc['courseId'] as String)
          .toList();
    } catch (e) {
      print('Error getting enrolled course IDs: $e');
      // Handle error as needed
    }

    return enrolledCourseIds;
  }

  List<Course> getEnrolledCourses(
      List<Course> allCourses, List<String> enrolledCourseIds) {
    // Filter the courses list to get only the enrolled courses
    List<Course> enrolledCourses = allCourses.where((course) {
      return enrolledCourseIds.contains(course.courseId);
    }).toList();

    return enrolledCourses;
  }
}
