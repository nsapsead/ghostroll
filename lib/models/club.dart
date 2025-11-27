import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String id;
  final String name;
  final String country;
  final String city;
  final String style; // e.g. BJJ, MMA, Judo
  final String? website;
  final String? logoUrl;
  final String createdByUserId;
  final DateTime createdAt;
  final bool isVerified;
  final String? joinCode; // for private or invite-only clubs

  Club({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.style,
    this.website,
    this.logoUrl,
    required this.createdByUserId,
    required this.createdAt,
    this.isVerified = false,
    this.joinCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'city': city,
      'style': style,
      'website': website,
      'logoUrl': logoUrl,
      'createdByUserId': createdByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'joinCode': joinCode,
    };
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      style: json['style'] as String,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isVerified: json['isVerified'] as bool? ?? false,
      joinCode: json['joinCode'] as String?,
    );
  }

  Club copyWith({
    String? name,
    String? country,
    String? city,
    String? style,
    String? website,
    String? logoUrl,
    bool? isVerified,
    String? joinCode,
  }) {
    return Club(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      style: style ?? this.style,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      createdByUserId: createdByUserId,
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
      joinCode: joinCode ?? this.joinCode,
    );
  }
}
