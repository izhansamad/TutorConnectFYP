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
import 'package:tutor_connect_app/screens/teacher/TeacherCoursesScreen.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHomeScreen.dart';

import '../../utils/Teacher.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({Key? key}) : super(key: key);

  @override
  _TeacherHomeState createState() => _TeacherHomeState();
  void changePage(int pageIndex) {
    _pageController.jumpToPage(pageIndex);
  }
}

PageController _pageController = new PageController(initialPage: 0);
int _currentIndex = 0;

class _TeacherHomeState extends State<TeacherHome> {
  List<Widget> _pages = [
    TeacherHomeScreen(),
    TeacherCoursesScreen(),
    ChatScreen(),
    ProfileScreen()
    // Container(),
    // Container()
  ];

  @override
  void initState() {
    _pageController = new PageController(initialPage: 0);
    _currentIndex = 0;
    loadTeacherData();
    super.initState();
  }

  Future<void> loadTeacherData() async {
    final teacherData = await getTeacherFromFirestore();

    final teacherDataProvider =
        Provider.of<TeacherDataProvider>(context, listen: false);
    teacherDataProvider.setTeacherData(teacherData!);

    setState(() {});
  }

  Future<Teacher?> getTeacherFromFirestore() async {
    DocumentSnapshot? userDocument = await getCurrentUserDocument();

    if (userDocument != null) {
      // Create a Teacher object from the user document
      return Teacher.fromDocument(userDocument);
    } else {
      // Handle the case when the user document is not found
      return null;
    }
  }

  Future<DocumentSnapshot?> getCurrentUserDocument() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Reference to the Firestore collection where user data is stored
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('teacher');

      // Query for the document with the current user's UID
      DocumentSnapshot userDoc = await usersCollection.doc(userUid).get();

      if (userDoc.exists) {
        return userDoc; // Return the user's document
      } else {
        // User not found, handle this case as needed (e.g., return null or an error).
        return null; // or throw an exception
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore query
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
              title: Text('Courses'),
              icon: Icon(CupertinoIcons.book_fill)),
          BottomNavyBarItem(
              activeColor: primaryColor,
              inactiveColor: Colors.black,
              textAlign: TextAlign.center,
              title: Text('Chats'),
              icon: Icon(CupertinoIcons.chat_bubble_2_fill)),
          // BottomNavyBarItem(
          //     activeColor: primaryColor,
          //     inactiveColor: Colors.black,
          //     title: Text('Booking'),
          //     icon: Icon(Icons.event_note_rounded)),
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
