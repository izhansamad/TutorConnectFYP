import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../widget/avatar_image.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

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
  XFile? _imageFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Add Course"),
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
                          keyBordType: TextInputType.phone,
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
                          icon: CupertinoIcons.money_dollar,
                          hintTxt: 'Course Fee',
                          validator: validateRequired),
                      _imageFile != null
                          ? Center(
                              child: AvatarImage(
                                _imageFile!.path,
                                isFileImage: true,
                                width: 300,
                                height: 150,
                                radius: 10,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      _imageFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    child: Text('Upload Course Image')),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addCourse();
                    }
                  },
                  child: Text("Add Course"),
                ),
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
        imageUrl);
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
      String courseImage) async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.set({
        'courseName': courseName,
        'courseDesc': courseDesc,
        'courseObj': courseObj,
        'courseFee': courseFee,
        'courseDuration': courseDuration,
        'courseImage': courseImage,
      });
      print('Course data saved to Firestore');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Course Saved")));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving Course data to Firestore: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed $e")));
    }
  }

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
}
