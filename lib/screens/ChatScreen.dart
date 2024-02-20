import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/utils/PrefsManager.dart';
import 'package:tutor_connect_app/widget/searchBar.dart';

import '../utils/Student.dart';
import '../utils/Teacher.dart';
import '../utils/chat_provider.dart';
import '../widget/chat_item.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final StudentDataProvider studentProvider =
      context.read<StudentDataProvider>();
  late final TeacherDataProvider teacherProvider =
      context.read<TeacherDataProvider>();
  late final String currentUserId;
  bool isTeacher = false;

  @override
  void initState() {
    isTeacher = PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY);
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (PrefsManager().getBool(PrefsManager().IS_TEACHER_KEY)) {
      chatProvider.getTeachersConvoList(currentUserId);
    } else {
      chatProvider.getStudentsConvoList(currentUserId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Chats",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.more_vert_outlined,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: getBody(),
    );
  }

  getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearch(),
            SizedBox(height: 20),
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: isTeacher
                  ? chatProvider.getTeachersConvoList(currentUserId)
                  : chatProvider.getStudentsConvoList(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<QueryDocumentSnapshot> conversations =
                      snapshot.data ?? [];
                  return conversations.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            var conversation = conversations[index];
                            var lastMessage =
                                conversation['messages'].last['content'];
                            var timestamp =
                                conversation['messages'].last['timestamp'];
                            var participants = conversation['participants'];
                            var peerId = isTeacher
                                ? participants['studentId']
                                : participants['teacherId'];
                            var peerAvatar = isTeacher
                                ? participants['studentImage']
                                : participants['teacherImage'];
                            var peerNickname = isTeacher
                                ? participants['studentName']
                                : participants['teacherName'];
                            var peerFCMToken = !isTeacher
                                ? teacherProvider.teacherData?.fcmToken ?? ""
                                : studentProvider.studentData?.fcmToken ?? "";
                            print(
                                "FCM TEACHER: ${teacherProvider.teacherData?.fcmToken ?? ""}, FCM STUDENT: ${studentProvider.studentData?.fcmToken ?? ""}");

                            return ChatItem(
                              peerId: peerId,
                              peerAvatar: peerAvatar,
                              peerName: peerNickname,
                              lastMessage: lastMessage,
                              timestamp: timestamp,
                              peerFCMToken: peerFCMToken,
                            );
                          },
                        )
                      : Center(
                          child: Text("No chats available"),
                        );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// getChatList() {
//   return Column(
//       children: List.generate(
//           chatsData.length, (index) => ChatItem(chatsData[index])));
// }
