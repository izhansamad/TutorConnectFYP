import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class StudentDataProvider extends ChangeNotifier {
  Student? _studentData;

  Student? get studentData => _studentData;

  Future<void> refreshStudentData() async {
    final studentData = await getStudentFromFirestore();

    if (studentData != null) {
      _studentData = studentData;
      notifyListeners();
    }
  }

  void setStudentData(Student studentData) {
    _studentData = studentData;
    notifyListeners();
  }

  Future<Student?> getStudentFromFirestore() async {
    DocumentSnapshot? userDocument = await getCurrentUserDocument();

    if (userDocument != null) {
      return Student.fromDocument(userDocument);
    } else {
      return null;
    }
  }

  Future<DocumentSnapshot?> getCurrentUserDocument() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Reference to the Firestore collection where user data is stored
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('student');

      DocumentSnapshot userDoc = await usersCollection.doc(userUid).get();

      if (userDoc.exists) {
        return userDoc;
      } else {
        return null;
      }
    } catch (error) {
      print("Error fetching user document: $error");
      throw error;
    }
  }

  Future<Student?> getStudentById(String studentId) async {
    try {
      // Reference to the 'student' collection
      CollectionReference studentsCollection =
          FirebaseFirestore.instance.collection('student');

      // Get the document snapshot corresponding to the provided student ID
      DocumentSnapshot studentDocSnapshot =
          await studentsCollection.doc(studentId).get();

      // Check if the document exists
      if (studentDocSnapshot.exists) {
        // Create a Student object from the document snapshot data
        Student student = Student.fromDocument(studentDocSnapshot);
        return student;
      } else {
        // If the document does not exist, return null
        return null;
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore query
      print("Error fetching student by ID: $error");
      throw error;
    }
  }
}

class Student {
  final String fullName;
  final String email;
  final String phone;
  final String fcmToken;
  final String image;

  Student({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.fcmToken,
    required this.image,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
        fullName: map['fullName'],
        email: map['email'],
        phone: map['phoneNumber'],
        fcmToken: map['pushToken'] ?? "",
        image: map['image']);
  }

  factory Student.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Student.fromMap(data);
  }
}
