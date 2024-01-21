import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_connect_app/screens/student/ShowModuleDetails.dart';
import 'package:tutor_connect_app/screens/teacher/AddCourseScreen.dart';
import 'package:tutor_connect_app/screens/teacher/AddModulesScreen.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';

import '../../core/colors.dart';
import '../../utils/Course.dart';
import '../../utils/Teacher.dart';
import '../../widget/avatar_image.dart';
import '../../widget/mybutton.dart';
import '../../widget/popular_teacher.dart';
import '../../widget/teacher_info_box.dart';
import 'TeacherProfileScreen.dart';

class CourseDetailScreen extends StatefulWidget {
  CourseDetailScreen({super.key, required this.course});
  Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Teacher? teacherData;
  bool isEnrolled = false;
  List<Map<String, dynamic>> customFields = [];
  List<Module> modules = [];
  Map<String, dynamic>? paymentIntentData;
  List<String> completedModules = [];
  List<String> allModulesIds = [];

  @override
  void initState() {
    getTeacherInfo(widget.course.teacherId);
    getModules();
    checkEnrollmentAndShowModules(
        FirebaseAuth.instance.currentUser?.uid ?? "", widget.course.courseId);
    super.initState();
  }

  void getModules() async {
    try {
      final modulesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.teacherId)
          .collection("teacherCourses")
          .doc(widget.course.courseId)
          .collection('modules');

      QuerySnapshot querySnapshot = await modulesCollection.get();

      modules = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        allModulesIds.add(data['moduleId']);
        return Module(
          // Map the fields according to your Module class structure
          moduleId: data['moduleId'],
          moduleName: data['moduleName'],
          moduleDescription: data['moduleDescription'],
          materials: (data['materials'] as List<dynamic>).map((material) {
            // Map the fields according to your CourseMaterial class structure
            return CourseMaterial(
              materialType: material['materialType'],
              materialUrl: material['materialUrl'],
              materialOrder: material['materialOrder'],
              materialName: material['materialName'] ?? "",
            );
          }).toList(),
        );
      }).toList();
      print("Modules: $modules");
      setState(() {});
    } catch (e) {
      print('Error getting modules data from Firestore: $e');
      // Handle error as needed
    }
  }

  double calculateCourseProgress(
      List<String> completedModuleIds, List<String> allModuleIds) {
    // Filter out completed module IDs that are not in the list of all module IDs
    List<String> validCompletedModuleIds =
        completedModuleIds.where((id) => allModuleIds.contains(id)).toList();

    double progress = validCompletedModuleIds.length / allModuleIds.length;

    return progress;
  }

  void getTeacherInfo(String teacherDocId) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('teacher');
    DocumentSnapshot userDoc = await usersCollection.doc(teacherDocId).get();
    if (userDoc.exists) {
      teacherData = Teacher.fromDocument(userDoc);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    customFields = widget.course.customFields ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AvatarImage(
                height: 170,
                width: 400,
                course.courseImage == ""
                    ? 'https://blogassets.leverageedu.com/blog/wp-content/uploads/2019/10/23170101/List-of-Professional-Courses-after-Graduation.gif'
                    : course.courseImage,
                radius: 5,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(course.courseName,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  course.courseDesc,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Objective",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(course.courseObj,
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < customFields.length; i++)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customFields[i]['heading'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(customFields[i]['value'],
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TeacherInfoBox(
                  value: course.courseDuration,
                  info: "Duration",
                  icon: Icons.timelapse,
                  color: Colors.blue,
                ),
                TeacherInfoBox(
                  value: course.courseFee,
                  info: "Fee",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Instructor",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            if (teacherData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => TeacherProfileScreen(
                                  teacher: teacherData!,
                                )));
                  },
                  child: PopularTeacher(
                    teacher: teacherData!,
                  ),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Course Progress",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: GFProgressBar(
                percentage:
                    calculateCourseProgress(completedModules, allModulesIds),
                lineHeight: 20,
                alignment: MainAxisAlignment.spaceBetween,
                child: Text(
                  "${(calculateCourseProgress(completedModules, allModulesIds) * 100)}%",
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.check_circle, color: GFColors.SUCCESS),
                ),
                backgroundColor: Colors.black26,
                progressBarColor: primaryColor,
              ),
            ),
            if ((PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY) &&
                    modules.isNotEmpty) ||
                isEnrolled)
              // Inside your CourseDetailScreen
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Modules",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Column(
                    children: modules.map((module) {
                      return GestureDetector(
                        onTap: () {
                          if (isEnrolled) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => ShowModuleDetail(
                                  module: module,
                                  courseId: widget.course.courseId,
                                  isCompleted: completedModules
                                      .contains(module.moduleId),
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => AddModulesScreen(
                                  course: course,
                                  module: module,
                                ),
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          leading: Icon(Icons.view_module),
                          title: Text(module.moduleName),
                          subtitle: Text(module.moduleDescription),
                          trailing: isEnrolled
                              ? completedModules.contains(module.moduleId)
                                  ? Text(
                                      "Completed",
                                      style: TextStyle(
                                          color: Colors.green.shade800),
                                    )
                                  : Text(
                                      "In-Progress",
                                      style:
                                          TextStyle(color: Colors.red.shade800),
                                    )
                              : SizedBox(),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            if (PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY))
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: MyButton(
                    disableButton: false,
                    bgColor: primaryColor,
                    title: "Add Modules",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => AddModulesScreen(
                                    course: course,
                                  )));
                    }),
              ),
            PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY)
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: MyButton(
                        disableButton: false,
                        bgColor: primaryColor,
                        title: "Edit Course",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => AddCourseScreen(
                                        course: course,
                                      )));
                        }),
                  )
                : isEnrolled
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        child: MyButton(
                            disableButton: false,
                            bgColor: primaryColor,
                            title: "Enroll Now",
                            onTap: () async {
                              await makePayment(widget.course);

                              // await enrollStudentInCourse(
                              //     FirebaseAuth.instance.currentUser?.uid ?? "",
                              //     widget.course.courseId);
                            }),
                      ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(Course course) async {
    try {
      paymentIntentData = await createPaymentIntent(
          course.courseFee, 'PKR'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  // setupIntentClientSecret: 'Your Secret Key',
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  //applePay: PaymentSheetApplePay.,
                  // googlePay: true,
                  //testEnv: true,
                  customFlow: true,
                  style: ThemeMode.light,
                  // merchantCountryCode: 'US',
                  merchantDisplayName: 'Tutor Connect'))
          .then((value) {});

      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              //       parameters: PresentPaymentSheetParameters(
              // clientSecret: paymentIntentData!['client_secret'],
              // confirmPayment: true,
              // )
              )
          .then((newValue) async {
        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

        await enrollStudentInCourse(
            FirebaseAuth.instance.currentUser?.uid ?? "",
            widget.course.courseId);
        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (int.parse(amount) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51OY6sbG8J4zJltRhQJ8ClHJpPGMX0h2qARbaamnEaI5OgjdGpvCLPTyVGfMAbQKBcJ6meI8szICZZLAF4yRX8yWA00JUMt9PxO',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  Future<void> enrollStudentInCourse(String studentId, String courseId) async {
    try {
      final enrollmentCollection =
          FirebaseFirestore.instance.collection('enrollments');

      // Check if the enrollment already exists
      QuerySnapshot existingEnrollmentSnapshot = await enrollmentCollection
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (existingEnrollmentSnapshot.docs.isEmpty) {
        // Create a new enrollment document
        await enrollmentCollection.add({
          'studentId': studentId,
          'courseId': courseId,
          'enrollmentDate': FieldValue.serverTimestamp(),
        });
        isEnrolled = true;
        setState(() {});
        print('Student enrolled in the course successfully');
      } else {
        print('Student is already enrolled in the course');
      }
    } catch (e) {
      print('Error enrolling student in the course: $e');
      // Handle error as needed
    }
  }

  Future<void> checkEnrollmentAndShowModules(
      String studentUid, String courseId) async {
    try {
      final enrollmentCollection =
          FirebaseFirestore.instance.collection('enrollments');

      QuerySnapshot enrollmentSnapshot = await enrollmentCollection
          .where('studentId', isEqualTo: studentUid)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (enrollmentSnapshot.docs.isNotEmpty) {
        DocumentSnapshot enrollmentDoc = enrollmentSnapshot.docs.first;
        completedModules = List<String>.from(enrollmentDoc['completedModules']);

        print("Completed MODULES: $completedModules");
        isEnrolled = true;
        setState(() {});
        print('User is enrolled in the course');
      } else {
        // User is not enrolled in the course
        print('User is not enrolled in the course');
        // Handle accordingly, e.g., show an error message or redirect to enrollment page
      }
    } catch (e) {
      print('Error checking enrollment: $e');
      // Handle error as needed
    }
  }
}
