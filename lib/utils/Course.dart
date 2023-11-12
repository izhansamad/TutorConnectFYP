import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String courseName;
  final String courseDesc;
  final String courseObj;
  final String courseFee;
  final String courseDuration;
  final String courseImage;
  final String? courseRating;
  final String teacherId;

  Course({
    required this.courseName,
    required this.courseDesc,
    required this.courseObj,
    required this.courseFee,
    required this.courseDuration,
    required this.courseImage,
    required this.courseRating,
    required this.teacherId,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseName: map['courseName'],
      courseDesc: map['courseDesc'],
      courseObj: map['courseObj'],
      courseFee: map['courseFee'],
      courseDuration: map['courseDuration'],
      courseImage: map['courseImage'],
      courseRating: map['courseRating'],
      teacherId: map['teacherId'],
    );
  }

  factory Course.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Course.fromMap(data);
  }
}
