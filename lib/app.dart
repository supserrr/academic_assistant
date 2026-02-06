import 'package:flutter/material.dart';

import 'models/academic_session.dart';
import 'models/assignment.dart';
import 'screens/assignments_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/schedule_screen.dart';
import 'services/storage_service.dart';
import 'services/shared_preferences_storage.dart';

// Main app shell: bottom nav with 3 tabs. We keep assignments and sessions here
// so there is a single source of truth; screens get copies and callbacks to mutate.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.studentName});

  final String? studentName;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final List<Assignment> _assignments = [];
  final List<AcademicSession> _sessions = [];
  final StorageService _storage = SharedPreferencesStorageService();

  @override
  void initState() {
    super.initState();
    _loadData(); // load from storage so data persists across app restarts
  }

  Future<void> _loadData() async {
    final assignments = await _storage.loadAssignments();
    final sessions = await _storage.loadSessions();
    if (mounted) {
      setState(() {
        _assignments.clear();
        _assignments.addAll(assignments);
        _sessions.clear();
        _sessions.addAll(sessions);
      });
    }
  }

  // Save after every mutation so we never lose data if the app is closed
  void _addAssignment(Assignment a) {
    setState(() => _assignments.add(a));
    _storage.saveAssignments(_assignments);
  }

  void _updateAssignment(Assignment a) {
    setState(() {
      final i = _assignments.indexWhere((x) => x.id == a.id);
      if (i >= 0) _assignments[i] = a;
    });
    _storage.saveAssignments(_assignments);
  }

  void _removeAssignment(String id) {
    setState(() => _assignments.removeWhere((a) => a.id == id));
    _storage.saveAssignments(_assignments);
  }

  void _toggleAssignmentCompleted(String id) {
    setState(() {
      final i = _assignments.indexWhere((a) => a.id == id);
      if (i >= 0) {
        _assignments[i] = _assignments[i].copyWith(completed: !_assignments[i].completed);
      }
    });
    _storage.saveAssignments(_assignments);
  }

  void _addSession(AcademicSession s) {
    setState(() => _sessions.add(s));
    _storage.saveSessions(_sessions);
  }

  void _updateSession(AcademicSession s) {
    setState(() {
      final i = _sessions.indexWhere((x) => x.id == s.id);
      if (i >= 0) _sessions[i] = s;
    });
    _storage.saveSessions(_sessions);
  }

  void _removeSession(String id) {
    setState(() => _sessions.removeWhere((s) => s.id == id));
    _storage.saveSessions(_sessions);
  }

  void _setSessionAttendance(String id, AttendanceStatus status) {
    setState(() {
      final i = _sessions.indexWhere((s) => s.id == id);
      if (i >= 0) {
        _sessions[i] = _sessions[i].copyWith(attendance: status);
      }
    });
    _storage.saveSessions(_sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: _currentIndex == 0
            ? 'Dashboard'
            : _currentIndex == 1
                ? 'Assignments'
                : 'Schedule',
        child: IndexedStack(
          index: _currentIndex,
          children: [
          DashboardScreen(
            studentName: widget.studentName,
            assignments: List.from(_assignments),
            sessions: List.from(_sessions),
          ),
          AssignmentsScreen(
            assignments: List.from(_assignments),
            onAddAssignment: _addAssignment,
            onUpdateAssignment: _updateAssignment,
            onRemoveAssignment: _removeAssignment,
            onToggleCompleted: _toggleAssignmentCompleted,
          ),
          ScheduleScreen(
            sessions: List.from(_sessions),
            onAddSession: _addSession,
            onUpdateSession: _updateSession,
            onRemoveSession: _removeSession,
            onSetAttendance: _setSessionAttendance,
          ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
