import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:tutor_connect_app/core/colors.dart';
import 'package:tutor_connect_app/screens/student/TeacherProfileScreen.dart';
import 'package:tutor_connect_app/widget/searchBar.dart';
import 'package:tutor_connect_app/widget/teacher_box.dart';

import '../../utils/Teacher.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({Key? key}) : super(key: key);

  @override
  _TeachersScreenState createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  var teachersList;
  @override
  Widget build(BuildContext context) {
    final teachersDataProvider = Provider.of<AllTeachersDataProvider>(context);
    teachersList = teachersDataProvider.teachersData;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Teachers",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.favorite,
              color: Colors.red.shade800,
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(child: CustomSearch()),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: primaryColor,
                      size: 35,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              getTeachersList()
            ])));
  }

  getTeachersList() {
    return new StaggeredGridView.countBuilder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      itemCount: teachersList.length,
      itemBuilder: (BuildContext context, int index) => TeacherBox(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TeacherProfileScreen(
                          teacher: teachersList[index],
                        )));
          },
          index: index,
          teacher: teachersList[index]),
      staggeredTileBuilder: (int index) =>
          new StaggeredTile.count(2, index.isEven ? 3 : 3),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }
}
