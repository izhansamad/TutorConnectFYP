import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class StudentDataProvider extends ChangeNotifier {
  Student? _studentData;

  Student? get studentData => _studentData;

  Future<void> refreshTeacherData() async {
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
}

class Student {
  final String fullName;
  final String email;
  final String phone;
  final String image;

  Student({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.image,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
        fullName: map['fullName'],
        email: map['email'],
        phone: map['phoneNumber'],
        image: map['image']);
  }

  factory Student.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Student.fromMap(data);
  }
}
