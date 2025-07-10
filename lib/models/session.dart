enum ClassType { gi, noGi, striking }

class Session {
  final String id;
  final DateTime date;
  final ClassType classType;
  final String focusArea;
  final int rounds;
  final List<String> techniquesLearned;
  final String? sparringNotes;
  final String? reflection;

  Session({
    required this.id,
    required this.date,
    required this.classType,
    required this.focusArea,
    required this.rounds,
    required this.techniquesLearned,
    this.sparringNotes,
    this.reflection,
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
} 