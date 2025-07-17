import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static const String _scheduleKey = 'training_schedule';

  // Schedule entry model
  static Map<String, dynamic> createScheduleEntry({
    required String classType,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required String startTime, // Format: "HH:mm"
    required String endTime,   // Format: "HH:mm"
    String? notes,
    String? location,
    String? instructor,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'classType': classType,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes ?? '',
      'location': location ?? '',
      'instructor': instructor ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Save schedule entries to local storage
  static Future<void> saveSchedule(List<Map<String, dynamic>> schedule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduleJson = jsonEncode(schedule);
      await prefs.setString(_scheduleKey, scheduleJson);
    } catch (e) {
      print('Error saving schedule: $e');
      rethrow;
    }
  }

  // Load schedule entries from local storage
  static Future<List<Map<String, dynamic>>> loadSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduleJson = prefs.getString(_scheduleKey);
      
      if (scheduleJson != null) {
        final List<dynamic> scheduleList = jsonDecode(scheduleJson);
        return scheduleList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('Error loading schedule: $e');
      return [];
    }
  }

  // Add a new schedule entry
  static Future<void> addScheduleEntry(Map<String, dynamic> entry) async {
    try {
      final schedule = await loadSchedule();
      schedule.add(entry);
      await saveSchedule(schedule);
    } catch (e) {
      print('Error adding schedule entry: $e');
      rethrow;
    }
  }

  // Update an existing schedule entry
  static Future<void> updateScheduleEntry(String entryId, Map<String, dynamic> updatedEntry) async {
    try {
      final schedule = await loadSchedule();
      final index = schedule.indexWhere((entry) => entry['id'] == entryId);
      
      if (index != -1) {
        // Preserve the original ID and createdAt
        updatedEntry['id'] = entryId;
        updatedEntry['createdAt'] = schedule[index]['createdAt'];
        updatedEntry['updatedAt'] = DateTime.now().toIso8601String();
        
        schedule[index] = updatedEntry;
        await saveSchedule(schedule);
      }
    } catch (e) {
      print('Error updating schedule entry: $e');
      rethrow;
    }
  }

  // Delete a schedule entry
  static Future<void> deleteScheduleEntry(String entryId) async {
    try {
      final schedule = await loadSchedule();
      schedule.removeWhere((entry) => entry['id'] == entryId);
      await saveSchedule(schedule);
    } catch (e) {
      print('Error deleting schedule entry: $e');
      rethrow;
    }
  }

  // Get schedule entries for a specific day
  static Future<List<Map<String, dynamic>>> getScheduleForDay(int dayOfWeek) async {
    try {
      final schedule = await loadSchedule();
      return schedule.where((entry) => entry['dayOfWeek'] == dayOfWeek).toList();
    } catch (e) {
      print('Error getting schedule for day: $e');
      return [];
    }
  }

  // Get upcoming classes (next 7 days)
  static Future<List<Map<String, dynamic>>> getUpcomingClasses() async {
    try {
      final schedule = await loadSchedule();
      final now = DateTime.now();
      final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
      
      List<Map<String, dynamic>> upcomingClasses = [];
      
      // Check next 7 days
      for (int i = 0; i < 7; i++) {
        final dayToCheck = ((currentDayOfWeek - 1 + i) % 7) + 1; // Convert to 1-7 range
        final dateToCheck = now.add(Duration(days: i));
        
        final dayClasses = schedule.where((entry) => entry['dayOfWeek'] == dayToCheck).toList();
        
        for (final classEntry in dayClasses) {
          // Parse start time and check if it's in the future (for today)
          final startTimeParts = classEntry['startTime'].split(':');
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
              ...classEntry,
              'date': dateToCheck.toIso8601String().split('T')[0], // YYYY-MM-DD format
              'dateTime': classDateTime.toIso8601String(),
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
      print('Error getting upcoming classes: $e');
      return [];
    }
  }

  // Clear all schedule entries
  static Future<void> clearSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduleKey);
    } catch (e) {
      print('Error clearing schedule: $e');
      rethrow;
    }
  }

  // Get day name from day number
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

  // Format time for display
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
} 