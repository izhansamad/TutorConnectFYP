import 'package:flutter/material.dart';

import '../data/json.dart';
import '../utils/Teacher.dart';

class TeacherBox extends StatelessWidget {
  TeacherBox(
      {Key? key,
      required this.index,
      required this.teacher,
      required this.onTap})
      : super(key: key);
  final int index;
  Teacher teacher;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                    height: index.isEven ? 100 : 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(
                              teacher.image ?? teachers[0]['image'].toString()),
                          fit: BoxFit.cover),
                    )),
              ),
              SizedBox(height: 10),
              Text(
                teacher.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1),
              Text(
                teacher.speciality,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              SizedBox(height: 3),
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
                    "${teacher.rating} Review",
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              SizedBox(height: 3),
            ],
          )),
    );
  }
}
