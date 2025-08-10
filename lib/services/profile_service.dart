import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _selectedStylesKey = 'ghost_selected_martial_arts_styles';
  static const String _profileDataKey = 'ghost_profile_data';

  // Save selected martial arts styles
  static Future<void> saveSelectedStyles(List<String> selectedStyles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedStylesKey, selectedStyles);
  }

  // Load selected martial arts styles
  static Future<List<String>> loadSelectedStyles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_selectedStylesKey) ?? [];
  }

  // Save complete profile data
  static Future<void> saveProfileData(Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileDataKey, jsonEncode(profileData));
  }

  // Load profile data from local storage
  static Future<Map<String, dynamic>> loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('profile_data');
      
      if (profileJson != null) {
        return Map<String, dynamic>.from(jsonDecode(profileJson));
      }
      
      return {};
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error loading profile data: $e');
      return {};
    }
  }

  // Clear all profile data
  static Future<void> clearProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedStylesKey);
    await prefs.remove(_profileDataKey);
  }
} 