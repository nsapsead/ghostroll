import 'package:cloud_firestore/cloud_firestore.dart';

class ClassNote {
  final String id;
  final String classSessionId;
  final String clubId;
  final String authorUserId;
  final String section; // "techniques", "details", "sparring", "reflection", "question"
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned; // for instructor/admin pinning

  ClassNote({
    required this.id,
    required this.classSessionId,
    required this.clubId,
    required this.authorUserId,
    required this.section,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classSessionId': classSessionId,
      'clubId': clubId,
      'authorUserId': authorUserId,
      'section': section,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isPinned': isPinned,
    };
  }

  factory ClassNote.fromJson(Map<String, dynamic> json) {
    return ClassNote(
      id: json['id'] as String,
      classSessionId: json['classSessionId'] as String,
      clubId: json['clubId'] as String,
      authorUserId: json['authorUserId'] as String,
      section: json['section'] as String,
      content: json['content'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  ClassNote copyWith({
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return ClassNote(
      id: id,
      classSessionId: classSessionId,
      clubId: clubId,
      authorUserId: authorUserId,
      section: section,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
