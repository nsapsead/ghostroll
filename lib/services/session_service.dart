import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class SessionService {
  static const String _sessionsKey = 'training_sessions';

  // Create a session from a calendar event (when user attends)
  static Session createSessionFromCalendarEvent({
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

  // Save all sessions to local storage
  static Future<void> saveSessions(List<Session> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_sessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving sessions: $e');
      rethrow;
    }
  }

  // Load all sessions from local storage
  static Future<List<Session>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);
      
      if (sessionsJson != null) {
        final List<dynamic> sessionsList = jsonDecode(sessionsJson);
        return sessionsList.map((s) => Session.fromJson(s)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  // Add a new session
  static Future<void> addSession(Session session) async {
    try {
      final sessions = await loadSessions();
      sessions.add(session);
      
      // Sort sessions by date (newest first)
      sessions.sort((a, b) => b.date.compareTo(a.date));
      
      await saveSessions(sessions);
    } catch (e) {
      print('Error adding session: $e');
      rethrow;
    }
  }

  // Update an existing session
  static Future<void> updateSession(Session updatedSession) async {
    try {
      final sessions = await loadSessions();
      final index = sessions.indexWhere((s) => s.id == updatedSession.id);
      
      if (index != -1) {
        sessions[index] = updatedSession;
        
        // Sort sessions by date (newest first)
        sessions.sort((a, b) => b.date.compareTo(a.date));
        
        await saveSessions(sessions);
      }
    } catch (e) {
      print('Error updating session: $e');
      rethrow;
    }
  }

  // Delete a session
  static Future<void> deleteSession(String sessionId) async {
    try {
      final sessions = await loadSessions();
      sessions.removeWhere((s) => s.id == sessionId);
      await saveSessions(sessions);
    } catch (e) {
      print('Error deleting session: $e');
      rethrow;
    }
  }

  // Get sessions filtered by date range
  static Future<List<Session>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final sessions = await loadSessions();
      return sessions.where((session) {
        return session.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               session.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error getting sessions by date range: $e');
      return [];
    }
  }

  // Get sessions filtered by class type
  static Future<List<Session>> getSessionsByClassType(ClassType classType) async {
    try {
      final sessions = await loadSessions();
      return sessions.where((session) => session.classType == classType).toList();
    } catch (e) {
      print('Error getting sessions by class type: $e');
      return [];
    }
  }

  // Get sessions filtered by instructor
  static Future<List<Session>> getSessionsByInstructor(String instructor) async {
    try {
      final sessions = await loadSessions();
      return sessions.where((session) => 
        session.instructor?.toLowerCase().contains(instructor.toLowerCase()) == true
      ).toList();
    } catch (e) {
      print('Error getting sessions by instructor: $e');
      return [];
    }
  }

  // Search sessions by technique, notes, or focus area
  static Future<List<Session>> searchSessions(String query) async {
    try {
      final sessions = await loadSessions();
      final lowerQuery = query.toLowerCase();
      
      return sessions.where((session) {
        // Search in techniques learned
        final techniqueMatch = session.techniquesLearned
            .any((technique) => technique.toLowerCase().contains(lowerQuery));
        
        // Search in focus area
        final focusAreaMatch = session.focusArea.toLowerCase().contains(lowerQuery);
        
        // Search in sparring notes
        final sparringNotesMatch = session.sparringNotes?.toLowerCase().contains(lowerQuery) ?? false;
        
        // Search in reflection
        final reflectionMatch = session.reflection?.toLowerCase().contains(lowerQuery) ?? false;
        
        return techniqueMatch || focusAreaMatch || sparringNotesMatch || reflectionMatch;
      }).toList();
    } catch (e) {
      print('Error searching sessions: $e');
      return [];
    }
  }

  // Get training statistics
  static Future<Map<String, dynamic>> getTrainingStats() async {
    try {
      final sessions = await loadSessions();
      
      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'totalHours': 0.0,
          'averageSessionLength': 0.0,
          'classByType': <String, int>{},
          'thisWeekSessions': 0,
          'thisMonthSessions': 0,
        };
      }
      
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      
      final thisWeekSessions = sessions.where((s) => s.date.isAfter(weekStart)).length;
      final thisMonthSessions = sessions.where((s) => s.date.isAfter(monthStart)).length;
      
      final totalMinutes = sessions.fold<int>(0, (sum, session) => sum + session.duration);
      final totalHours = totalMinutes / 60.0;
      final averageSessionLength = totalMinutes / sessions.length;
      
      // Count sessions by class type
      final classByType = <String, int>{};
      for (final session in sessions) {
        final classType = session.classTypeDisplay;
        classByType[classType] = (classByType[classType] ?? 0) + 1;
      }
      
      return {
        'totalSessions': sessions.length,
        'totalHours': totalHours,
        'averageSessionLength': averageSessionLength,
        'classByType': classByType,
        'thisWeekSessions': thisWeekSessions,
        'thisMonthSessions': thisMonthSessions,
      };
    } catch (e) {
      print('Error getting training stats: $e');
      return {};
    }
  }

  // Clear all sessions (for reset/testing)
  static Future<void> clearAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsKey);
    } catch (e) {
      print('Error clearing sessions: $e');
      rethrow;
    }
  }
} 