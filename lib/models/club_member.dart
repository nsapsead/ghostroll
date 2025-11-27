import 'package:cloud_firestore/cloud_firestore.dart';

enum ClubRole {
  member,
  instructor,
  owner,
  admin,
}

extension ClubRoleExtension on ClubRole {
  String get name {
    switch (this) {
      case ClubRole.member:
        return 'member';
      case ClubRole.instructor:
        return 'instructor';
      case ClubRole.owner:
        return 'owner';
      case ClubRole.admin:
        return 'admin';
    }
  }

  static ClubRole fromString(String role) {
    switch (role) {
      case 'instructor':
        return ClubRole.instructor;
      case 'owner':
        return ClubRole.owner;
      case 'admin':
        return ClubRole.admin;
      case 'member':
      default:
        return ClubRole.member;
    }
  }
}

class ClubMember {
  final String id;
  final String clubId;
  final String userId;
  final ClubRole role;
  final String? beltRank;
  final DateTime joinedAt;
  final bool isActive;
  final String? displayNameOverride;

  ClubMember({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.role,
    this.beltRank,
    required this.joinedAt,
    this.isActive = true,
    this.displayNameOverride,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      'userId': userId,
      'role': role.name,
      'beltRank': beltRank,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      'displayNameOverride': displayNameOverride,
    };
  }

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      userId: json['userId'] as String,
      role: ClubRoleExtension.fromString(json['role'] as String),
      beltRank: json['beltRank'] as String?,
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
      isActive: json['isActive'] as bool? ?? true,
      displayNameOverride: json['displayNameOverride'] as String?,
    );
  }

  ClubMember copyWith({
    ClubRole? role,
    String? beltRank,
    bool? isActive,
    String? displayNameOverride,
  }) {
    return ClubMember(
      id: id,
      clubId: clubId,
      userId: userId,
      role: role ?? this.role,
      beltRank: beltRank ?? this.beltRank,
      joinedAt: joinedAt,
      isActive: isActive ?? this.isActive,
      displayNameOverride: displayNameOverride ?? this.displayNameOverride,
    );
  }
}
