import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/academic_session.dart';
import '../models/assignment.dart';
import 'storage_service.dart';

// Persists assignments and sessions as JSON strings in shared_preferences.
// Also stores login state (name, email, password) for the auth flow.
class SharedPreferencesStorageService implements StorageService {
  static const _keyAssignments = 'assignments';
  static const _keySessions = 'sessions';

  static const _keyStudentName = 'student_name';
  static const _keyStudentEmail = 'student_email';
  static const _keyStudentPassword = 'student_password';
  static const _keyIsLoggedIn = 'is_logged_in';

  // Load: get string from prefs -> jsonDecode to List -> map each item to Assignment via fromJson
  @override
  Future<List<Assignment>> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyAssignments);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Save: map each Assignment to Json -> jsonEncode list -> setString under key
  @override
  Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final list = assignments.map((e) => e.toJson()).toList();
    await prefs.setString(_keyAssignments, jsonEncode(list));
  }

  // Same pattern as assignments: get string -> jsonDecode -> map to AcademicSession via fromJson
  @override
  Future<List<AcademicSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySessions);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => AcademicSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Same as assignments: toJson list -> jsonEncode -> setString
  @override
  Future<void> saveSessions(List<AcademicSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = sessions.map((e) => e.toJson()).toList();
    await prefs.setString(_keySessions, jsonEncode(list));
  }

  Future<String?> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentName);
  }

  Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> saveCredentials(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStudentName, name);
    await prefs.setString(_keyStudentEmail, email);
    await prefs.setString(_keyStudentPassword, password);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<bool> validateLogin(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyStudentEmail);
    final storedPassword = prefs.getString(_keyStudentPassword);
    if (storedEmail == null || storedPassword == null) return false;
    if (storedEmail != email.trim() || storedPassword != password) return false;
    await prefs.setBool(_keyIsLoggedIn, true);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
