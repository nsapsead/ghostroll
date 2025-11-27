import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSession {
  final String id;
  final String clubId;
  final DateTime date;
  final String classType; // "Gi", "No-Gi", "Striking", "Seminar"
  final String? focusArea; // e.g. "Toreando passing"
  final String? instructorId; // link to InstructorProfile or userId
  final int? duration; // minutes
  final String? templateName; // e.g. "Fundamentals", optional
  final String createdByUserId;
  final DateTime createdAt;

  ClassSession({
    required this.id,
    required this.clubId,
    required this.date,
    required this.classType,
    this.focusArea,
    this.instructorId,
    this.duration,
    this.templateName,
    required this.createdByUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      'date': Timestamp.fromDate(date),
      'classType': classType,
      'focusArea': focusArea,
      'instructorId': instructorId,
      'duration': duration,
      'templateName': templateName,
      'createdByUserId': createdByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      classType: json['classType'] as String,
      focusArea: json['focusArea'] as String?,
      instructorId: json['instructorId'] as String?,
      duration: json['duration'] as int?,
      templateName: json['templateName'] as String?,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  ClassSession copyWith({
    DateTime? date,
    String? classType,
    String? focusArea,
    String? instructorId,
    int? duration,
    String? templateName,
  }) {
    return ClassSession(
      id: id,
      clubId: clubId,
      date: date ?? this.date,
      classType: classType ?? this.classType,
      focusArea: focusArea ?? this.focusArea,
      instructorId: instructorId ?? this.instructorId,
      duration: duration ?? this.duration,
      templateName: templateName ?? this.templateName,
      createdByUserId: createdByUserId,
      createdAt: createdAt,
    );
  }
}
