enum ClassType { gi, noGi, striking, seminar }

extension ClassTypeExtension on ClassType {
  String get displayName {
    switch (this) {
      case ClassType.gi:
        return 'Gi';
      case ClassType.noGi:
        return 'No-Gi';
      case ClassType.striking:
        return 'Striking';
      case ClassType.seminar:
        return 'Seminar';
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
  final String? linkedClassSessionId;

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
    this.linkedClassSessionId,
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
      'linkedClassSessionId': linkedClassSessionId,
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
      linkedClassSessionId: json['linkedClassSessionId'] as String?,
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
      linkedClassSessionId: linkedClassSessionId,
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
      case ClassType.seminar:
        return 'Seminar';
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

  factory Session.fromCalendarEvent({
    required String eventTitle,
    required String classType,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? instructor,
    String? location,
    String? notes,
    String focusArea = '',
    List<String> techniquesLearned = const [],
    String? sparringNotes,
    String? reflection,
    String? mood,
  }) {
    // Convert class type string to ClassType enum
    ClassType sessionClassType;
    switch (classType.toLowerCase()) {
      case 'bjj':
      case 'brazilian jiu-jitsu':
        sessionClassType = ClassType.gi;
        break;
      case 'no-gi':
      case 'nogi':
        sessionClassType = ClassType.noGi;
        break;
      case 'striking':
      case 'muay thai':
      case 'boxing':
      case 'kickboxing':
        sessionClassType = ClassType.striking;
        break;
      case 'seminar':
        sessionClassType = ClassType.seminar;
        break;
      default:
        sessionClassType = ClassType.gi;
    }

    // Calculate duration from start and end time
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startDateTime = DateTime(date.year, date.month, date.day, 
        int.parse(startParts[0]), int.parse(startParts[1]));
    final endDateTime = DateTime(date.year, date.month, date.day, 
        int.parse(endParts[0]), int.parse(endParts[1]));
    final duration = endDateTime.difference(startDateTime).inMinutes;

    return Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      classType: sessionClassType,
      focusArea: focusArea.isNotEmpty ? focusArea : eventTitle,
      rounds: 0, // User can edit this later
      techniquesLearned: techniquesLearned.isNotEmpty ? techniquesLearned : [''],
      sparringNotes: sparringNotes,
      reflection: reflection,
      mood: mood,
      location: location,
      instructor: instructor,
      duration: duration > 0 ? duration : 60, // Default to 60 minutes if calculation fails
      isScheduledClass: true,
    );
  }
} 