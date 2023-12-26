import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../utils/PrefsManager.dart';
import '../utils/Student.dart';
import '../utils/Teacher.dart';
import '../utils/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.arguments});

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final String currentUserId;
  bool isLoading = false;
  bool isTeacher = false;
  var data;
  String previousSenderId = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final StudentDataProvider studentProvider =
      context.read<StudentDataProvider>();
  late final TeacherDataProvider teacherProvider =
      context.read<TeacherDataProvider>();

  @override
  void initState() {
    isTeacher = PrefsManager().getBool('isTeacher');
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
  }

  void onSendMessage(String content) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      if (isTeacher) {
        chatProvider.sendMessage(
          content: content,
          studentId: widget.arguments.peerId,
          teacherId: currentUserId,
          studentName: widget.arguments.peerName,
          teacherName: FirebaseAuth.instance.currentUser!.displayName ?? "",
          teacherImage: teacherProvider.teacherData?.image ?? "",
          studentImage: widget.arguments.peerAvatar,
        );
      } else {
        chatProvider.sendMessage(
            content: content,
            studentId: currentUserId,
            teacherId: widget.arguments.peerId,
            studentName: FirebaseAuth.instance.currentUser!.displayName ?? "",
            teacherName: widget.arguments.peerName,
            teacherImage: widget.arguments.peerAvatar,
            studentImage: studentProvider.studentData?.image ?? "");
      }
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: grayText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.widget.arguments.peerName,
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _getMessagesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Return a loading indicator while waiting for the data
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle the error
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Access the data using snapshot.data
              QuerySnapshot querySnapshot = snapshot.data!;
              List<Map<String, dynamic>> messages =
                  _extractMessages(querySnapshot);
              if (messages.isNotEmpty) {
                messages[0]['messages'].sort((a, b) {
                  var timestampA = int.parse(a['timestamp']);
                  var timestampB = int.parse(b['timestamp']);
                  return timestampB.compareTo(timestampA);
                });
              }
              print("MESSAGES $messages");
              return Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: messages.isNotEmpty
                            ? ListView.builder(
                                reverse: true,
                                itemCount: messages[0]['messages'].length,
                                itemBuilder: (context, index) {
                                  var message = messages[0]['messages'][index];
                                  bool isSentByTeacher =
                                      message['senderId'] == currentUserId;
                                  bool isLastMsgLeft = !isSentByTeacher;
                                  bool showAvatar =
                                      message['senderId'] != previousSenderId;
                                  previousSenderId = message['senderId'];
                                  return MessageWidget(
                                    content: message['content'],
                                    peerAvatar: widget.arguments.peerAvatar,
                                    isSentByTeacher: isSentByTeacher,
                                    isLastMsgLeft: isLastMsgLeft,
                                    showAvatar: showAvatar,
                                  );
                                },
                              )
                            : Center(child: Text("No message here yet...")),
                      ), // Input content
                      buildInput(),
                    ],
                  ),

                  // Loading
                  buildLoading(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getMessagesStream() {
    if (isTeacher) {
      return chatProvider.getMessagesStream(
          widget.arguments.peerId, currentUserId);
    } else {
      return chatProvider.getMessagesStream(
          currentUserId, widget.arguments.peerId);
    }
  }

  List<Map<String, dynamic>> _extractMessages(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(width: 40),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text);
                },
                style: TextStyle(color: primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: grayText),
                ),
                focusNode: focusNode,
                autofocus: true,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: grayText, width: 0.5)),
          color: Colors.white),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String content;
  final String peerAvatar;
  final bool isSentByTeacher;
  final bool isLastMsgLeft;
  final bool showAvatar;

  MessageWidget({
    required this.content,
    required this.peerAvatar,
    required this.isSentByTeacher,
    required this.isLastMsgLeft,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    // Customize the UI based on whether the message is sent by the teacher or not
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        alignment:
            isSentByTeacher ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              isSentByTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLastMsgLeft && showAvatar
                ? Material(
                    child: Image.network(
                      peerAvatar,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return Icon(
                          Icons.account_circle,
                          size: 35,
                          color: grayText,
                        );
                      },
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                    clipBehavior: Clip.hardEdge,
                  )
                : Container(width: 35),
            Card(
              color: isSentByTeacher ? Colors.blue : Colors.green,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  content,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  ChatPageArguments(
      {required this.peerId, required this.peerAvatar, required this.peerName});
}
