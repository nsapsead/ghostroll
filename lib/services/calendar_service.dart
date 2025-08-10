import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/class_schedule.dart';

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

class CalendarService {
  static const String _eventsKey = 'calendar_events';
  static const String _scheduleKey = 'training_schedule'; // Legacy key for backward compatibility

  // Create a recurring class event
  static CalendarEvent createRecurringClass({
    required String classType,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required String startTime, // Format: "HH:mm"
    required String endTime,   // Format: "HH:mm"
    DateTime? recurringStartDate, // When the recurring schedule starts
    DateTime? recurringEndDate,   // When it ends (null = indefinite)
    String? location,
    String? instructor,
    String? notes,
  }) {
    return CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: classType,
      type: CalendarEventType.recurringClass,
      classType: classType,
      dayOfWeek: dayOfWeek,
      recurringStartDate: recurringStartDate ?? DateTime.now(),
      recurringEndDate: recurringEndDate,
      startTime: startTime,
      endTime: endTime,
      location: location,
      instructor: instructor,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  // Create a drop-in event
  static CalendarEvent createDropInEvent({
    required String title,
    required String classType,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? location,
    String? instructor,
    String? notes,
  }) {
    return CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: CalendarEventType.dropInEvent,
      classType: classType,
      specificDate: date,
      startTime: startTime,
      endTime: endTime,
      location: location,
      instructor: instructor,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  // Save events to local storage
  static Future<void> saveEvents(List<CalendarEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = jsonEncode(events.map((e) => e.toJson()).toList());
      await prefs.setString(_eventsKey, eventsJson);
    } catch (e) {
      debugPrint('Error saving events: $e');
      rethrow;
    }
  }

  // Load events from local storage
  static Future<List<CalendarEvent>> loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to load new format first
      final eventsJson = prefs.getString(_eventsKey);
      if (eventsJson != null) {
        final List<dynamic> eventsList = jsonDecode(eventsJson);
        return eventsList.map((e) => CalendarEvent.fromJson(e)).toList();
      }
      
      // Fallback to legacy format and migrate
      final legacyJson = prefs.getString(_scheduleKey);
      if (legacyJson != null) {
        final List<dynamic> legacyList = jsonDecode(legacyJson);
        final migratedEvents = legacyList.map((e) => _migrateFromLegacyFormat(e)).toList();
        
        // Save in new format
        await saveEvents(migratedEvents);
        
        // Remove legacy data
        await prefs.remove(_scheduleKey);
        
        return migratedEvents;
      }
      
      return [];
    } catch (e) {
      debugPrint('Error loading events: $e');
      return [];
    }
  }

  // Migrate from legacy format
  static CalendarEvent _migrateFromLegacyFormat(Map<String, dynamic> legacy) {
    return CalendarEvent(
      id: legacy['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: legacy['classType'] ?? 'Class',
      type: CalendarEventType.recurringClass,
      classType: legacy['classType'] ?? 'BJJ',
      dayOfWeek: legacy['dayOfWeek'],
      startTime: legacy['startTime'] ?? '18:00',
      endTime: legacy['endTime'] ?? '19:00',
      location: legacy['location'],
      instructor: legacy['instructor'],
      notes: legacy['notes'],
      createdAt: legacy['createdAt'] != null 
          ? DateTime.parse(legacy['createdAt']) 
          : DateTime.now(),
    );
  }

  // Add a new event
  static Future<void> addEvent(CalendarEvent event) async {
    try {
      final events = await loadEvents();
      events.add(event);
      await saveEvents(events);
    } catch (e) {
      debugPrint('Error adding event: $e');
      rethrow;
    }
  }

  // Update an existing event
  static Future<void> updateEvent(String eventId, CalendarEvent updatedEvent) async {
    try {
      final events = await loadEvents();
      final index = events.indexWhere((event) => event.id == eventId);
      
      if (index != -1) {
        events[index] = updatedEvent.copyWith();
        await saveEvents(events);
      }
    } catch (e) {
      debugPrint('Error updating event: $e');
      rethrow;
    }
  }

  // Delete an event
  static Future<void> deleteEvent(String eventId) async {
    try {
      final events = await loadEvents();
      events.removeWhere((event) => event.id == eventId);
      await saveEvents(events);
    } catch (e) {
      debugPrint('Error deleting event: $e');
      rethrow;
    }
  }

  // Get events for a specific date
  static Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      final events = await loadEvents();
      final eventsForDate = <CalendarEvent>[];
      
      for (final event in events) {
        if (event.type == CalendarEventType.dropInEvent) {
          // Check if drop-in event is on this specific date
          if (event.specificDate != null && 
              event.specificDate!.year == date.year &&
              event.specificDate!.month == date.month &&
              event.specificDate!.day == date.day) {
            eventsForDate.add(event);
          }
        } else if (event.type == CalendarEventType.recurringClass) {
          // Check if recurring class occurs on this day of week and within date range
          final checkDate = DateTime(date.year, date.month, date.day);
          final startDate = event.recurringStartDate != null 
              ? DateTime(event.recurringStartDate!.year, event.recurringStartDate!.month, event.recurringStartDate!.day)
              : DateTime(event.createdAt.year, event.createdAt.month, event.createdAt.day);
          
          // Check if date is in range and not deleted
          final dateString = checkDate.toIso8601String().split('T')[0]; // YYYY-MM-DD format
          final isInDateRange = !checkDate.isBefore(startDate) && 
              (event.recurringEndDate == null || !checkDate.isAfter(
                  DateTime(event.recurringEndDate!.year, event.recurringEndDate!.month, event.recurringEndDate!.day)));
          final isNotDeleted = !event.deletedInstances.contains(dateString);
          
          if (event.dayOfWeek == date.weekday && isInDateRange && isNotDeleted) {
            eventsForDate.add(event);
          }
        }
      }
      
      // Sort by start time
      eventsForDate.sort((a, b) => a.startTime.compareTo(b.startTime));
      return eventsForDate;
    } catch (e) {
      debugPrint('Error getting events for date: $e');
      return [];
    }
  }

  // Get events for a week
  static Future<Map<DateTime, List<CalendarEvent>>> getEventsForWeek(DateTime weekStart) async {
    try {
      final weekEvents = <DateTime, List<CalendarEvent>>{};
      
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateKey = DateTime(date.year, date.month, date.day);
        weekEvents[dateKey] = await getEventsForDate(date);
      }
      
      return weekEvents;
    } catch (e) {
      debugPrint('Error getting events for week: $e');
      return {};
    }
  }

  // Get events for a month
  static Future<Map<DateTime, List<CalendarEvent>>> getEventsForMonth(DateTime month) async {
    try {
      final monthEvents = <DateTime, List<CalendarEvent>>{};
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      
      for (int day = firstDay.day; day <= lastDay.day; day++) {
        final date = DateTime(month.year, month.month, day);
        final events = await getEventsForDate(date);
        if (events.isNotEmpty) {
          monthEvents[date] = events;
        }
      }
      
      return monthEvents;
    } catch (e) {
      debugPrint('Error getting events for month: $e');
      return {};
    }
  }

  // Get upcoming classes (next 7 days) - Updated for new format
  static Future<List<Map<String, dynamic>>> getUpcomingClasses() async {
    try {
      final events = await loadEvents();
      final now = DateTime.now();
      List<Map<String, dynamic>> upcomingClasses = [];
      
      // Check next 7 days
      for (int i = 0; i < 7; i++) {
        final dateToCheck = now.add(Duration(days: i));
        final eventsForDate = await getEventsForDate(dateToCheck);
        
        for (final event in eventsForDate) {
          // Parse start time and check if it's in the future (for today)
          final startTimeParts = event.startTime.split(':');
          final classDateTime = DateTime(
            dateToCheck.year,
            dateToCheck.month,
            dateToCheck.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
          );
          
          // Only include future classes
          if (classDateTime.isAfter(now)) {
            upcomingClasses.add({
              'id': event.id,
              'classType': event.classType,
              'dayOfWeek': event.dayOfWeek ?? dateToCheck.weekday,
              'startTime': event.startTime,
              'endTime': event.endTime,
              'location': event.location ?? '',
              'instructor': event.instructor ?? '',
              'notes': event.notes ?? '',
              'date': dateToCheck.toIso8601String().split('T')[0],
              'dateTime': classDateTime.toIso8601String(),
              'type': event.type.name,
            });
          }
        }
      }
      
      // Sort by date and time
      upcomingClasses.sort((a, b) {
        final dateTimeA = DateTime.parse(a['dateTime']);
        final dateTimeB = DateTime.parse(b['dateTime']);
        return dateTimeA.compareTo(dateTimeB);
      });
      
      return upcomingClasses;
    } catch (e) {
      debugPrint('Error getting upcoming classes: $e');
      return [];
    }
  }

  // Clear all events
  static Future<void> clearEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);
    } catch (e) {
      debugPrint('Error clearing events: $e');
      rethrow;
    }
  }

  // Delete a single instance of a recurring event
  static Future<void> deleteRecurringEventInstance(String eventId, DateTime date) async {
    try {
      final events = await loadEvents();
      final eventIndex = events.indexWhere((e) => e.id == eventId);
      
      if (eventIndex != -1) {
        final event = events[eventIndex];
        if (event.type == CalendarEventType.recurringClass) {
          final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
          final updatedDeletedInstances = List<String>.from(event.deletedInstances);
          
          if (!updatedDeletedInstances.contains(dateString)) {
            updatedDeletedInstances.add(dateString);
            
            final updatedEvent = event.copyWith(
              deletedInstances: updatedDeletedInstances,
            );
            
            events[eventIndex] = updatedEvent;
            await saveEvents(events);
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting recurring event instance: $e');
      rethrow;
    }
  }

  // Delete all instances of a recurring event from a specific date forward
  static Future<void> deleteRecurringEventFromDate(String eventId, DateTime fromDate) async {
    try {
      final events = await loadEvents();
      final eventIndex = events.indexWhere((e) => e.id == eventId);
      
      if (eventIndex != -1) {
        final event = events[eventIndex];
        if (event.type == CalendarEventType.recurringClass) {
          // Set the end date to the day before the deletion date
          final endDate = fromDate.subtract(const Duration(days: 1));
          
          final updatedEvent = event.copyWith(
            recurringEndDate: endDate,
          );
          
          events[eventIndex] = updatedEvent;
          await saveEvents(events);
        }
      }
    } catch (e) {
      debugPrint('Error deleting recurring event from date: $e');
      rethrow;
    }
  }

  // Legacy methods for backward compatibility
  
  @deprecated
  static Map<String, dynamic> createScheduleEntry({
    required String classType,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? notes,
    String? location,
    String? instructor,
  }) {
    final event = createRecurringClass(
      classType: classType,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      location: location,
      instructor: instructor,
      notes: notes,
    );
    return event.toJson();
  }

  @deprecated
  static Future<void> saveSchedule(List<Map<String, dynamic>> schedule) async {
    try {
      final events = schedule.map((s) => _migrateFromLegacyFormat(s)).toList();
      await saveEvents(events);
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      rethrow;
    }
  }

  @deprecated
  static Future<List<Map<String, dynamic>>> loadSchedule() async {
    try {
      final events = await loadEvents();
      return events
          .where((e) => e.type == CalendarEventType.recurringClass)
          .map((e) => e.toJson())
          .toList();
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      return [];
    }
  }

  @deprecated
  static Future<void> addScheduleEntry(Map<String, dynamic> entry) async {
    try {
      final event = _migrateFromLegacyFormat(entry);
      await addEvent(event);
    } catch (e) {
      debugPrint('Error adding schedule entry: $e');
      rethrow;
    }
  }

  @deprecated
  static Future<void> updateScheduleEntry(String entryId, Map<String, dynamic> updatedEntry) async {
    try {
      final event = _migrateFromLegacyFormat({...updatedEntry, 'id': entryId});
      await updateEvent(entryId, event);
    } catch (e) {
      debugPrint('Error updating schedule entry: $e');
      rethrow;
    }
  }

  @deprecated
  static Future<void> deleteScheduleEntry(String entryId) async {
    try {
      await deleteEvent(entryId);
    } catch (e) {
      debugPrint('Error deleting schedule entry: $e');
      rethrow;
    }
  }

  @deprecated
  static Future<List<Map<String, dynamic>>> getScheduleForDay(int dayOfWeek) async {
    try {
      final events = await loadEvents();
      return events
          .where((e) => e.type == CalendarEventType.recurringClass && e.dayOfWeek == dayOfWeek)
          .map((e) => e.toJson())
          .toList();
    } catch (e) {
      debugPrint('Error getting schedule for day: $e');
      return [];
    }
  }

  @deprecated
  static Future<void> clearSchedule() async {
    await clearEvents();
  }

  // Utility methods
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