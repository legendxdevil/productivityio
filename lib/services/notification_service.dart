import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

import '../utils/models.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _actionEvents = StreamController.broadcast();
  Stream<String> get actionEvents => _actionEvents.stream;

  Future<void> init() async {
    // Initialize timezone (fixed to Asia/Kolkata for now)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final actionId = response.actionId; // e.g. 'MARK_DONE'
        final payload = response.payload; // e.g. 'task:123'
        if (actionId == 'MARK_DONE' && payload != null && payload.startsWith('task:')) {
          final idStr = payload.split(':').last;
          final taskId = int.tryParse(idStr);
          if (taskId != null) {
            await cancelTaskById(taskId);
            _actionEvents.add('task_done:$taskId');
            await _showInfo('Task Completed', 'Marked task #$taskId as done. Pending reminders cancelled.');
          }
        }
      },
    );

    // Explicitly request Android notification permission (Android 13+)
    final androidImpl =
        _fln.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  NotificationDetails _details() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_quotes_channel',
      'Daily Quotes',
      channelDescription: 'Daily motivational quote reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    return const NotificationDetails(android: androidDetails);
  }

  Future<void> showTest() async {
    await _fln.show(
      1001,
      'Productivio',
      'This is your test notification! 🚀',
      _details(),
    );
  }

  Future<void> scheduleDailyQuote({required int hour, required int minute}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _fln.zonedSchedule(
      2001,
      'Daily Motivation',
      'Stay focused. Your consistency is your superpower. ✨',
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // --- Progressive Task Reminders ---

  // Create unique notification IDs for a task using its id and an index
  int _taskNotifId(int taskId, int index) => taskId * 10 + index; // up to 10 slots

  AndroidNotificationDetails _taskAndroidDetails(String title, String body) {
    return AndroidNotificationDetails(
      'tasks_channel',
      'Tasks',
      channelDescription: 'Progressive reminders for tasks',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'MARK_DONE',
          'Done',
          showsUserInterface: true,
          // RequestForegroundService permission is not required for simple action
        ),
      ],
    );
  }

  NotificationDetails _taskDetails(String title, String body) {
    return NotificationDetails(android: _taskAndroidDetails(title, body));
  }

  Future<void> scheduleTaskProgressive(Task task) async {
    final now = tz.TZDateTime.now(tz.local);
    final due = tz.TZDateTime.from(task.dueAt, tz.local);
    final List<Duration> offsets = [
      const Duration(hours: 1),
      const Duration(minutes: 30),
      const Duration(minutes: 10),
      const Duration(minutes: 5),
      const Duration(minutes: 1),
    ];

    int idx = 0;
    for (final d in offsets) {
      final scheduled = due.subtract(d);
      if (scheduled.isAfter(now)) {
        await _fln.zonedSchedule(
          _taskNotifId(task.id, idx),
          'Upcoming: ${task.title}',
          'Due in ${_fmtDuration(d)}',
          scheduled,
          _taskDetails('Upcoming: ${task.title}', 'Due in ${_fmtDuration(d)}'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
          payload: 'task:${task.id}',
        );
      }
      idx++;
    }
  }

  Future<void> cancelTask(Task task) => cancelTaskById(task.id);

  Future<void> cancelTaskById(int taskId) async {
    for (int i = 0; i < 10; i++) {
      await _fln.cancel(_taskNotifId(taskId, i));
    }
  }

  // --- Event multi-offset Reminders ---
  int _eventNotifId(int eventId, int index) => 900000 + eventId * 10 + index; // avoid collision

  Future<void> scheduleEventReminder(EventItem event) async {
    final now = tz.TZDateTime.now(tz.local);
    final eventTime = tz.TZDateTime.from(event.eventAt, tz.local);

    // Use custom hours-before list; default provided by model
    final hours = event.notifyHoursBefore.toSet().toList()..sort((a, b) => b.compareTo(a));

    int idx = 0;
    for (final h in hours) {
      final remindAt = eventTime.subtract(Duration(hours: h));
      if (remindAt.isAfter(now)) {
        final android = AndroidNotificationDetails(
          'events_channel',
          'Events',
          channelDescription: 'Event reminders',
          importance: Importance.high,
          priority: Priority.high,
        );
        await _fln.zonedSchedule(
          _eventNotifId(event.id, idx),
          'Event: ${event.title}',
          'In ${h}h - ${event.topic}',
          remindAt,
          NotificationDetails(android: android),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
          payload: 'event:${event.id}',
        );
      }
      idx++;
    }
  }

  Future<void> cancelEvent(EventItem event) async {
    // Cancel a reasonable range of IDs for this event
    for (int i = 0; i < 10; i++) {
      await _fln.cancel(_eventNotifId(event.id, i));
    }
  }

  // --- Helpers ---
  String _fmtDuration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    }
    return '${d.inMinutes}m';
  }

  Future<void> _showInfo(String title, String body) async {
    await _fln.show(888001, title, body, const NotificationDetails(
      android: AndroidNotificationDetails('info_channel', 'Info'),
    ));
  }
}
