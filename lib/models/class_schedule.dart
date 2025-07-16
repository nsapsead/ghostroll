import 'package:flutter/material.dart';

class ClassScheduleEntry {
  final int dayOfWeek; // 0=Monday, 6=Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String classType;
  final String? location;
  final String? notes;

  ClassScheduleEntry({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.classType,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': '${startTime.hour}:${startTime.minute}',
    'endTime': '${endTime.hour}:${endTime.minute}',
    'classType': classType,
    'location': location,
    'notes': notes,
  };

  static ClassScheduleEntry fromJson(Map<String, dynamic> json) {
    final startParts = (json['startTime'] as String).split(':');
    final endParts = (json['endTime'] as String).split(':');
    return ClassScheduleEntry(
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1])),
      endTime: TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1])),
      classType: json['classType'] as String,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }
} 