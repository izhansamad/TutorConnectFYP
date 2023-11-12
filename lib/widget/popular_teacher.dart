import 'package:flutter/material.dart';
import 'package:tutor_connect_app/data/json.dart';

import '../utils/Teacher.dart';
import 'avatar_image.dart';

class PopularTeacher extends StatelessWidget {
  PopularTeacher({Key? key, required this.teacher}) : super(key: key);
  Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 3),
      child: Container(
          // margin: EdgeInsets.only(right: 15),
          padding: EdgeInsets.all(15),
          // width: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(1, 1), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              AvatarImage(teacher.image ?? teachers[0]['image'].toString()),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    teacher.speciality,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 14,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        "${teacher.rating} Star",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  )
                ],
              )
            ],
          )),
    );
  }
}
