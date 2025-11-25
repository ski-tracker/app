import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/response/activity_response.dart';
import '../../data/model/response/location_response.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/enum/activity_type.dart';

/// Service for managing local storage of activities
interface class LocalStorageService {
  static const String _activitiesKey = 'local_activities';
  static const String _usersKey = 'local_users';

  /// Get all activities from local storage
  static Future<List<Activity>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey);
    
    if (activitiesJson == null) {
      return [];
    }

    try {
      final List<dynamic> activitiesList = jsonDecode(activitiesJson);
      return activitiesList
          .map((item) {
            final map = item as Map<String, dynamic>;
            // Ensure locations are properly formatted
            if (map['locations'] != null) {
              map['locations'] = (map['locations'] as List).map((loc) {
                if (loc is Map<String, dynamic>) {
                  return loc;
                }
                return loc;
              }).toList();
            }
            return ActivityResponse.fromMap(map).toEntity();
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save an activity to local storage
  static Future<void> saveActivity(Activity activity) async {
    final activities = await getActivities();
    
    // Check if activity already exists (update) or add new
    final existingIndex = activities.indexWhere((a) => a.id == activity.id);
    
    if (existingIndex != -1) {
      activities[existingIndex] = activity;
    } else {
      activities.add(activity);
    }

    await _saveActivities(activities);
  }

  /// Delete an activity from local storage
  static Future<void> deleteActivity(String id) async {
    final activities = await getActivities();
    activities.removeWhere((activity) => activity.id == id);
    await _saveActivities(activities);
  }

  /// Save activities list to storage
  static Future<void> _saveActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert activities to JSON format
    final activitiesJson = activities.map((activity) {
      return {
        'id': activity.id,
        'type': activity.type.name.toUpperCase(),
        'startDatetime': activity.startDatetime.toIso8601String(),
        'endDatetime': activity.endDatetime.toIso8601String(),
        'distance': activity.distance,
        'speed': activity.speed,
        'time': activity.time,
        'locations': activity.locations.map((loc) => {
          'id': loc.id,
          'datetime': loc.datetime.toIso8601String(),
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        }).toList(),
      };
    }).toList();

    await prefs.setString(_activitiesKey, jsonEncode(activitiesJson));
  }

  /// Get activity by ID from local storage
  static Future<Activity?> getActivityById(String id) async {
    final activities = await getActivities();
    try {
      return activities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if a user exists in local storage
  static Future<bool> userExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null) {
      return false;
    }

    try {
      final Map<String, dynamic> users = jsonDecode(usersJson);
      return users.containsKey(username);
    } catch (e) {
      return false;
    }
  }

  /// Register a new user in local storage
  static Future<int> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      try {
        users = jsonDecode(usersJson);
      } catch (e) {
        users = {};
      }
    }

    // Store user (in real app, password should be hashed)
    users[username] = {
      'username': username,
      'password': password, // In production, hash this!
      'createdAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_usersKey, jsonEncode(users));
    return users.length; // Return user count as ID
  }

  /// Verify user credentials
  static Future<bool> verifyUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null) {
      return false;
    }

    try {
      final Map<String, dynamic> users = jsonDecode(usersJson);
      final user = users[username];
      
      if (user == null) {
        return false;
      }

      // In production, compare hashed passwords
      return user['password'] == password;
    } catch (e) {
      return false;
    }
  }

  /// Clear all local data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
    await prefs.remove(_usersKey);
  }
}

