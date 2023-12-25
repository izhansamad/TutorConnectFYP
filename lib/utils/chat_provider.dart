import 'package:cloud_firestore/cloud_firestore.dart';
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
      required String studentImage}) async {
    try {
      // Reference to the 'conversations' collection
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
              'senderId': PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY)
                  ? teacherId
                  : studentId,
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
              'senderId':
                  PrefsManager().getBool('isTeacher') ? teacherId : studentId,
              'content': content,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            },
          ],
        });
      }
    } catch (error) {
      print('Error sending message: $error');
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
