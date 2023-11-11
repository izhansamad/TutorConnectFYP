import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/ChatScreen.dart';
import 'package:tutor_connect_app/screens/ProfileScreen.dart';
import 'package:tutor_connect_app/screens/student/HomeScreen.dart';
import 'package:tutor_connect_app/screens/student/TeacherScreen.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherCoursesScreen.dart';
import 'package:tutor_connect_app/utils/Teacher.dart';

import '../../utils/Student.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
  void changePage(int pageIndex) {
    _pageController.jumpToPage(pageIndex);
  }
}

PageController _pageController = new PageController(initialPage: 0);
int _currentIndex = 0;

class _HomeState extends State<Home> {
  List<Widget> _pages = [
    HomeScreen(),
    TeachersScreen(),
    TeacherCoursesScreen(),
    ChatScreen(),
    ProfileScreen()
  ];

  @override
  void initState() {
    _pageController = new PageController(initialPage: 0);
    _currentIndex = 0;
    loadStudentData();
    loadteachersData();
    super.initState();
  }

  Future<void> loadteachersData() async {
    // final studentData = await getStudentFromFirestore();

    final teachersDataProvider =
        Provider.of<AllTeachersDataProvider>(context, listen: false);
    await teachersDataProvider.refreshTeachersData();

    setState(() {});
  }

  Future<void> loadStudentData() async {
    // final studentData = await getStudentFromFirestore();

    final studentDataProvider =
        Provider.of<StudentDataProvider>(context, listen: false);
    await studentDataProvider.refreshStudentData();

    setState(() {});
  }

  Future<Student?> getStudentFromFirestore() async {
    DocumentSnapshot? userDocument = await getCurrentUserDocument();

    if (userDocument != null) {
      return Student.fromDocument(userDocument);
    } else {
      return null;
    }
  }

  Future<DocumentSnapshot?> getCurrentUserDocument() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Reference to the Firestore collection where user data is stored
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('student');

      DocumentSnapshot userDoc = await usersCollection.doc(userUid).get();

      if (userDoc.exists) {
        return userDoc;
      } else {
        return null;
      }
    } catch (error) {
      print("Error fetching user document: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: _pages.map((page) {
            if (page is HomeScreen) {
              // Pass the callback function to HomeScreen
              return HomeScreen(changePage: widget.changePage);
            }
            return page;
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              activeColor: primaryColor,
              inactiveColor: Colors.black,
              textAlign: TextAlign.center,
              title: Text('Home'),
              icon: Icon(Icons.home)),
          BottomNavyBarItem(
              activeColor: primaryColor,
              inactiveColor: Colors.black,
              textAlign: TextAlign.center,
              title: Text('Teachers'),
              icon: Icon(Icons.school)),
          BottomNavyBarItem(
              activeColor: primaryColor,
              inactiveColor: Colors.black,
              textAlign: TextAlign.center,
              title: Text('Courses'),
              icon: Icon(CupertinoIcons.book_fill)),
          BottomNavyBarItem(
              activeColor: primaryColor,
              inactiveColor: Colors.black,
              textAlign: TextAlign.center,
              title: Text('Chats'),
              icon: Icon(CupertinoIcons.chat_bubble_2_fill)),
          BottomNavyBarItem(
              activeColor: primaryColor,
              inactiveColor: Colors.black,
              textAlign: TextAlign.center,
              title: Text('Account'),
              icon: Icon(Icons.manage_accounts_rounded)),
        ],
      ),
    );
  }
}
