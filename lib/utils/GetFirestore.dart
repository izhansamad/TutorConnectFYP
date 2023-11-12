import 'package:cloud_firestore/cloud_firestore.dart';

import 'Course.dart';

class GetFirestore {
  Future<List<Course>> getTeacherCourses(String teacherDocId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherDocId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        var courseData = data['courses'] as List<dynamic>;

        List<Course> courses =
            courseData.map((courseMap) => Course.fromMap(courseMap)).toList();

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
