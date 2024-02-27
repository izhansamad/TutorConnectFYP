import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHome.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';
import 'package:tutor_connect_app/widget/avatar_image.dart';
import 'package:tutor_connect_app/widget/textField.dart';

import '../core/colors.dart';
import '../core/space.dart';
import '../core/text_style.dart';
import '../widget/main_button.dart';
import '../widget/mybutton.dart';
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
  List<TextEditingController> customFieldHeadingControllers = [];
  List<TextEditingController> customFieldValueControllers = [];
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
                              context: context,
                              controller: fullNameController,
                              keyBordType: TextInputType.name,
                              hintTxt: 'Full Name',
                              icon: Icons.person,
                              validator: validateRequired),
                          textField(
                              context: context,
                              controller: emailController,
                              keyBordType: TextInputType.emailAddress,
                              hintTxt: 'Email Address',
                              icon: Icons.email,
                              validator: validateRequired),
                          textField(
                              context: context,
                              controller: phoneController,
                              keyBordType: TextInputType.phone,
                              hintTxt: 'Phone Number',
                              icon: Icons.phone,
                              validator: validateRequired),
                          textField(
                              context: context,
                              controller: passController,
                              isObs: true,
                              hintTxt: 'Password',
                              icon: Icons.visibility_off,
                              validator: validatePassword),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                context: context,
                                controller: qualificationController,
                                icon: Icons.school,
                                hintTxt: 'Qualification',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                context: context,
                                controller: experienceController,
                                icon: CupertinoIcons.star_circle_fill,
                                hintTxt: 'Experience',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                context: context,
                                controller: specialityController,
                                icon: CupertinoIcons.book_fill,
                                hintTxt: 'Teaching Speciality',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          Visibility(
                            visible: isTeacher,
                            child: textField(
                                context: context,
                                controller: aboutController,
                                icon: CupertinoIcons.info_circle_fill,
                                hintTxt: 'About',
                                validator: isTeacher ? validateRequired : null),
                          ),
                          for (int i = 0;
                              i < customFieldHeadingControllers.length;
                              i++)
                            Visibility(
                              visible: isTeacher,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      textField(
                                        isCustomField: true,
                                        context: context,
                                        controller:
                                            customFieldHeadingControllers[i],
                                        icon: Icons.text_fields,
                                        hintTxt:
                                            'Custom Field Heading ${i + 1}',
                                        validator: validateRequired,
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.only(right: 8),
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            customFieldHeadingControllers
                                                .removeAt(i);
                                            customFieldValueControllers
                                                .removeAt(i);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  textField(
                                    context: context,
                                    controller: customFieldValueControllers[i],
                                    icon: Icons.abc,
                                    hintTxt: 'Custom Field Value ${i + 1}',
                                    validator: validateRequired,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 10),
                          Visibility(
                            visible: isTeacher,
                            child: MyButton(
                              onTap: () {
                                customFieldHeadingControllers
                                    .add(TextEditingController());
                                customFieldValueControllers
                                    .add(TextEditingController());
                                setState(() {});
                              },
                              title: "Add Another Field",
                            ),
                          ),
                          Visibility(
                              visible: isTeacher,
                              child: SizedBox(
                                height: 15,
                              )),
                          _imageFile != null
                              ? AvatarImage(
                                  _imageFile!.path,
                                  isFileImage: true,
                                  width: 150,
                                  height: 150,
                                  radius: 100,
                                )
                              : Container(),
                          MyButton(
                              onTap: () async {
                                final ImagePicker _picker = ImagePicker();
                                _imageFile = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {});
                              },
                              title: ('Upload Image'))
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
      String imagePath = 'images/${user.uid}/profile.png';
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
      String? pushToken = await FirebaseMessaging.instance.getToken();
      final userDocRef = FirebaseFirestore.instance
          .collection('student')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.set({
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
        'image': image,
        'pushToken': pushToken
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
    List<Map<String, dynamic>> updatedCustomFields = [];
    for (int i = 0; i < customFieldHeadingControllers.length; i++) {
      String heading = customFieldHeadingControllers[i].text;
      String value = customFieldValueControllers[i].text;

      if (heading.isNotEmpty || value.isNotEmpty) {
        updatedCustomFields.add({'heading': heading, 'value': value});
      }
    }
    try {
      String? pushToken = await FirebaseMessaging.instance.getToken();

      final userDocRef = FirebaseFirestore.instance
          .collection('teacher')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.set({
        'id': FirebaseAuth.instance.currentUser!.uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
        'qualification': qualification,
        'experience': experience,
        'speciality': speciality,
        'about': about,
        'rating': '5',
        'image': image,
        'pushToken': pushToken,
        'customFields': updatedCustomFields,
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
