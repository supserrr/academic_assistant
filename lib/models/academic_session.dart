import 'package:flutter/material.dart';

enum SessionType {
  classSession,
  masterySession,
  studyGroup,
  pslMeeting;

  String get label {
    switch (this) {
      case SessionType.classSession:
        return 'Class';
      case SessionType.masterySession:
        return 'Mastery Session';
      case SessionType.studyGroup:
        return 'Study Group';
      case SessionType.pslMeeting:
        return 'PSL Meeting';
    }
  }

  static SessionType fromString(String value) {
    switch (value) {
      case 'classSession':
        return SessionType.classSession;
      case 'masterySession':
        return SessionType.masterySession;
      case 'studyGroup':
        return SessionType.studyGroup;
      case 'pslMeeting':
        return SessionType.pslMeeting;
      default:
        return SessionType.classSession;
    }
  }
}

enum AttendanceStatus {
  present,
  absent;

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }
}

class AcademicSession {
  AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.sessionType = SessionType.classSession,
    this.attendance,
  });

  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final SessionType sessionType;
  final AttendanceStatus? attendance;

  // Immutable update for attendance/session edits without mutating the original
  AcademicSession copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    SessionType? sessionType,
    AttendanceStatus? attendance,
  }) {
    return AcademicSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      sessionType: sessionType ?? this.sessionType,
      attendance: attendance ?? this.attendance,
    );
  }

  // For persistence: date/time as ISO-style strings so we can parse back in fromJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String().split('T').first,
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'location': location,
      'sessionType': sessionType.name,
      'attendance': attendance?.name,
    };
  }

  // Reconstruct from stored JSON; parse time strings "HH:mm" back to TimeOfDay
  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    final startParts = (json['startTime'] as String).split(':');
    final endParts = (json['endTime'] as String).split(':');
    return AcademicSession(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      location: json['location'] as String?,
      sessionType: SessionType.fromString(json['sessionType'] as String? ?? 'class'),
      attendance: json['attendance'] != null
          ? (json['attendance'] == 'present'
              ? AttendanceStatus.present
              : AttendanceStatus.absent)
          : null,
    );
  }
}
