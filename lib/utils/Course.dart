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
      customFields: List<Map<String, dynamic>>.from(map['customFields'] ?? []),
      modules: (map['modules'] as List<dynamic>?)
          ?.map((moduleMap) => Module.fromMap(moduleMap))
          .toList(),
    );
  }

  factory Course.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Course.fromMap(data);
  }
}

class Module {
  final String moduleName;
  final String moduleDescription;
  List<Material>? materials;

  Module({
    required this.moduleName,
    required this.moduleDescription,
    this.materials,
  });

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      moduleName: map['moduleName'],
      moduleDescription: map['moduleDescription'],
      materials: (map['materials'] as List<dynamic>?)
          ?.map((materialMap) => Material.fromMap(materialMap))
          .toList(),
    );
  }
}

class Material {
  final String materialType;
  final String materialUrl;
  final int materialOrder;

  Material({
    required this.materialType,
    required this.materialUrl,
    required this.materialOrder,
  });

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      materialType: map['materialType'],
      materialUrl: map['materialUrl'],
      materialOrder: map['materialOrder'],
    );
  }
}
