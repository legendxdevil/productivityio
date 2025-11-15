import 'package:home_widget/home_widget.dart';
import '../utils/quotes_data.dart';
import '../utils/models.dart';

class WidgetService {
  WidgetService._();
  static final instance = WidgetService._();

  static const String _providerName = 'HomeWidgetProvider';

  Future<void> updateWithQuote(Quote quote) async {
    await HomeWidget.saveWidgetData<String>('quote', quote.text);
    await HomeWidget.saveWidgetData<String>('author', quote.author);
    await HomeWidget.updateWidget(name: _providerName);
  }

  Future<void> updateWithEvent(EventItem event) async {
    final now = DateTime.now();
    final daysLeft = event.eventAt.difference(now).inDays;

    await HomeWidget.saveWidgetData<String>('event_title', event.title);
    await HomeWidget.saveWidgetData<String>('event_place', event.place);
    await HomeWidget.saveWidgetData<String>('event_date', event.eventAt.toIso8601String());
    await HomeWidget.saveWidgetData<int>('event_days_left', daysLeft);
    await HomeWidget.updateWidget(name: _providerName);
  }
}
