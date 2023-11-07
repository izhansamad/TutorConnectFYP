import 'package:badges/badges.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/widget/searchBar.dart';

import '../../utils/Teacher.dart';
import '../../widget/category_box.dart';
import '../../widget/popular_teacher.dart';
import 'TeacherProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? changePage; // Callback function
  HomeScreen({Key? key, this.changePage}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  // List<Teacher>? teachersList = [];
  var teachersList;
  @override
  void initState() {
    userName = FirebaseAuth.instance.currentUser!.displayName ?? "";
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subjects",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
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
                          CategoryBox(
                            title: "Maths",
                            icon: Icons.calculate_outlined,
                            color: Colors.red,
                          ),
                          CategoryBox(
                            title: "Chemistry",
                            icon: Icons.science_outlined,
                            color: Colors.blue,
                          ),
                          CategoryBox(
                            title: "Biology",
                            icon: Icons.monitor_heart_outlined,
                            color: Colors.purple,
                          ),
                          CategoryBox(
                            title: "English",
                            icon: Icons.abc,
                            color: Colors.green,
                          ),
                          CategoryBox(
                            title: "Computer",
                            icon: Icons.computer,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
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
                      // scrollDirection: Axis.vertical,
                      child: Column(
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
                    SizedBox(
                      height: 20,
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
}
