import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime? targetDate;
  bool isCompleted;
  final Color color;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'color': color.value,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      color: Color(json['color']),
    );
  }

  /// Create a copy of this goal with updated values
  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isCompleted,
    Color? color,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
    );
  }
}
