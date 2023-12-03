import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherEditProfileScreen.dart';

import '../../utils/Course.dart';

class AddModulesScreen extends StatefulWidget {
  final Course course;
  final Module? module;

  AddModulesScreen({required this.course, this.module});

  @override
  _AddModulesScreenState createState() => _AddModulesScreenState();
}

class _AddModulesScreenState extends State<AddModulesScreen> {
  List<File> selectedFiles = [];

  TextEditingController moduleNameController = TextEditingController();
  TextEditingController moduleDescriptionController = TextEditingController();

  @override
  void initState() {
    if (widget.module != null) {
      moduleNameController.text = widget.module!.moduleName;
      moduleDescriptionController.text = widget.module!.moduleDescription;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Modules"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            textField(
              controller: moduleNameController,
              hintTxt: "Module Name",
              validator: validateRequired,
            ),
            textField(
              controller: moduleDescriptionController,
              hintTxt: "Module Description",
              validator: validateRequired,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await pickAndUploadFile('video');
                  },
                  child: Text("Add Video"),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    await pickAndUploadFile('pdf');
                  },
                  child: Text("Add PDF"),
                ),
              ],
            ),
            if (widget.module != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Existing Materials:"),
                  for (CourseMaterial material
                      in widget.module?.materials ?? [])
                    ListTile(
                      title: Text(material.materialUrl.split('/').last),
                    ),
                ],
              ),
            if (selectedFiles.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selected Files:"),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(selectedFiles[index].path.split('/').last),
                      );
                    },
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                saveModule();
              },
              child: Text("Save Module"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickAndUploadFile(String fileType) async {
    FilePickerResult? result;
    if (fileType == 'video') {
      result = await FilePicker.platform.pickFiles(type: FileType.video);
    } else if (fileType == 'pdf') {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    }
    if (result != null) {
      setState(() {
        selectedFiles.add(File(result?.files.single.path ?? ""));
      });
    }
  }

  void saveModule() async {
    List<CourseMaterial> materials = await uploadFilesToFirebaseStorage();

    // Create a new module with the uploaded materials
    Module newModule = Module(
      moduleName: moduleNameController.text,
      moduleDescription: moduleDescriptionController.text,
      materials: [...?widget.module?.materials, ...materials],
    );
    print("NEW MODULE $newModule");

    if (widget.module != null) {
      await updateCourseModule(widget.module!.moduleId ?? "", newModule);
    } else {
      await addCourseModules(newModule);
    }

    setState(() {
      selectedFiles = [];
    });

    print("Module saved!");
  }

  Future<void> addCourseModules(Module module) async {
    try {
      final teacherUid = FirebaseAuth.instance.currentUser!.uid;
      final modulesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherUid)
          .collection("teacherCourses")
          .doc(widget.course.courseId)
          .collection('modules');

      DocumentReference docRef = await modulesCollection.add(module.toMap());
      String moduleId = docRef.id;
      await docRef.update({'moduleId': moduleId});
    } catch (e) {
      print('Error updating Course data in Firestore: $e');
      // Handle error as needed
    }
  }

  Future<void> updateCourseModule(String moduleId, Module updatedModule) async {
    try {
      final teacherUid = FirebaseAuth.instance.currentUser!.uid;
      final modulesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherUid)
          .collection("teacherCourses")
          .doc(widget.course.courseId)
          .collection('modules');

      // Reference to the specific module document
      final moduleDocRef = modulesCollection.doc(moduleId);

      // Update the module document with the new data
      await moduleDocRef.update(updatedModule.toMap());

      print('Module updated with ID: $moduleId');
    } catch (e) {
      print('Error updating module data in Firestore: $e');
      // Handle error as needed
    }
  }

  Future<List<CourseMaterial>> uploadFilesToFirebaseStorage() async {
    FirebaseStorage storage = FirebaseStorage.instance;

    List<CourseMaterial> materials = [];

    for (File file in selectedFiles) {
      try {
        Reference ref = storage.ref().child(
            'courseMaterial/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');

        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();

        // Create CourseMaterial instance with Firebase Storage URL
        CourseMaterial material = CourseMaterial(
          materialType: getFileType(file),
          materialUrl: downloadUrl,
          materialOrder: materials.length + 1, // Incremental order
        );

        materials.add(material);
      } catch (e) {
        print('Error uploading file to Firebase Storage: $e');
        // Handle error as needed
      }
    }

    return materials;
  }

  String getFileType(File file) {
    // Logic to determine the file type based on the file extension
    // You might want to enhance this based on your specific use case
    if (file.path.toLowerCase().endsWith('.pdf')) {
      return 'pdf';
    } else if (file.path.toLowerCase().endsWith('.mp4') ||
        file.path.toLowerCase().endsWith('.mov')) {
      return 'video';
    } else {
      return 'unknown';
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
