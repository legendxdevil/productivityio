import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../utils/quotes_data.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, _) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System default'),
                    value: ThemeMode.system,
                    groupValue: mode,
                    onChanged: (value) {
                      if (value != null) themeModeNotifier.value = value;
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: mode,
                    onChanged: (value) {
                      if (value != null) themeModeNotifier.value = value;
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: mode,
                    onChanged: (value) {
                      if (value != null) themeModeNotifier.value = value;
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(height: 32),
          const Text('Notifications & Widget', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Initialize notifications'),
            subtitle: const Text('Required once so reminders and events can notify you.'),
            onTap: () async {
              await NotificationService.instance.init();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications initialized')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Test notification'),
            onTap: () async {
              await NotificationService.instance.showTest();
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Daily quote at 9:00 AM'),
            onTap: () async {
              await NotificationService.instance.scheduleDailyQuote(hour: 9, minute: 0);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Daily 9:00 AM notification scheduled')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: const Text('Update home widget with first quote'),
            onTap: () async {
              if (quotes.isNotEmpty) {
                await WidgetService.instance.updateWithQuote(quotes.first);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Widget updated with first quote')),
                  );
                }
              }
            },
          ),
          const Divider(height: 32),
          const Text('Social', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.alternate_email),
            title: Text('Github'),
            subtitle: Text('github.com/your_handle_here'),
          ),
          const ListTile(
            leading: Icon(Icons.camera_alt_outlined),
            title: Text('Instagram'),
            subtitle: Text('@your_instagram_here'),
          ),
          const ListTile(
            leading: Icon(Icons.linked_camera_outlined),
            title: Text('LinkedIn'),
            subtitle: Text('your-linkedin-profile'),
          ),
        ],
      ),
    );
  }
}
