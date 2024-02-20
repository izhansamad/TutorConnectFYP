import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class TeacherDataProvider extends ChangeNotifier {
  Teacher? _teacherData;

  Teacher? get teacherData => _teacherData;

  Future<void> refreshTeacherData() async {
    final teacherData = await getTeacherFromFirestore();

    if (teacherData != null) {
      _teacherData = teacherData;
      notifyListeners();
    }
  }

  void setTeacherData(Teacher teacherData) {
    _teacherData = teacherData;
    notifyListeners();
  }

  Future<Teacher?> getTeacherFromFirestore() async {
    DocumentSnapshot? userDocument = await getCurrentUserDocument();

    if (userDocument != null) {
      // Create a Teacher object from the user document
      return Teacher.fromDocument(userDocument);
    } else {
      // Handle the case when the user document is not found
      return null;
    }
  }

  Future<DocumentSnapshot?> getCurrentUserDocument() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Reference to the Firestore collection where user data is stored
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('teacher');

      // Query for the document with the current user's UID
      DocumentSnapshot userDoc = await usersCollection.doc(userUid).get();

      if (userDoc.exists) {
        return userDoc; // Return the user's document
      } else {
        // User not found, handle this case as needed (e.g., return null or an error).
        return null; // or throw an exception
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore query
      print("Error fetching user document: $error");
      throw error;
    }
  }
}

class AllTeachersDataProvider extends ChangeNotifier {
  List<Teacher>? _teachersData;

  List<Teacher>? get teachersData => _teachersData;

  Future<void> refreshTeachersData() async {
    final teachersData = await getAllTeachersFromFirestore();

    if (teachersData != null) {
      _teachersData = teachersData;
      notifyListeners();
    }
  }

  void setTeachersData(List<Teacher> teachersData) {
    _teachersData = teachersData;
    notifyListeners();
  }

  Future<Teacher?> getTeacherById(String teacherId) async {
    try {
      // Reference to the 'teacher' collection
      CollectionReference teachersCollection =
      FirebaseFirestore.instance.collection('teacher');

      // Get the document snapshot corresponding to the provided teacher ID
      DocumentSnapshot teacherDocSnapshot =
      await teachersCollection.doc(teacherId).get();

      // Check if the document exists
      if (teacherDocSnapshot.exists) {
        // Create a Teacher object from the document snapshot data
        Teacher teacher = Teacher.fromDocument(teacherDocSnapshot);
        return teacher;
      } else {
        // If the document does not exist, return null
        return null;
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore query
      print("Error fetching teacher by ID: $error");
      throw error;
    }
  }

  Future<List<Teacher>?> getAllTeachersFromFirestore() async {
    try {
      List<Teacher> teachersList = [];
      CollectionReference teachersCollection =
          FirebaseFirestore.instance.collection('teacher');

      QuerySnapshot teacherQuerySnapshot = await teachersCollection.get();

      teacherQuerySnapshot.docs.forEach((teacherDoc) {
        // Create a Teacher object from each document and add it to the list
        Teacher teacher = Teacher.fromDocument(teacherDoc);
        teachersList.add(teacher);
      });
      return teachersList;
    } catch (error) {
      // Handle any errors that occur during the Firestore query
      print("Error fetching teachers: $error");
      throw error;
    }
  }
}

class Teacher {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String about;
  final String experience;
  final String speciality;
  final String qualification;
  final String rating;
  final String fcmToken;
  final String? image;
  List<Map<String, dynamic>>? customFields;

  Teacher(
      {required this.id,
      required this.fullName,
      required this.email,
      required this.phone,
      required this.about,
      required this.experience,
      required this.speciality,
      required this.qualification,
      required this.rating,
      required this.image,
      required this.fcmToken,
      this.customFields});

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phoneNumber'],
      about: map['about'],
      experience: map['experience'],
      speciality: map['speciality'],
      qualification: map['qualification'],
      image: map['image'],
      rating: map['rating'],
      fcmToken: map['pushToken'] ?? "",
      customFields: List<Map<String, dynamic>>.from(map['customFields'] ?? []),
    );
  }

  factory Teacher.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Teacher.fromMap(data);
  }
}
