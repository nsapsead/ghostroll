enum ClassType { gi, noGi, striking }

extension ClassTypeExtension on ClassType {
  String get displayName {
    switch (this) {
      case ClassType.gi:
        return 'Gi';
      case ClassType.noGi:
        return 'No-Gi';
      case ClassType.striking:
        return 'Striking';
    }
  }
}

class Session {
  final String id;
  final DateTime date;
  final ClassType classType;
  final String focusArea;
  final int rounds;
  final List<String> techniquesLearned;
  final String? sparringNotes;
  final String? reflection;
  final String? mood;
  final String? location;
  final String? instructor;
  final int duration; // in minutes
  final bool isScheduledClass;

  Session({
    required this.id,
    required this.date,
    required this.classType,
    required this.focusArea,
    required this.rounds,
    required this.techniquesLearned,
    this.sparringNotes,
    this.reflection,
    this.mood,
    this.location,
    this.instructor,
    this.duration = 60,
    this.isScheduledClass = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'classType': classType.name,
      'focusArea': focusArea,
      'rounds': rounds,
      'techniquesLearned': techniquesLearned,
      'sparringNotes': sparringNotes,
      'reflection': reflection,
      'mood': mood,
      'location': location,
      'instructor': instructor,
      'duration': duration,
      'isScheduledClass': isScheduledClass,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      date: DateTime.parse(json['date']),
      classType: ClassType.values.firstWhere(
        (e) => e.name == json['classType'],
      ),
      focusArea: json['focusArea'],
      rounds: json['rounds'],
      techniquesLearned: List<String>.from(json['techniquesLearned']),
      sparringNotes: json['sparringNotes'],
      reflection: json['reflection'],
      mood: json['mood'] as String?,
      location: json['location'] as String?,
      instructor: json['instructor'] as String?,
      duration: json['duration'] as int? ?? 60,
      isScheduledClass: json['isScheduledClass'] as bool? ?? false,
    );
  }

  Session copyWith({
    String? mood,
    String? reflection,
    String? sparringNotes,
  }) {
    return Session(
      id: id,
      date: date,
      classType: classType,
      focusArea: focusArea,
      rounds: rounds,
      techniquesLearned: techniquesLearned,
      sparringNotes: sparringNotes ?? this.sparringNotes,
      reflection: reflection ?? this.reflection,
      mood: mood ?? this.mood,
      location: location,
      instructor: instructor,
      duration: duration,
      isScheduledClass: isScheduledClass,
    );
  }

  String get classTypeDisplay {
    switch (classType) {
      case ClassType.gi:
        return 'Gi';
      case ClassType.noGi:
        return 'No-Gi';
      case ClassType.striking:
        return 'Striking';
    }
  }

  String get durationDisplay {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
} 