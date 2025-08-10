import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstructorService {
  static const String _instructorsKey = 'instructors';

  // Save instructors to local storage
  static Future<void> saveInstructors(List<Map<String, dynamic>> instructors) async {
    final prefs = await SharedPreferences.getInstance();
    final instructorsJson = jsonEncode(instructors);
    await prefs.setString(_instructorsKey, instructorsJson);
  }

  // Load instructors from local storage
  static Future<List<Map<String, dynamic>>> loadInstructors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final instructorsJson = prefs.getString(_instructorsKey);
      
      if (instructorsJson != null) {
        final List<dynamic> instructorsList = jsonDecode(instructorsJson);
        return instructorsList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error loading instructors: $e');
      return [];
    }
  }

  // Add a new instructor
  static Future<void> addInstructor(Map<String, dynamic> instructor) async {
    final instructors = await loadInstructors();
    instructors.add(instructor);
    await saveInstructors(instructors);
  }

  // Update an existing instructor
  static Future<void> updateInstructor(int index, Map<String, dynamic> instructor) async {
    final instructors = await loadInstructors();
    if (index >= 0 && index < instructors.length) {
      instructors[index] = instructor;
      await saveInstructors(instructors);
    }
  }

  // Delete an instructor
  static Future<void> deleteInstructor(int index) async {
    final instructors = await loadInstructors();
    if (index >= 0 && index < instructors.length) {
      instructors.removeAt(index);
      await saveInstructors(instructors);
    }
  }

  // Clear all instructors
  static Future<void> clearInstructors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_instructorsKey);
  }

  // Get instructors for a specific martial arts style
  static Future<List<Map<String, dynamic>>> getInstructorsForStyle(String style) async {
    final instructors = await loadInstructors();
    return instructors.where((instructor) => instructor['style'] == style).toList();
  }

  // Get all instructor names for a specific style (useful for dropdowns)
  static Future<List<String>> getInstructorNamesForStyle(String style) async {
    final instructors = await getInstructorsForStyle(style);
    return instructors.map((instructor) => instructor['name'] as String).toList();
  }

  // Get primary instructor for a style (first one in the list)
  static Future<String?> getPrimaryInstructorForStyle(String style) async {
    final instructorNames = await getInstructorNamesForStyle(style);
    return instructorNames.isNotEmpty ? instructorNames.first : null;
  }
} 