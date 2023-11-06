import 'package:badges/badges.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../data/json.dart';
import '../../utils/Teacher.dart';
import '../../widget/avatar_image.dart';
import '../../widget/mybutton.dart';
import '../../widget/teacher_info_box.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Teacher? teacherData;
  int maxLines = 1;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController specialityController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  bool editing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final teacherDataProvider = Provider.of<TeacherDataProvider>(context);
    teacherData = teacherDataProvider.teacherData;
    fullNameController.text = teacherData?.fullName ?? "";
    phoneController.text = teacherData?.phone ?? "";
    qualificationController.text = teacherData?.qualification ?? "";
    experienceController.text = teacherData?.experience ?? "";
    specialityController.text = teacherData?.speciality ?? "";
    aboutController.text = teacherData?.about ?? "";
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? ""}",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                ),
              ),
              Text(
                "Share Knowledge, Build Futures",
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
      body: teacherData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (!editing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Available hours 8:00am - 5:00pm",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.green)),
                          SizedBox(
                            height: 25,
                          ),
                          AvatarImage(
                            height: 100,
                            width: 100,
                            teacherData!.image ??
                                teachers[0]['image'].toString(),
                            radius: 40,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(teacherData!.fullName,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "About",
                              style: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            teacherData!.about,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
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
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
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
                                value: "${teacherData!.speciality}",
                                info: "Speciality",
                                icon: CupertinoIcons.book_fill,
                                color: Colors.blue,
                              ),
                              TeacherInfoBox(
                                value: teacherData!.experience,
                                info: "Experience",
                                icon: Icons.medical_services_rounded,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TeacherInfoBox(
                                value: teacherData!.qualification,
                                info: "Qualification",
                                icon: Icons.card_membership_rounded,
                                color: Colors.orange,
                              ),
                              TeacherInfoBox(
                                value: "1000+",
                                info: "Students",
                                icon: Icons.groups_rounded,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: MyButton(
                                icon: CupertinoIcons.pencil,
                                disableButton: false,
                                bgColor: primaryColor,
                                title: "Edit Profile",
                                onTap: () {
                                  setState(() {
                                    editing = true;
                                  });
                                }),
                          ),
                        ],
                      ),
                    ),
                  if (editing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 8),
                            child: Text(
                              "Personal Info",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              textField(
                                  controller: fullNameController,
                                  keyBordType: TextInputType.name,
                                  hintTxt: 'Full Name',
                                  icon: Icons.person,
                                  isEnabled: editing,
                                  validator: validateRequired),
                              textField(
                                  controller: phoneController,
                                  keyBordType: TextInputType.phone,
                                  hintTxt: 'Phone Number',
                                  icon: Icons.phone,
                                  isEnabled: editing,
                                  validator: validateRequired),
                              textField(
                                  controller: qualificationController,
                                  icon: Icons.school,
                                  hintTxt: 'Qualification',
                                  isEnabled: editing,
                                  validator: validateRequired),
                              textField(
                                  controller: experienceController,
                                  icon: CupertinoIcons.star_circle_fill,
                                  hintTxt: 'Experience',
                                  isEnabled: editing,
                                  validator: validateRequired),
                              textField(
                                  controller: specialityController,
                                  icon: CupertinoIcons.book_fill,
                                  hintTxt: 'Teaching Speciality',
                                  isEnabled: editing,
                                  validator: validateRequired),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 8.0,
                                  ),
                                  child: TextFormField(
                                    maxLines: maxLines,
                                    onChanged: (text) {
                                      int newMaxLines = (text.length / 40)
                                          .ceil(); // 40 is an approximate character count per line
                                      setState(() {
                                        maxLines = newMaxLines;
                                      });
                                    },
                                    controller: aboutController,
                                    validator: validateRequired,
                                    enabled: editing,
                                    decoration: InputDecoration(
                                        labelText: "About",
                                        labelStyle: TextStyle(
                                          color: primaryColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                          ),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.info,
                                          color: editing
                                              ? primaryColor
                                              : Colors.grey,
                                        )),
                                    cursorColor: primaryColor,
                                  ))
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              editing = false;
                            });
                          },
                          child: Text("Cancel"),
                        ),
                        if (editing)
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                updateTeacherProfile();
                              }
                            },
                            child: Text("Update"),
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  void updateTeacherProfile() {
    final updatedFullName = fullNameController.text;
    final updatedPhone = phoneController.text;
    final updatedQualification = qualificationController.text;
    final updatedExperience = experienceController.text;
    final updatedSpeciality = specialityController.text;
    final updatedAbout = aboutController.text;

    // Get updated values for other fields similarly.

    String docId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final teacherRef =
        FirebaseFirestore.instance.collection('teacher').doc(docId);

    teacherRef.update({
      'fullName': updatedFullName,
      'about': updatedAbout,
      'experience': updatedExperience,
      'qualification': updatedQualification,
      'speciality': updatedSpeciality,
      'phoneNumber': updatedPhone
    }).then((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
      setState(() {
        editing = false;
      });
      final teacherDataProvider =
          Provider.of<TeacherDataProvider>(context, listen: false);
      await teacherDataProvider.refreshTeacherData();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $error")),
      );
    });
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}

Widget textField({
  required String hintTxt,
  required TextEditingController controller,
  bool isEnabled = true,
  IconData? icon,
  String? Function(String?)? validator,
  TextInputType? keyBordType,
}) {
  return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        enabled: isEnabled,
        keyboardType: keyBordType,
        decoration: InputDecoration(
            labelText: hintTxt,
            labelStyle: TextStyle(
              color: primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: primaryColor,
              ),
            ),
            suffixIcon: Icon(
              icon,
              color: isEnabled ? primaryColor : Colors.grey,
            )),
        cursorColor: primaryColor,
      ));
}
