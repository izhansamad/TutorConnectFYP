import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_connect_app/utils/PrefsManager.dart';

class ChatProvider {
  final FirebaseFirestore firebaseFirestore;

  ChatProvider({required this.firebaseFirestore});

  CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection('conversations');

  Future<List<QueryDocumentSnapshot>> getTeachersConvoList(
      String teacherId) async {
    QuerySnapshot teacherConversations = await _conversationsCollection
        .where('participants.teacherId', isEqualTo: teacherId)
        .get();
    return teacherConversations.docs;
  }

  Future<List<QueryDocumentSnapshot>> getStudentsConvoList(
      String studentId) async {
    QuerySnapshot studentConversations = await _conversationsCollection
        .where('participants.studentId', isEqualTo: studentId)
        .get();
    return studentConversations.docs;
  }

  Stream<QuerySnapshot> getMessagesStream(String studentId, String teacherId) {
    try {
      return _conversationsCollection
          .where('participants.studentId', isEqualTo: studentId)
          .where('participants.teacherId', isEqualTo: teacherId)
          .snapshots();
    } catch (error) {
      print('Error getting messages stream: $error');
      throw error;
    }
  }

  Future<void> sendMessage(
      {required String content,
      required String studentId,
      required String teacherId,
      required String studentName,
      required String teacherName,
      required String teacherImage,
      required String fcmTokenTeacher,
      required String fcmTokenStudent,
      required String studentImage}) async {
    try {
      bool isTeacher = PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY);
      CollectionReference conversationsCollection =
          FirebaseFirestore.instance.collection('conversations');

      // Query the 'conversations' collection to find the specific conversation
      QuerySnapshot conversationQuerySnapshot = await conversationsCollection
          .where('participants.studentId', isEqualTo: studentId)
          .where('participants.teacherId', isEqualTo: teacherId)
          .get();

      // Check if the conversation already exists
      if (conversationQuerySnapshot.docs.isNotEmpty) {
        var conversationDoc = conversationQuerySnapshot.docs.first;

        // Update the existing conversation document by adding a new message
        await conversationDoc.reference.update({
          'messages': FieldValue.arrayUnion([
            {
              'senderId': isTeacher ? teacherId : studentId,
              'content': content,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          ]),
        });
      } else {
        // If the conversation doesn't exist, create a new conversation document
        await conversationsCollection.add({
          'participants': {
            'studentId': studentId,
            'teacherId': teacherId,
            'studentName': studentName,
            'teacherName': teacherName,
            'studentImage': studentImage,
            'teacherImage': teacherImage
          },
          'messages': [
            {
              'senderId': isTeacher ? teacherId : studentId,
              'content': content,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          ],
        });
      }
      String peerName = !isTeacher ? studentName : teacherName;
      await sendNotification(!isTeacher ? fcmTokenTeacher : fcmTokenStudent,
          "New Message from $peerName", content);
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  Future<void> sendNotification(
      String fcmToken, String title, String body) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAqRdeJF4:APA91bEHLLK8rBAP7N8LBNq2hc5cZRNlZIZybW5M_n2qAm9vRLyMwb7qLixLnVhB2VXAaX48WNJONB2Dm3btMgr0yffvwnXT31Xi5LZFmxENmI-01Dm0exhYkp2RGrN856Xubglz2hac', // FCM server key obtained from Firebase console
    };
    print("FCM TOKEN: $fcmToken");

    final payload = {
      'notification': {
        'title': title,
        'body': body,
      },
      'priority': 'high',
      'to': fcmToken,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getTeacherDetailsById(String teacherId) async {
    try {
      DocumentSnapshot teacherDocSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (teacherDocSnapshot.exists) {
        print(teacherDocSnapshot.data());
        return teacherDocSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore query
      print('Error getting teacher details: $error');
      throw error;
    }
  }

  Future<Map<String, dynamic>> getStudentDetailsById(String studentId) async {
    try {
      DocumentSnapshot studentDocSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDocSnapshot.exists) {
        print(studentDocSnapshot.data());
        return studentDocSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (error) {
      // Handle any errors that occur during the Firestore query
      print('Error getting student details: $error');
      throw error;
    }
  }
}
