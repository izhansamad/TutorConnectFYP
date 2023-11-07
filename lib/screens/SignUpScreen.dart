import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHome.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';
import 'package:tutor_connect_app/widget/textField.dart';

import '../core/colors.dart';
import '../core/space.dart';
import '../core/text_style.dart';
import '../widget/main_button.dart';
import 'student/Home.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  XFile? _imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController specialityController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isTeacher = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SpaceVH(height: 10.0),
                    Text(
                      'Create new account',
                      style: headline1,
                    ),
                    SpaceVH(height: 5.0),
                    Text(
                      'Please fill in the form to continue',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    SpaceVH(height: 20.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          textField(
                              controller: fullNameController,
                              keyBordType: TextInputType.name,
                              hintTxt: 'Full Name',
                              icon: Icons.person,
                              validator: validateRequired),
                          textField(
                              controller: emailController,
                              keyBordType: TextInputType.emailAddress,
                              hintTxt: 'Email Address',
                              icon: Icons.email,
                              validator: validateRequired),
                          textField(
                              controller: phoneController,
                              keyBordType: TextInputType.phone,
                              hintTxt: 'Phone Number',
                              icon: Icons.phone,
                              validator: validateRequired),
                          textField(
                              controller: passController,
                              isObs: true,
                              hintTxt: 'Password',
                              icon: Icons.visibility_off,
                              validator: validatePassword),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                controller: qualificationController,
                                icon: Icons.school,
                                hintTxt: 'Qualification',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                controller: experienceController,
                                icon: CupertinoIcons.star_circle_fill,
                                hintTxt: 'Experience',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                controller: specialityController,
                                icon: CupertinoIcons.book_fill,
                                hintTxt: 'Teaching Speciality',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                controller: aboutController,
                                icon: CupertinoIcons.info_circle_fill,
                                hintTxt: 'About',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          _imageFile != null
                              ? Container(
                                  margin: EdgeInsets.only(top: 15),
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).cardColor,
                                      width: 2.0,
                                    ),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(100.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: FileImage(File(_imageFile!.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(),
                          ElevatedButton(
                              onPressed: () async {
                                final ImagePicker _picker = ImagePicker();
                                _imageFile = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {});
                              },
                              child: Text('Upload Image'))
                        ],
                      ),
                    ),
                    SpaceVH(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Row(
                        children: [
                          Checkbox(
                            activeColor: primaryColor,
                            value: isTeacher,
                            onChanged: (value) {
                              setState(() {
                                isTeacher = value!;
                              });
                            },
                          ),
                          Text(
                            'Sign up as a teacher',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SpaceVH(height: 30.0),
                    MainButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          signUpUser();
                        }
                      },
                      text: 'Sign Up',
                      btnColor: primaryColor,
                    ),
                    SpaceVH(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Already Have an account? ',
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey.shade700),
                          ),
                          TextSpan(
                            text: ' Sign In',
                            style: headlineDot.copyWith(
                              fontSize: 14.0,
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
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

  Future<String> _uploadImageToFirebaseStorage(XFile imageFile) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String imagePath =
          'images/${fullNameController.text}/${DateTime.now()}.png';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(imagePath);
      UploadTask uploadTask = storageReference.putFile(File(imageFile.path));
      String imageUrl = await (await uploadTask).ref.getDownloadURL();
      print('Image uploaded, URL: $imageUrl');
      return imageUrl;
    }
    return "";
  }

  void signUpUser() async {
    setState(() {
      isLoading = true;
    });
    print(emailController.text);
    print(passController.text);
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passController.text)
        .then((value) async {
      User? user = FirebaseAuth.instance.currentUser;
      user!.updateDisplayName(fullNameController.text);
      String imageUrl = "";
      if (_imageFile != null) {
        imageUrl = await _uploadImageToFirebaseStorage(_imageFile!);
      }
      await isTeacher
          ? saveTeacherToFirestore(
              emailController.text,
              fullNameController.text,
              phoneController.text,
              passController.text,
              qualificationController.text,
              experienceController.text,
              specialityController.text,
              aboutController.text,
              imageUrl)
          : saveStudentToFirestore(
              emailController.text,
              fullNameController.text,
              phoneController.text,
              passController.text,
              imageUrl);
      setState(() {
        isLoading = false;
      });
      if (isTeacher) {
        PrefsManager().setBool('isTeacher', true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => TeacherHome()),
          (route) => false,
        );
      } else {
        PrefsManager().setBool('isTeacher', false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => Home()),
          (route) => false,
        );
      }
    }).onError((error, stackTrace) {
      if (error is FirebaseAuthException) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.code)));
      }
      print(error.toString());
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> saveStudentToFirestore(String email, String fullName,
      String phoneNumber, password, image) async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('student')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.set({
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
        'image': image
      });
      print('User data saved to Firestore');
    } catch (e) {
      print('Error saving user data to Firestore: $e');
    }
  }

  Future<void> saveTeacherToFirestore(
      String email,
      String fullName,
      String phoneNumber,
      String password,
      String qualification,
      String experience,
      String speciality,
      String about,
      String image) async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('teacher')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.set({
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
        'qualification': qualification,
        'experience': experience,
        'speciality': speciality,
        'about': about,
        'rating': '5',
        'image': image
      });
      print('Teacher data saved to Firestore');
    } catch (e) {
      print('Error saving Teacher data to Firestore: $e');
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
