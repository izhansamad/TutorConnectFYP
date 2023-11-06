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

class Teacher {
  final String fullName;
  final String email;
  final String phone;
  final String about;
  final String experience;
  final String speciality;
  final String qualification;
  final String rating;
  final String? image;

  Teacher({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.about,
    required this.experience,
    required this.speciality,
    required this.qualification,
    required this.rating,
    required this.image,
  });

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
        fullName: map['fullName'],
        email: map['email'],
        phone: map['phoneNumber'],
        about: map['about'],
        experience: map['experience'],
        speciality: map['speciality'],
        qualification: map['qualification'],
        image: map['image'],
        rating: map['rating']);
  }

  factory Teacher.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Teacher.fromMap(data);
  }
}
