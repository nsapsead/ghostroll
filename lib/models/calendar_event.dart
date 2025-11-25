// Enum for event types
enum CalendarEventType { recurringClass, dropInEvent }

// Calendar Event Model
class CalendarEvent {
  final String id;
  final String title;
  final CalendarEventType type;
  final String classType;
  final DateTime? specificDate; // null for recurring, specific date for drop-ins
  final int? dayOfWeek; // 1-7 for recurring classes, null for drop-ins
  final DateTime? recurringStartDate; // Start date for recurring events
  final DateTime? recurringEndDate; // End date for recurring events (null = indefinite)
  final List<String> deletedInstances; // ISO date strings of deleted individual instances
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final String? location;
  final String? instructor;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.classType,
    this.specificDate,
    this.dayOfWeek,
    this.recurringStartDate,
    this.recurringEndDate,
    this.deletedInstances = const [],
    required this.startTime,
    required this.endTime,
    this.location,
    this.instructor,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'classType': classType,
      'specificDate': specificDate?.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'recurringStartDate': recurringStartDate?.toIso8601String(),
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'deletedInstances': deletedInstances,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'instructor': instructor,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      type: CalendarEventType.values.firstWhere((e) => e.name == json['type']),
      classType: json['classType'],
      specificDate: json['specificDate'] != null ? DateTime.parse(json['specificDate']) : null,
      dayOfWeek: json['dayOfWeek'],
      recurringStartDate: json['recurringStartDate'] != null ? DateTime.parse(json['recurringStartDate']) : null,
      recurringEndDate: json['recurringEndDate'] != null ? DateTime.parse(json['recurringEndDate']) : null,
      deletedInstances: json['deletedInstances'] != null ? List<String>.from(json['deletedInstances']) : [],
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      instructor: json['instructor'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Create a copy with updated fields
  CalendarEvent copyWith({
    String? title,
    CalendarEventType? type,
    String? classType,
    DateTime? specificDate,
    int? dayOfWeek,
    DateTime? recurringStartDate,
    DateTime? recurringEndDate,
    List<String>? deletedInstances,
    String? startTime,
    String? endTime,
    String? location,
    String? instructor,
    String? notes,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      classType: classType ?? this.classType,
      specificDate: specificDate ?? this.specificDate,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      recurringStartDate: recurringStartDate ?? this.recurringStartDate,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      deletedInstances: deletedInstances ?? this.deletedInstances,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      instructor: instructor ?? this.instructor,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class CalendarUtils {
  static String getDayName(int dayOfWeek) {
    const dayNames = [
      '', // Index 0 (unused)
      'Monday',
      'Tuesday', 
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return dayNames[dayOfWeek] ?? 'Unknown';
  }

  static String getShortDayName(int dayOfWeek) {
    const shortDayNames = [
      '', // Index 0 (unused)
      'Mon',
      'Tue', 
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    return shortDayNames[dayOfWeek] ?? 'Unk';
  }

  static String formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  static String formatTimeRange(String startTime, String endTime) {
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  // Get week start (Monday) for a given date
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Get month start for a given date
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
}
