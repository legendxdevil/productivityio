import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../utils/models.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _titleCtrl = TextEditingController();
  DateTime? _dueAt;
  final List<Task> _tasks = [];
  String _selectedEmoji = '💧 Water';

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      await NotificationService.instance.init();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initialize notifications for reminders')),
      );
    }
  }

  Future<void> _pickDueTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 3))),
    );
    if (time == null) return;
    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addTask() async {
    if (_titleCtrl.text.trim().isEmpty || _dueAt == null) return;
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000; // simple unique int
    final baseTitle = _titleCtrl.text.trim();
    final task = Task(id: id, title: '$_selectedEmoji  $baseTitle', dueAt: _dueAt!);
    try {
      await NotificationService.instance.init();
      await NotificationService.instance.scheduleTaskProgressive(task);
      setState(() {
        _tasks.add(task);
        _titleCtrl.clear();
        _dueAt = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Strict reminder scheduled with progressive notifications')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to schedule reminder. Please check notification permissions.')),
      );
    }
  }

  Future<void> _completeTask(Task t) async {
    await NotificationService.instance.cancelTask(t);
    setState(() {
      _tasks.removeWhere((e) => e.id == t.id);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Great! Reminder completed, all pending notifications stopped.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create strict reminders that nudge you multiple times before your chosen deadline.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text('Category'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: DropdownButton<String>(
                              value: _selectedEmoji,
                              underline: const SizedBox.shrink(),
                              items: const [
                                DropdownMenuItem(
                                  value: '💧 Water',
                                  child: Text('💧 Water'),
                                ),
                                DropdownMenuItem(
                                  value: '🏃 Exercise',
                                  child: Text('🏃 Exercise'),
                                ),
                                DropdownMenuItem(
                                  value: '📚 Study',
                                  child: Text('📚 Study'),
                                ),
                                DropdownMenuItem(
                                  value: '🧠 Focus',
                                  child: Text('🧠 Focus'),
                                ),
                                DropdownMenuItem(
                                  value: '✨ Other',
                                  child: Text('✨ Other'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedEmoji = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Due date & time',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _dueAt == null
                                      ? 'Tap to choose when this reminder should alert you'
                                      : 'Due: ${_dueAt!.toLocal()}',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _pickDueTime,
                            icon: const Icon(Icons.schedule_outlined, size: 18),
                            label: const Text('Pick time'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addTask,
                        icon: const Icon(Icons.notification_important_outlined),
                        label: const Text('Create strict reminder'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 16),
            const Text('Scheduled strict reminders', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final t = _tasks[index];
                  return ListTile(
                    title: Text(t.title),
                    subtitle: Text('Due: ${t.dueAt.toLocal()}'),
                    trailing: TextButton.icon(
                      onPressed: () => _completeTask(t),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
