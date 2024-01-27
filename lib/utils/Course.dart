import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String courseName;
  final String courseId;
  final String courseDesc;
  final String courseObj;
  final String courseFee;
  final String courseDuration;
  final String courseImage;
  final String? courseRating;
  final String teacherId;
  bool courseStatus;
  List<Map<String, dynamic>>? customFields;
  List<Module>? modules;

  Course({
    required this.courseName,
    required this.courseId,
    required this.courseDesc,
    required this.courseObj,
    required this.courseFee,
    required this.courseDuration,
    required this.courseImage,
    required this.courseRating,
    required this.teacherId,
    this.courseStatus = false,
    this.customFields,
    this.modules,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseName: map['courseName'],
      courseId: map['courseId'],
      courseDesc: map['courseDesc'],
      courseObj: map['courseObj'],
      courseFee: map['courseFee'],
      courseDuration: map['courseDuration'],
      courseImage: map['courseImage'],
      courseRating: map['courseRating'],
      teacherId: map['teacherId'],
      courseStatus: map['courseStatus'] ?? false,
      customFields: List<Map<String, dynamic>>.from(map['customFields'] ?? []),
      modules: (map['modules'] as List<dynamic>?)
              ?.map((moduleMap) => Module.fromMap(moduleMap))
              .toList() ??
          [],
    );
  }

  factory Course.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Course.fromMap(data);
  }
}

class Module {
  final String? moduleId;
  final String moduleName;
  final String moduleDescription;
  List<CourseMaterial>? materials;

  Module({
    this.moduleId,
    required this.moduleName,
    required this.moduleDescription,
    this.materials,
  });
  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'moduleName': moduleName,
      'moduleDescription': moduleDescription,
      'materials': materials?.map((material) => material.toMap()).toList(),
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      moduleId: map['moduleId'],
      moduleName: map['moduleName'],
      moduleDescription: map['moduleDescription'],
      materials: (map['materials'] as List<dynamic>?)
          ?.map((materialMap) => CourseMaterial.fromMap(materialMap))
          .toList(),
    );
  }
}

class CourseMaterial {
  final String materialType;
  final String materialUrl;
  final int materialOrder;
  final String materialName;

  CourseMaterial({
    required this.materialType,
    required this.materialUrl,
    required this.materialOrder,
    required this.materialName,
  });

  factory CourseMaterial.fromMap(Map<String, dynamic> map) {
    return CourseMaterial(
      materialType: map['materialType'],
      materialUrl: map['materialUrl'],
      materialOrder: map['materialOrder'],
      materialName: map['materialName'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'materialType': materialType,
      'materialUrl': materialUrl,
      'materialOrder': materialOrder,
      'materialName': materialName,
    };
  }
}
