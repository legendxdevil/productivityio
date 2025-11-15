import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../utils/models.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _titleCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _notifyCtrl = TextEditingController(text: '24, 6, 1');
  DateTime? _eventAt;
  DateTime? _reachAt;
  final List<EventItem> _events = [];

  Future<void> _pickEventTime() async {
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
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 24))),
    );
    if (time == null) return;
    setState(() {
      _eventAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickReachTime() async {
    if (_eventAt == null) {
      await _pickEventTime();
      if (_eventAt == null) return;
    }
    final baseDate = _eventAt!;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(baseDate.subtract(const Duration(hours: 1))),
    );
    if (time == null) return;
    setState(() {
      _reachAt = DateTime(baseDate.year, baseDate.month, baseDate.day, time.hour, time.minute);
    });
  }

  Future<void> _addEvent() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _topicCtrl.text.trim().isEmpty ||
        _placeCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty ||
        _descriptionCtrl.text.trim().isEmpty ||
        _eventAt == null) {
      return;
    }

    // Smart rule: allow at most one event per calendar day
    final eventDate = DateTime(_eventAt!.year, _eventAt!.month, _eventAt!.day);
    final hasSameDay = _events.any((existing) {
      final d = existing.eventAt;
      final existingDate = DateTime(d.year, d.month, d.day);
      return existingDate == eventDate;
    });
    if (hasSameDay) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already have an event on this day. Only one event per day is allowed.')),
        );
      }
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000; // simple unique int
    final parsedNotify = _notifyCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => int.tryParse(s))
        .whereType<int>()
        .where((h) => h > 0)
        .toList();
    final notifyHours = parsedNotify.isEmpty ? const [24] : parsedNotify;
    final e = EventItem(
      id: id,
      title: _titleCtrl.text.trim(),
      topic: _topicCtrl.text.trim(),
      place: _placeCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      eventAt: _eventAt!,
      reachAt: _reachAt,
      notifyHoursBefore: notifyHours,
    );

    try {
      await NotificationService.instance.init();
      await NotificationService.instance.scheduleEventReminder(e);

      setState(() {
        _events.add(e);
        _titleCtrl.clear();
        _topicCtrl.clear();
        _placeCtrl.clear();
        _locationCtrl.clear();
        _descriptionCtrl.clear();
        _notifyCtrl.text = '24, 6, 1';
        _eventAt = null;
        _reachAt = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event scheduled with reminders')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to schedule event reminder. Please check notification permission.'),
        ),
      );
    }
  }

  Future<void> _cancelEvent(EventItem e) async {
    await NotificationService.instance.cancelEvent(e);
    setState(() {
      _events.removeWhere((x) => x.id == e.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: SingleChildScrollView(
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
                      'Plan important events with full details and get smart reminders before the day.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Event title',
                        prefixIcon: Icon(Icons.event_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _topicCtrl,
                      decoration: const InputDecoration(labelText: 'Topic / short details'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _placeCtrl,
                      decoration: const InputDecoration(labelText: 'Place / venue'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(labelText: 'Location / address / link'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notifyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notify before (hours, e.g. 24, 6, 1)',
                        prefixIcon: Icon(Icons.alarm_on_outlined),
                      ),
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
                                  'Event date & time',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _eventAt == null
                                      ? 'Choose when the event starts'
                                      : 'Event: ${_eventAt!.toLocal()}',
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
                            onPressed: _pickEventTime,
                            icon: const Icon(Icons.schedule_outlined, size: 18),
                            label: const Text('Pick time'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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
                                  'Reach time (optional)',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _reachAt == null
                                      ? 'When you want to reach the venue'
                                      : 'Reach by: ${_reachAt!.toLocal()}',
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
                            onPressed: _pickReachTime,
                            icon: const Icon(Icons.directions_run_outlined, size: 18),
                            label: const Text('Pick reach'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addEvent,
                        icon: const Icon(Icons.event_available_outlined),
                        label: const Text('Add event & schedule'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 16),
            const Text('Scheduled events', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              itemCount: _events.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final e = _events[index];
                  final daysLeft = e.eventAt.difference(DateTime.now()).inDays;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(e.title),
                      subtitle: Text(
                        'When: ${e.eventAt.toLocal()}\n'
                        'Where: ${e.place}\n'
                        'Location: ${e.location}\n'
                        'Topic: ${e.topic}\n'
                        '${e.reachAt != null ? 'Reach by: ${e.reachAt!.toLocal()}\n' : ''}'
                        '${daysLeft >= 0 ? 'Days left: $daysLeft' : 'Event passed'}',
                      ),
                      isThreeLine: false,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.push_pin_outlined),
                            tooltip: 'Pin to widget',
                            onPressed: () async {
                              await WidgetService.instance.updateWithEvent(e);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Event pinned to widget.')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            tooltip: 'Cancel event',
                            onPressed: () => _cancelEvent(e),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
