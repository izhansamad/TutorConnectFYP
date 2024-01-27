import 'package:cloud_firestore/cloud_firestore.dart';

import 'Course.dart';

class GetFirestore {
  Future<bool> updateCourseStatus(
      String courseId, String teacherId, bool courseStatus) async {
    try {
      final teacherCoursesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherId)
          .collection('teacherCourses');

      // Check if the course already exists
      QuerySnapshot existingCoursesSnapshot = await teacherCoursesCollection
          .where('courseId', isEqualTo: courseId)
          .get();
      bool courseExists = existingCoursesSnapshot.docs.isNotEmpty;
      if (courseExists) {
        existingCoursesSnapshot.docs.first.reference
            .update({'courseStatus': courseStatus});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<Course>> getTeacherCourses(String teacherDocId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherDocId)
          .collection('teacherCourses')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Course> courses = snapshot.docs
            .map((courseDoc) => Course.fromMap(courseDoc.data()))
            .toList();

        return courses;
      } else {
        return [];
      }
    } catch (e) {
      // Handle errors
      print('Error retrieving courses: $e');
      return [];
    }
  }
}
