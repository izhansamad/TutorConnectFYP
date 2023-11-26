import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHome.dart';
import 'package:tutor_connect_app/widget/ConfirmationDialog.dart';
import 'package:tutor_connect_app/widget/mybutton.dart';

import '../../core/colors.dart';
import '../../utils/Course.dart';
import '../../widget/avatar_image.dart';

class AddCourseScreen extends StatefulWidget {
  Course? course;
  AddCourseScreen({super.key, this.course});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();
  TextEditingController courseObjectiveController = TextEditingController();
  TextEditingController courseFeeController = TextEditingController();
  TextEditingController courseDurationController = TextEditingController();
  List<TextEditingController> customFieldHeadingControllers = [];
  List<TextEditingController> customFieldValueControllers = [];
  XFile? _imageFile;
  bool isLoading = false;
  @override
  void initState() {
    final course = widget.course;
    if (course != null) {
      courseNameController.text = course.courseName;
      courseDescriptionController.text = course.courseDesc;
      courseObjectiveController.text = course.courseObj;
      courseFeeController.text = course.courseFee;
      courseDurationController.text = course.courseDuration;
      customFieldHeadingControllers =
          List.generate(course.customFields?.length ?? 0, (index) {
        return TextEditingController(
          text: course.customFields?[index]['heading'] ?? "",
        );
      });
      customFieldValueControllers =
          List.generate(course.customFields?.length ?? 0, (index) {
        return TextEditingController(
          text: course.customFields?[index]['value'] ?? "",
        );
      });
    }
    // final cloudinary = Cloudinary.full(
    //   apiKey: "apiKey",
    //   apiSecret: "apiSecret",
    //   cloudName: "cloudName",
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: widget.course == null
                ? Text("Add Course")
                : Text("Update Course"),
            actions: [
              if (widget.course != null)
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                          title: "Are You Sure?",
                          message: "Do you want to delete this course?",
                          onConfirm: () {
                            deleteCourse();
                          },
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete,
                  ),
                  tooltip: "Delete Course",
                )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textField(
                          controller: courseNameController,
                          keyBordType: TextInputType.name,
                          hintTxt: 'Name',
                          icon: Icons.drive_file_rename_outline,
                          validator: validateRequired),
                      textField(
                          controller: courseDescriptionController,
                          keyBordType: TextInputType.text,
                          hintTxt: 'Description',
                          icon: CupertinoIcons.line_horizontal_3,
                          validator: validateRequired),
                      textField(
                          controller: courseObjectiveController,
                          icon: Icons.emoji_objects,
                          hintTxt: 'Objective',
                          validator: validateRequired),
                      textField(
                          controller: courseDurationController,
                          icon: Icons.timelapse,
                          hintTxt: 'Duration',
                          validator: validateRequired),
                      textField(
                          controller: courseFeeController,
                          keyBordType: TextInputType.number,
                          icon: CupertinoIcons.money_dollar,
                          hintTxt: 'Course Fee',
                          validator: validateRequired),
                      for (int i = 0;
                          i < customFieldHeadingControllers.length;
                          i++)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: textField(
                                    padding: EdgeInsets.fromLTRB(20, 8, 1, 8),
                                    controller:
                                        customFieldHeadingControllers[i],
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
                _imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Center(
                          child: AvatarImage(
                            _imageFile!.path,
                            isFileImage: true,
                            width: 300,
                            height: 150,
                            radius: 10,
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 10),
                widget.course == null
                    ? MyButton(
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          _imageFile = await _picker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {});
                        },
                        title: 'Upload Course Image')
                    : SizedBox(),
                SizedBox(height: 15),
                MyButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      addCourse();
                    }
                  },
                  title: widget.course == null ? "Add Course" : "Update Course",
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black
                .withOpacity(0.5), // Add a semi-transparent overlay.
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  void deleteCourse() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      // Get the existing list of courses
      var existingData = (await userDocRef.get()).data();
      List<Map<String, dynamic>> existingCourses = [];

      if (existingData != null && existingData['courses'] != null) {
        existingCourses = List.from(existingData['courses']);
      }

      bool courseExists = false;
      int existingCourseIndex = -1;

      for (int i = 0; i < existingCourses.length; i++) {
        if (existingCourses[i]['courseName'] == widget.course?.courseName) {
          courseExists = true;
          existingCourseIndex = i;
          break;
        }
      }

      if (courseExists) {
        // Delete the existing course
        existingCourses.removeAt(existingCourseIndex);
        await userDocRef.set({
          'courses': existingCourses,
        });
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Course Deleted")));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => TeacherHome()),
            (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error $e")));
    }
  }

  void addCourse() async {
    setState(() {
      isLoading = true;
    });

    String imageUrl = "";
    if (_imageFile != null) {
      imageUrl = await _uploadImageToFirebaseStorage(_imageFile!);
    }

    await saveCourseToFirestore(
      courseNameController.text,
      courseDescriptionController.text,
      courseObjectiveController.text,
      courseFeeController.text,
      courseDurationController.text,
      imageUrl,
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveCourseToFirestore(
    String courseName,
    String courseDesc,
    String courseObj,
    String courseFee,
    String courseDuration,
    String courseImage,
  ) async {
    List<Map<String, dynamic>> customFields = [];

    for (int i = 0; i < customFieldHeadingControllers.length; i++) {
      String heading = customFieldHeadingControllers[i].text;
      String value = customFieldValueControllers[i].text;

      if (heading.isNotEmpty || value.isNotEmpty) {
        customFields.add({'heading': heading, 'value': value});
      }
    }

    try {
      final teacherUid = FirebaseAuth.instance.currentUser!.uid;
      final teacherCoursesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherUid)
          .collection('teacherCourses');

      // Check if the course already exists
      QuerySnapshot existingCoursesSnapshot = await teacherCoursesCollection
          .where('courseName', isEqualTo: courseName)
          .get();
      bool courseExists = existingCoursesSnapshot.docs.isNotEmpty;

      if (courseExists) {
        // Update the existing course document
        final existingCourseDoc = existingCoursesSnapshot.docs.first;
        await existingCourseDoc.reference.update({
          'courseName': courseName,
          'courseDesc': courseDesc,
          'courseObj': courseObj,
          'courseFee': courseFee,
          'courseDuration': courseDuration,
          'teacherId': teacherUid,
          'customFields': customFields,
        });
      } else {
        final newCourseDocRef = await teacherCoursesCollection.add({
          'courseName': courseName,
          'courseDesc': courseDesc,
          'courseObj': courseObj,
          'courseFee': courseFee,
          'courseDuration': courseDuration,
          'courseImage': courseImage,
          'teacherId': teacherUid,
          'customFields': customFields,
        });

        final courseId = newCourseDocRef.id;
        await newCourseDocRef.update({'courseId': courseId});
      }

      print('Course data saved to Firestore');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Course Saved")));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => TeacherHome()),
        (route) => false,
      );
    } catch (e) {
      print('Error saving Course data to Firestore: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed $e")));
    }
  }

  // Future<void> saveCourseToFirestore(
  //   String courseName,
  //   String courseDesc,
  //   String courseObj,
  //   String courseFee,
  //   String courseDuration,
  //   String courseImage,
  // ) async {
  //   List<Map<String, dynamic>> customFields = [];
  //
  //   for (int i = 0; i < customFieldHeadingControllers.length; i++) {
  //     String heading = customFieldHeadingControllers[i].text;
  //     String value = customFieldValueControllers[i].text;
  //
  //     if (heading.isNotEmpty || value.isNotEmpty) {
  //       customFields.add({'heading': heading, 'value': value});
  //     }
  //   }
  //   try {
  //     final userDocRef = FirebaseFirestore.instance
  //         .collection('courses')
  //         .doc(FirebaseAuth.instance.currentUser!.uid);
  //
  //     // Get the existing list of courses
  //     var existingData = (await userDocRef.get()).data();
  //     List<Map<String, dynamic>> existingCourses = [];
  //
  //     if (existingData != null && existingData['courses'] != null) {
  //       existingCourses = List.from(existingData['courses']);
  //     }
  //     bool courseExists = false;
  //     int existingCourseIndex = -1;
  //
  //     for (int i = 0; i < existingCourses.length; i++) {
  //       if (existingCourses[i]['courseName'] == courseName) {
  //         courseExists = true;
  //         existingCourseIndex = i;
  //         break;
  //       }
  //     }
  //     if (courseExists) {
  //       Map<String, dynamic> currentCourse =
  //           existingCourses[existingCourseIndex];
  //       existingCourses[existingCourseIndex] = {
  //         'courseName': courseName,
  //         'courseDesc': courseDesc,
  //         'courseObj': courseObj,
  //         'courseFee': courseFee,
  //         'courseDuration': courseDuration,
  //         'courseImage': currentCourse['courseImage'],
  //         'teacherId': FirebaseAuth.instance.currentUser!.uid,
  //         'customFields': customFields,
  //       };
  //     } else {
  //       existingCourses.add({
  //         'courseName': courseName,
  //         'courseDesc': courseDesc,
  //         'courseObj': courseObj,
  //         'courseFee': courseFee,
  //         'courseDuration': courseDuration,
  //         'courseImage': courseImage,
  //         'teacherId': FirebaseAuth.instance.currentUser!.uid,
  //         'customFields': customFields,
  //       });
  //     }
  //     // Update the document with the new list of courses
  //     await userDocRef.set({
  //       'courses': existingCourses,
  //     });
  //
  //     print('Course data saved to Firestore');
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("Course Saved")));
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (builder) => TeacherHome()),
  //         (route) => false);
  //   } catch (e) {
  //     print('Error saving Course data to Firestore: $e');
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("Failed $e")));
  //   }
  // }

  Future<String> _uploadImageToFirebaseStorage(XFile imageFile) async {
    String imagePath =
        'images/courses/${courseNameController.text}-${DateTime.now()}.png';
    Reference storageReference =
        FirebaseStorage.instance.ref().child(imagePath);
    UploadTask uploadTask = storageReference.putFile(File(imageFile.path));
    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    print('Image uploaded, URL: $imageUrl');
    return imageUrl;
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget textField({
    required String hintTxt,
    required TextEditingController controller,
    bool isEnabled = true,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyBordType,
    padding = const EdgeInsets.symmetric(
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
          maxLines: null,
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
}
