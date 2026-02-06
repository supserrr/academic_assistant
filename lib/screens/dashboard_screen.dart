import 'package:flutter/material.dart';

import '../models/academic_session.dart';
import '../models/assignment.dart';

// First tab: greeting, date/week, today's sessions, assignments due in 7 days, attendance %, warning
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.studentName,
    required this.assignments,
    required this.sessions,
  });

  final String? studentName;
  final List<Assignment> assignments;
  final List<AcademicSession> sessions;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // Human-readable date: Today/Tomorrow/Yesterday or "Monday, Jan 5"
  static String _formatDateHuman(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dDate = DateTime(d.year, d.month, d.day);
    final diff = dDate.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  static String _greetingBase() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _greetingWithName() {
    final base = _greetingBase();
    final name = studentName?.trim();
    if (name != null && name.isNotEmpty) return '$base, $name';
    return base;
  }

  static String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // Week number from start of year (1-based) for display
  int get _academicWeek {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return (now.difference(startOfYear).inDays / 7).floor() + 1;
  }

  // Sessions for today only, sorted by start time (earliest first)
  List<AcademicSession> get _todaySessions {
    final now = DateTime.now();
    return sessions.where((s) {
      return s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day;
    }).toList()
      ..sort((a, b) {
        final am = a.startTime.hour * 60 + a.startTime.minute;
        final bm = b.startTime.hour * 60 + b.startTime.minute;
        return am.compareTo(bm);
      });
  }

  // Filter: incomplete only, due date in [today, today+6] (inclusive 7-day window), then sort by due
  List<Assignment> get _assignmentsDueNext7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOf7Days = today.add(const Duration(days: 6));
    return assignments
        .where((a) {
          if (a.completed) return false;
          final due = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
          return !due.isBefore(today) && !due.isAfter(endOf7Days);
        })
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // True when at least one session has attendance set
  bool get _hasAttendanceRecorded {
    return sessions.any((s) => s.attendance != null);
  }

  // Percentage of sessions marked present among those with attendance set; null when none recorded
  double? get _attendancePercentage {
    final withAttendance = sessions.where((s) => s.attendance != null).toList();
    if (withAttendance.isEmpty) return null;
    final present = withAttendance.where((s) => s.attendance == AttendanceStatus.present).length;
    return (present / withAttendance.length) * 100;
  }

  int get _pendingAssignmentCount {
    return assignments.where((a) => !a.completed).length;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todaySessions = _todaySessions;
    final upcomingAssignments = _assignmentsDueNext7Days;
    final attendancePercent = _attendancePercentage;
    final hasAttendanceRecorded = _hasAttendanceRecorded;
    final showWarning = hasAttendanceRecorded && attendancePercent != null && attendancePercent < 75;
    final pendingCount = _pendingAssignmentCount;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greetingWithName(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.surface,
                fontSize: 36,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.error, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDateHuman(now),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Week $_academicWeek · ${_formatDate(now)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (showWarning) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.onError, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AT RISK: Attendance below 75%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.percent,
                    label: 'Attendance',
                    value: hasAttendanceRecorded && attendancePercent != null
                        ? '${attendancePercent.toStringAsFixed(0)}%'
                        : 'N/A',
                    valueColor: (hasAttendanceRecorded &&
                            attendancePercent != null &&
                            attendancePercent < 75)
                        ? colorScheme.error
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.assignment_outlined,
                    label: 'Pending',
                    value: '$pendingCount',
                    valueColor: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SectionHeader(icon: Icons.schedule, title: "Today's sessions"),
            const SizedBox(height: 10),
            if (todaySessions.isEmpty)
              _EmptySectionCard(
                icon: Icons.event_available,
                title: "No sessions today",
                subtitle: "Add sessions in the Schedule tab to see them here.",
              )
            else
              ...todaySessions.map(
                (s) => _SessionListTile(
                  title: s.title,
                  subtitle: '${_formatTime(s.startTime)} – ${_formatTime(s.endTime)} · ${s.sessionType.label}',
                ),
              ),
            const SizedBox(height: 24),
            _SectionHeader(icon: Icons.assignment_late, title: 'Due in next 7 days'),
            const SizedBox(height: 10),
            if (upcomingAssignments.isEmpty)
              _EmptySectionCard(
                icon: Icons.assignment_outlined,
                title: "Nothing due in the next 7 days",
                subtitle: "Assignments due soon will show up here.",
              )
            else
              ...upcomingAssignments.map(
                (a) {
                  final due = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
                  final today = DateTime(now.year, now.month, now.day);
                  final diff = due.difference(today).inDays;
                  final dueLabel = diff == 0 ? 'Due today' : (diff == 1 ? 'Due tomorrow' : null);
                  return _AssignmentListTile(
                    title: a.title,
                    subtitle: '${a.courseName} · ${_formatDateHuman(a.dueDate)}',
                    dueBadge: dueLabel,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.error, size: 24),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentListTile extends StatelessWidget {
  const _AssignmentListTile({
    required this.title,
    required this.subtitle,
    this.dueBadge,
  });

  final String title;
  final String subtitle;
  final String? dueBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.assignment_outlined, color: colorScheme.error, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dueBadge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dueBadge!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 11,
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
