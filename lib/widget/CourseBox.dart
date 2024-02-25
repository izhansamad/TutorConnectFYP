import 'package:flutter/material.dart';

import '../utils/Course.dart';

class CourseBox extends StatelessWidget {
  CourseBox({
    Key? key,
    required this.course,
  }) : super(key: key);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(
                  course.courseImage == ""
                      ? 'https://blogassets.leverageedu.com/blog/wp-content/uploads/2019/10/23170101/List-of-Professional-Courses-after-Graduation.gif'
                      : course.courseImage,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  course.courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse,
                            color: Colors.blue,
                            size: 16,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "${course.courseDuration}",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "${course.courseRating ?? "5"}",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          Text(
                            "${course.courseFee}",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CourseBoxHomeScreen extends StatelessWidget {
  CourseBoxHomeScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 300,
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
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 80,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(
                      course.courseImage == ""
                          ? 'https://blogassets.leverageedu.com/blog/wp-content/uploads/2019/10/23170101/List-of-Professional-Courses-after-Graduation.gif'
                          : course.courseImage,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10, width: 170),
                    Text(
                      course.courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text(
                        "Sir ${course.teacherName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade700),
                      ),
                    ),
                    SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timelapse,
                                color: Colors.blue,
                                size: 16,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "${course.courseDuration}",
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 16,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "${course.courseRating ?? "5"}",
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(
                                width: 1,
                              ),
                              Text(
                                "${course.courseFee}",
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
