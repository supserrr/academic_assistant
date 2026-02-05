// Used when saving/loading from storage (fromString) and for display (label)
enum AssignmentPriority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case AssignmentPriority.high:
        return 'High';
      case AssignmentPriority.medium:
        return 'Medium';
      case AssignmentPriority.low:
        return 'Low';
    }
  }

  static AssignmentPriority? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'high':
        return AssignmentPriority.high;
      case 'medium':
        return AssignmentPriority.medium;
      case 'low':
        return AssignmentPriority.low;
      default:
        return null;
    }
  }
}

// Model for one assignment. toJson/fromJson so we can persist as JSON in shared_preferences.
class Assignment {
  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority,
    this.completed = false,
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final AssignmentPriority? priority;
  final bool completed;

  // Immutable update: returns a new Assignment with only the given fields changed
  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? courseName,
    AssignmentPriority? priority,
    bool? completed,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
    );
  }

  // For persistence: we store a list of these maps as JSON in shared_preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority?.name,
      'completed': completed,
    };
  }

  // Reconstruct from stored JSON (used when loading from shared_preferences)
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      courseName: json['courseName'] as String,
      priority: json['priority'] != null
          ? AssignmentPriority.fromString(json['priority'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
