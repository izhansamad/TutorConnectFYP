import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../utils/Teacher.dart';
import '../../widget/mybutton.dart';

class TeacherEditProfileScreen extends StatefulWidget {
  Teacher teacherData;
  TeacherEditProfileScreen({super.key, required this.teacherData});

  @override
  State<TeacherEditProfileScreen> createState() =>
      _TeacherEditProfileScreenState();
}

class _TeacherEditProfileScreenState extends State<TeacherEditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController specialityController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  List<TextEditingController> customFieldHeadingControllers = [];
  List<TextEditingController> customFieldValueControllers = [];

  @override
  void initState() {
    final teacherData = widget.teacherData;
    fullNameController.text = teacherData.fullName ?? "";
    phoneController.text = teacherData.phone ?? "";
    qualificationController.text = teacherData.qualification ?? "";
    experienceController.text = teacherData.experience ?? "";
    specialityController.text = teacherData.speciality ?? "";
    aboutController.text = teacherData.about ?? "";
    customFieldHeadingControllers =
        List.generate(teacherData.customFields?.length ?? 0, (index) {
      return TextEditingController(
        text: teacherData.customFields?[index]['heading'] ?? "",
      );
    });

    customFieldValueControllers =
        List.generate(teacherData.customFields?.length ?? 0, (index) {
      return TextEditingController(
        text: teacherData.customFields?[index]['value'] ?? "",
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final teacherData = widget.teacherData;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: Text(
                  "Personal Info",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                      validator: validateRequired),
                  textField(
                      controller: phoneController,
                      keyBordType: TextInputType.phone,
                      hintTxt: 'Phone Number',
                      icon: Icons.phone,
                      validator: validateRequired),
                  textField(
                      controller: qualificationController,
                      icon: Icons.school,
                      hintTxt: 'Qualification',
                      validator: validateRequired),
                  textField(
                      controller: experienceController,
                      icon: CupertinoIcons.star_circle_fill,
                      hintTxt: 'Experience',
                      validator: validateRequired),
                  textField(
                      controller: specialityController,
                      icon: CupertinoIcons.book_fill,
                      hintTxt: 'Teaching Speciality',
                      validator: validateRequired),
                  textField(
                      controller: aboutController,
                      icon: CupertinoIcons.info_circle_fill,
                      hintTxt: 'About',
                      validator: validateRequired),
                  for (int i = 0; i < customFieldHeadingControllers.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: textField(
                                padding: EdgeInsets.fromLTRB(20, 8, 1, 8),
                                controller: customFieldHeadingControllers[i],
                                icon: Icons.text_fields,
                                hintTxt: 'Custom Field Heading ${i + 1}',
                                validator: validateRequired,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.only(right: 8),
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  customFieldHeadingControllers.removeAt(i);
                                  customFieldValueControllers.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                        textField(
                          controller: customFieldValueControllers[i],
                          icon: Icons.abc,
                          hintTxt: 'Custom Field Value ${i + 1}',
                          validator: validateRequired,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            MyButton(
              onTap: () {
                customFieldHeadingControllers.add(TextEditingController());
                customFieldValueControllers.add(TextEditingController());
                setState(() {});
              },
              title: "Add Another Field",
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: MyButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    title: ("Cancel"),
                  ),
                ),
                Expanded(
                  child: MyButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        updateTeacherProfile();
                      }
                    },
                    title: ("Update"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void updateTeacherProfile() {
    final updatedFullName = fullNameController.text;
    final updatedPhone = phoneController.text;
    final updatedQualification = qualificationController.text;
    final updatedExperience = experienceController.text;
    final updatedSpeciality = specialityController.text;
    final updatedAbout = aboutController.text;
    List<Map<String, dynamic>> updatedCustomFields = [];

    for (int i = 0; i < customFieldHeadingControllers.length; i++) {
      String heading = customFieldHeadingControllers[i].text;
      String value = customFieldValueControllers[i].text;

      if (heading.isNotEmpty || value.isNotEmpty) {
        updatedCustomFields.add({'heading': heading, 'value': value});
      }
    }
    String docId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final teacherRef =
        FirebaseFirestore.instance.collection('teacher').doc(docId);

    teacherRef.update({
      'fullName': updatedFullName,
      'about': updatedAbout,
      'experience': updatedExperience,
      'qualification': updatedQualification,
      'speciality': updatedSpeciality,
      'phoneNumber': updatedPhone,
      'customFields': updatedCustomFields,
    }).then((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
      final teacherDataProvider =
          Provider.of<TeacherDataProvider>(context, listen: false);
      await teacherDataProvider.refreshTeacherData();
      Navigator.pop(context);
    }).catchError((error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $error")),
      );
    });
  }
}

Widget textField({
  required String hintTxt,
  required TextEditingController controller,
  bool isEnabled = true,
  IconData? icon,
  String? Function(String?)? validator,
  TextInputType? keyBordType,
  EdgeInsets padding = const EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 8.0,
  ),
}) {
  return Padding(
    padding: padding,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.red, // Customize the color for error borders
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: Colors.red, // Customize the color for focused error borders
          ),
        ),
        suffixIcon: Icon(
          icon,
          color: isEnabled ? primaryColor : Colors.grey,
        ),
      ),
      cursorColor: primaryColor,
    ),
  );
}
