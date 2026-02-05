import 'package:flutter/material.dart';

import '../models/assignment.dart';

// Second tab: list of assignments (ListView), FAB to add, tap to edit, checkbox to complete, menu to remove
class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({
    super.key,
    required this.assignments,
    required this.onAddAssignment,
    required this.onUpdateAssignment,
    required this.onRemoveAssignment,
    required this.onToggleCompleted,
  });

  final List<Assignment> assignments;
  final void Function(Assignment) onAddAssignment;
  final void Function(Assignment) onUpdateAssignment;
  final void Function(String id) onRemoveAssignment;
  final void Function(String id) onToggleCompleted;

  List<Assignment> get _sortedAssignments {
    final list = List<Assignment>.from(assignments);
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  // One dialog for both add and edit: pass existing assignment or null; result is the saved model
  Future<void> _openForm(BuildContext context, [Assignment? existing]) async {
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => _AssignmentFormDialog(existing: existing),
    );
    if (result == null || !context.mounted) return;
    if (existing != null) {
      onUpdateAssignment(result);
    } else {
      onAddAssignment(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedAssignments;
    final theme = Theme.of(context);
    final count = sorted.length;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Assignments'),
            if (count > 0)
              Text(
                count == 1 ? '1 assignment' : '$count assignments',
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
                      Icons.assignment_outlined,
                      size: 72,
                      color: theme.colorScheme.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No assignments yet',
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.surface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first assignment',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.surface),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: sorted.length,
              // ListView.builder builds only visible items for better performance with long lists
              itemBuilder: (context, index) {
                final a = sorted[index];
                final due = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
                final today = DateTime.now();
                final t = DateTime(today.year, today.month, today.day);
                final diff = due.difference(t).inDays;
                final dueBadge = diff == 0 ? 'Due today' : (diff == 1 ? 'Due tomorrow' : null);
                return _AssignmentCard(
                  assignment: a,
                  dueBadge: dueBadge,
                  onToggleCompleted: () => onToggleCompleted(a.id),
                  onEdit: () => _openForm(context, a),
                  onRemove: () => onRemoveAssignment(a.id),
                  formatDate: _formatDate,
                );
              },
            ),
      floatingActionButton: Semantics(
        label: 'Add assignment',
        button: true,
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onRemove,
    required this.formatDate,
    this.dueBadge,
  });

  final Assignment assignment;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final String Function(DateTime) formatDate;
  final String? dueBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final a = assignment;
    final subtitle =
        '${a.courseName} · Due ${formatDate(a.dueDate)}${a.priority != null ? ' · ${a.priority!.label}' : ''}';
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: a.completed,
                  onChanged: (_) => onToggleCompleted(),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dueBadge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            dueBadge!,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 10,
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          decoration: a.completed ? TextDecoration.lineThrough : null,
                          decorationColor: colorScheme.outline,
                        ),
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
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.error, size: 22),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onRemove();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentFormDialog extends StatefulWidget {
  const _AssignmentFormDialog({this.existing});

  final Assignment? existing;

  @override
  State<_AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<_AssignmentFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late DateTime _dueDate;
  AssignmentPriority? _priority;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _courseController = TextEditingController(text: widget.existing?.courseName ?? '');
    _dueDate = widget.existing?.dueDate ?? DateTime.now();
    _priority = widget.existing?.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
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
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }
    setState(() => _titleError = null);
    final id = widget.existing?.id ?? 'a_${DateTime.now().millisecondsSinceEpoch}';
    final a = Assignment(
      id: id,
      title: title,
      dueDate: _dueDate,
      courseName: _courseController.text.trim().isEmpty ? 'No course' : _courseController.text.trim(),
      priority: _priority,
      completed: widget.existing?.completed ?? false,
    );
    Navigator.of(context).pop(a);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        widget.existing != null ? 'Edit assignment' : 'New assignment',
        style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Assignment title (required)',
                errorText: _titleError,
              ),
              onChanged: (_) => setState(() => _titleError = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course name'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(
                '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: Icon(Icons.calendar_today, color: theme.colorScheme.error),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AssignmentPriority?>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority (optional)'),
              items: const [
                DropdownMenuItem(value: null, child: Text('None')),
                DropdownMenuItem(value: AssignmentPriority.high, child: Text('High')),
                DropdownMenuItem(value: AssignmentPriority.medium, child: Text('Medium')),
                DropdownMenuItem(value: AssignmentPriority.low, child: Text('Low')),
              ],
              onChanged: (v) => setState(() => _priority = v),
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
