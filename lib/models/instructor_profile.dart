class InstructorProfile {
  final String id;
  final String userId;
  final String? bio;
  final String? primaryClubId;
  final List<String> otherClubIds;
  final List<String> specialties; // e.g. "pressure passing", "leg locks"
  final Map<String, String>? socialLinks; // e.g. {"instagram": "...", "website": "..."}
  final bool isPublic;

  InstructorProfile({
    required this.id,
    required this.userId,
    this.bio,
    this.primaryClubId,
    this.otherClubIds = const [],
    this.specialties = const [],
    this.socialLinks,
    this.isPublic = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bio': bio,
      'primaryClubId': primaryClubId,
      'otherClubIds': otherClubIds,
      'specialties': specialties,
      'socialLinks': socialLinks,
      'isPublic': isPublic,
    };
  }

  factory InstructorProfile.fromJson(Map<String, dynamic> json) {
    return InstructorProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bio: json['bio'] as String?,
      primaryClubId: json['primaryClubId'] as String?,
      otherClubIds: List<String>.from(json['otherClubIds'] ?? []),
      specialties: List<String>.from(json['specialties'] ?? []),
      socialLinks: json['socialLinks'] != null 
          ? Map<String, String>.from(json['socialLinks']) 
          : null,
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  InstructorProfile copyWith({
    String? bio,
    String? primaryClubId,
    List<String>? otherClubIds,
    List<String>? specialties,
    Map<String, String>? socialLinks,
    bool? isPublic,
  }) {
    return InstructorProfile(
      id: id,
      userId: userId,
      bio: bio ?? this.bio,
      primaryClubId: primaryClubId ?? this.primaryClubId,
      otherClubIds: otherClubIds ?? this.otherClubIds,
      specialties: specialties ?? this.specialties,
      socialLinks: socialLinks ?? this.socialLinks,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
