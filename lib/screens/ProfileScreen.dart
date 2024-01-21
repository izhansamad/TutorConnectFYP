import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/LoginScreen.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';

import '../utils/Student.dart';
import '../utils/Teacher.dart';
import '../widget/avatar_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificaionsValue = true;
  bool isTeacher = false;
  bool loading = false;
  var data;
  @override
  void initState() {
    isTeacher = PrefsManager().getBool('isTeacher');
    super.initState();
  }

  void _editImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Profile Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Update Image"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  // Implement the logic to update the image
                  _updateImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Remove Image"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  // Implement the logic to remove the image
                  removeImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> removeImage() async {
    setState(() {
      loading = true;
    });

    String imagePath =
        'images/${FirebaseAuth.instance.currentUser!.uid}/profile.png';
    Reference currentStorageReference =
        FirebaseStorage.instance.ref().child(imagePath);

    try {
      // Delete the old profile image from Firebase Storage
      await currentStorageReference.delete();
      print('Old profile image deleted successfully');
    } catch (e) {
      print('Error deleting old profile image: $e');
    }

    // Update the Firestore document with an empty string for the 'image' field
    if (isTeacher) {
      final teacherRef = FirebaseFirestore.instance
          .collection('teacher')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await teacherRef.update({'image': ''});
      final teacherDataProvider = context.read<TeacherDataProvider>();
      teacherDataProvider.refreshTeacherData();
    } else {
      final studentRef = FirebaseFirestore.instance
          .collection('student')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await studentRef.update({'image': ''});
      final studentDataProvider = context.read<StudentDataProvider>();
      studentDataProvider.refreshStudentData();
    }

    setState(() {
      loading = false;
    });
  }

  _updateImage() async {
    setState(() {
      loading = true;
    });
    final ImagePicker _picker = ImagePicker();
    XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    String imagePath =
        'images/${FirebaseAuth.instance.currentUser!.uid}/profile.png';
    Reference currentStorageReference =
        FirebaseStorage.instance.ref().child(imagePath);
    try {
      await currentStorageReference.delete();
      print('Old profile image deleted successfully');
    } catch (e) {
      print('Error deleting old profile image: $e');
    }
    UploadTask uploadTask =
        currentStorageReference.putFile(File(imageFile?.path ?? ""));
    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    if (isTeacher) {
      final teacherRef = FirebaseFirestore.instance
          .collection('teacher')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await teacherRef.update({
        'image': imageUrl,
      });
      final teacherDataProvider = context.read<TeacherDataProvider>();
      teacherDataProvider.refreshTeacherData();
    } else {
      final studentRef = FirebaseFirestore.instance
          .collection('student')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await studentRef.update({
        'image': imageUrl,
      });
      final studentDataProvider = context.read<StudentDataProvider>();
      studentDataProvider.refreshStudentData();
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isTeacher) {
      final teacherDataProvider = Provider.of<TeacherDataProvider>(context);
      data = teacherDataProvider.teacherData;
    } else {
      final studentDataProvider = Provider.of<StudentDataProvider>(context);
      data = studentDataProvider.studentData;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: data == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Stack(
                                children: [
                                  AvatarImage(
                                    data.image == ""
                                        ? "https://thinksport.com.au/wp-content/uploads/2020/01/avatar-.jpg"
                                        : data.image,
                                    width: 140,
                                    height: 140,
                                    radius: 100,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            primaryColor, // Your primary color
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _editImage();
                                        },
                                        color: Colors.white,
                                        iconSize: 25,
                                        padding: EdgeInsets.all(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Text(
                                "${FirebaseAuth.instance.currentUser?.displayName}",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                FirebaseAuth.instance.currentUser?.email ?? "",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SwitchListTile(
                          title: Text("Notifications"),
                          secondary: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.notifications_active),
                          ), //can this be selected?
                          dense: true,
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          value: notificaionsValue,
                          onChanged: (bool value) {
                            setState(() {
                              notificaionsValue = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          onTap: () async {
                            _showLogoutConfirmationDialog();
                          },
                          title: Text("Logout"),
                          dense: true,
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.logout),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (loading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout Confirmation"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(
                "Logout",
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  print("Error signing out: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
