import 'package:flutter/material.dart';

import '../models/academic_session.dart';

// Third tab: list of sessions by date, FAB to add, tap to edit, chips for Present/Absent
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onAddSession,
    required this.onUpdateSession,
    required this.onRemoveSession,
    required this.onSetAttendance,
  });

  final List<AcademicSession> sessions;
  final void Function(AcademicSession) onAddSession;
  final void Function(AcademicSession) onUpdateSession;
  final void Function(String id) onRemoveSession;
  final void Function(String id, AttendanceStatus status) onSetAttendance;

  List<AcademicSession> get _sortedSessions {
    final list = List<AcademicSession>.from(sessions);
    list.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });
    return list;
  }

  // Same pattern as assignments: one dialog for add and edit, pass existing or null
  Future<void> _openForm(BuildContext context, [AcademicSession? existing]) async {
    final result = await showDialog<AcademicSession>(
      context: context,
      builder: (context) => _SessionFormDialog(existing: existing),
    );
    if (result == null || !context.mounted) return;
    if (existing != null) {
      onUpdateSession(result);
    } else {
      onAddSession(result);
    }
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedSessions;
    final theme = Theme.of(context);
    final count = sorted.length;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Schedule'),
            if (count > 0)
              Text(
                count == 1 ? '1 session' : '$count sessions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.surface,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: sorted.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 72,
                      color: theme.colorScheme.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No sessions scheduled',
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.surface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a session',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.surface),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final s = sorted[index];
                bool showDateHeader;
                if (index == 0) {
                  showDateHeader = true;
                } else {
                  final prev = sorted[index - 1].date;
                  showDateHeader = prev.year != s.date.year ||
                      prev.month != s.date.month ||
                      prev.day != s.date.day;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: theme.colorScheme.error, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(s.date),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    _SessionCard(
                      session: s,
                      formatTime: _formatTime,
                      onEdit: () => _openForm(context, s),
                      onRemove: () => onRemoveSession(s.id),
                      onSetAttendance: onSetAttendance,
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: Semantics(
        label: 'Add session',
        button: true,
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.formatTime,
    required this.onEdit,
    required this.onRemove,
    required this.onSetAttendance,
  });

  final AcademicSession session;
  final String Function(TimeOfDay) formatTime;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final void Function(String id, AttendanceStatus status) onSetAttendance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = session;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 52,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.sessionType.label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatTime(s.startTime)} – ${formatTime(s.endTime)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (s.location != null && s.location!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          s.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20, color: colorScheme.error),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Text(
                  'Attendance: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('Present'),
                  selected: s.attendance == AttendanceStatus.present,
                  onSelected: (_) => onSetAttendance(s.id, AttendanceStatus.present),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Absent'),
                  selected: s.attendance == AttendanceStatus.absent,
                  onSelected: (_) => onSetAttendance(s.id, AttendanceStatus.absent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionFormDialog extends StatefulWidget {
  const _SessionFormDialog({this.existing});

  final AcademicSession? existing;

  @override
  State<_SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<_SessionFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  SessionType _sessionType = SessionType.classSession;
  String? _titleError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _locationController = TextEditingController(text: widget.existing?.location ?? '');
    _date = widget.existing?.date ?? DateTime.now();
    _startTime = widget.existing?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.existing?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _sessionType = widget.existing?.sessionType ?? SessionType.classSession;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.error,
              onPrimary: colorScheme.onError,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.error,
              onPrimary: colorScheme.onError,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.error,
              onPrimary: colorScheme.onError,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }
    final startMin = _startTime.hour * 60 + _startTime.minute;
    final endMin = _endTime.hour * 60 + _endTime.minute;
    if (endMin <= startMin) {
      setState(() => _timeError = 'End time must be after start time');
      return;
    }
    setState(() {
      _titleError = null;
      _timeError = null;
    });
    final id = widget.existing?.id ?? 's_${DateTime.now().millisecondsSinceEpoch}';
    final s = AcademicSession(
      id: id,
      title: title,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      sessionType: _sessionType,
      attendance: widget.existing?.attendance,
    );
    Navigator.of(context).pop(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        widget.existing != null ? 'Edit session' : 'New session',
        style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Session title (required)',
                errorText: _titleError,
              ),
              onChanged: (_) => setState(() => _titleError = null),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              ),
              trailing: Icon(Icons.calendar_today, color: theme.colorScheme.error),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start time'),
              subtitle: Text(
                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Icon(Icons.access_time, color: theme.colorScheme.error),
              onTap: _pickStartTime,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End time'),
              subtitle: Text(
                '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Icon(Icons.access_time, color: theme.colorScheme.error),
              onTap: _pickEndTime,
            ),
            if (_timeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _timeError!,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location (optional)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SessionType>(
              initialValue: _sessionType,
              decoration: const InputDecoration(labelText: 'Session type'),
              items: SessionType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _sessionType = v ?? SessionType.classSession),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}