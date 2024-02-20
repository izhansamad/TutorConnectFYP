import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/chat_page.dart';
import 'avatar_image.dart';

//
// import 'avatar_image.dart';
//
// class ChatItem extends StatelessWidget {
//   final String peerId;
//   final String peerAvatar;
//   final String peerNickname;
//
//   ChatItem({
//     required this.peerId,
//     required this.peerAvatar,
//     required this.peerNickname,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Customize the UI of each chat item
//     return ListTile(
//       leading: CircleAvatar(
//         // Display the peer's avatar
//         backgroundImage: NetworkImage(peerAvatar),
//       ),
//       title: Text(peerNickname),
//       subtitle: Text("Last message goes here"), // You can customize this
//       onTap: () {
//         // Navigate to the chat screen when a chat item is tapped
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               arguments: ChatPageArguments(
//                 peerId: peerId,
//                 peerAvatar: peerAvatar,
//                 peerName: peerNickname,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class ChatItem extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;
  final String lastMessage;
  final String peerFCMToken;
  final String timestamp;

  ChatItem({
    required this.peerId,
    required this.peerAvatar,
    required this.peerName,
    required this.lastMessage,
    required this.peerFCMToken,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              arguments: ChatPageArguments(
                peerId: peerId,
                peerFCMToken: peerFCMToken,
                peerAvatar: peerAvatar,
                peerName: peerName,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarImage(
                  peerAvatar,
                  radius: 10,
                ),
                SizedBox(width: 10),
                Expanded(
                    child: Container(
                        height: 65,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                        child: Text(peerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)))),
                                SizedBox(width: 5),
                                Container(
                                    child: Icon(
                                  Icons.date_range,
                                  size: 10,
                                  color: Colors.grey,
                                )),
                                SizedBox(width: 3),
                                Container(
                                    child: Text(
                                        DateFormat('yyyy-MM-dd HH:mm:ss')
                                            .format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    int.parse(timestamp))),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)))
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    child: Text("",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey))),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13))),
                              ],
                            ),
                          ],
                        ))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
