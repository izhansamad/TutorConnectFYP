import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutor_connect_app/screens/teacher/AddQuizScreen.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherEditProfileScreen.dart';
import 'package:tutor_connect_app/screens/teacher/TeacherHome.dart';

import '../../utils/Course.dart';

class AddModulesScreen extends StatefulWidget {
  final Course course;
  final Module? module;

  AddModulesScreen({required this.course, this.module});

  @override
  _AddModulesScreenState createState() => _AddModulesScreenState();
}

class CustomFile {
  final String name;
  final File file;
  final String type;

  CustomFile({required this.name, required this.file, this.type = ""});
}

class _AddModulesScreenState extends State<AddModulesScreen> {
  List<CustomFile> selectedFiles = [];
  List<String> deletedMaterial = [];

  TextEditingController moduleNameController = TextEditingController();
  TextEditingController moduleDescriptionController = TextEditingController();
  TextEditingController materialNameController = TextEditingController();

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
        title:
            widget.module != null ? Text("Update Module") : Text("Add Module"),
        actions: [
          if (widget.module != null)
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Are you sure'),
                        content: Text('You want to delete this module?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () {
                              deleteModule();
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete))
        ],
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Add Materials",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            textField(
              controller: materialNameController,
              hintTxt: "Material Name",
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
            if (widget.module?.materials?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Existing Materials",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  for (CourseMaterial material
                      in widget.module?.materials ?? [])
                    ListTile(
                      leading: material.materialType == "pdf"
                          ? Icon(Icons.picture_as_pdf)
                          : Icon(Icons.video_camera_back),
                      title: Text(material.materialName),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Are you sure'),
                                content:
                                    Text('You want to delete this material?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Delete'),
                                    onPressed: () {
                                      deletedMaterial.add(material.materialUrl);
                                      widget.module?.materials?.removeWhere(
                                        (item) =>
                                            item.materialUrl ==
                                            material.materialUrl,
                                      );
                                      setState(() {});
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            if (selectedFiles.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Selected Materials",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: selectedFiles[index].type == "pdf"
                            ? Icon(Icons.picture_as_pdf)
                            : Icon(Icons.video_camera_back),
                        title: Text(selectedFiles[index].name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            selectedFiles.removeAt(index);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                if (moduleNameController.text == "" ||
                    moduleDescriptionController.text == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("All fields are required!")));
                  return;
                }
                if ((widget.module?.materials?.length ?? 0) == 0 &&
                    selectedFiles.length == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Cannot save a empty module")));
                  return;
                }
                saveModule();
              },
              child: Text("Save Module"),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => AddQuizScreen(
                                courseId: widget.course.courseId,
                                moduleId: widget.module!.moduleId ?? "")));
                  },
                  child: Text("Add Quiz")),
            )
          ],
        ),
      ),
    );
  }

  Future<void> pickAndUploadFile(String fileType) async {
    if (materialNameController.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter Material Name")));
      return;
    }
    FilePickerResult? result;
    if (fileType == 'video') {
      result = await FilePicker.platform.pickFiles(type: FileType.video);
    } else if (fileType == 'pdf') {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    }

    if (result != null) {
      selectedFiles.add(CustomFile(
          name: materialNameController.text,
          type: fileType,
          file: File(result.files.single.path ?? "")));
      materialNameController.clear();
      // selectedFiles.add(File(result?.files.single.path ?? ""));
      setState(() {});
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
    moveToHome();

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
      if (deletedMaterial.isNotEmpty) {
        for (var url in deletedMaterial) {
          deleteMaterialFromStorage(url);
        }
      }
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
      // await moduleDocRef.update(updatedModule.toMap());
      Map<Object, Object?> data = {
        'moduleName': updatedModule.moduleName,
        'moduleDescription': updatedModule.moduleDescription,
        'materials': updatedModule.materials
            ?.map((material) => material.toMap())
            .toList(),
      };
      await moduleDocRef.update(data);

      print('Module updated with ID: $moduleId');
    } catch (e) {
      print('Error updating module data in Firestore: $e');
      // Handle error as needed
    }
  }

  Future<List<CourseMaterial>> uploadFilesToFirebaseStorage() async {
    FirebaseStorage storage = FirebaseStorage.instance;

    List<CourseMaterial> materials = [];

    for (var selectedFile in selectedFiles) {
      try {
        Reference ref = storage.ref().child(
            'courseMaterial/${DateTime.now().millisecondsSinceEpoch}_${selectedFile.file.path.split('/').last}');
        await ref.putFile(selectedFile.file);
        String downloadUrl = await ref.getDownloadURL();

        // Create CourseMaterial instance with Firebase Storage URL
        CourseMaterial material = CourseMaterial(
          materialType: getFileType(selectedFile.file),
          materialUrl: downloadUrl,
          materialOrder: materials.length + 1, // Incremental order
          materialName: selectedFile.name,
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

  void deleteMaterialFromStorage(String materialUrl) async {
    try {
      Reference materialRef = FirebaseStorage.instance.refFromURL(materialUrl);
      await materialRef.delete();
      setState(() {});
      print('Material deleted successfully.');
    } catch (e) {
      print('Error deleting material: $e');
      // Handle error as needed
    }
  }

  Future<void> deleteModule() async {
    try {
      final teacherUid = FirebaseAuth.instance.currentUser!.uid;
      final modulesCollection = FirebaseFirestore.instance
          .collection('courses')
          .doc(teacherUid)
          .collection("teacherCourses")
          .doc(widget.course.courseId)
          .collection('modules');

      // Reference to the specific module document
      final moduleDocRef = modulesCollection.doc(widget.module?.moduleId);

      // Get the module data to retrieve the list of materials
      DocumentSnapshot<Map<String, dynamic>> moduleSnapshot =
          await moduleDocRef.get();
      Map<String, dynamic>? moduleData = moduleSnapshot.data();

      if (moduleData != null) {
        // Delete the module document from Firestore
        await moduleDocRef.delete();

        // Retrieve the list of materials
        List<Map<String, dynamic>>? materials =
            (moduleData['materials'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>();

        if (materials != null) {
          // Delete each material from Firebase Storage
          for (Map<String, dynamic> materialData in materials) {
            String materialUrl = materialData['materialUrl'];
            Reference materialRef =
                FirebaseStorage.instance.refFromURL(materialUrl);
            await materialRef.delete();
            print('Material deleted from Storage: $materialUrl');
          }
        }
        moveToHome();
        print('Module and associated materials deleted successfully.');
      } else {
        print('Module not found.');
      }
    } catch (e) {
      print('Error deleting module and materials: $e');
      // Handle error as needed
    }
  }

  moveToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => TeacherHome()),
        (route) => false);
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
