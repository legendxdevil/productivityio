import 'package:flutter/material.dart';

import '../utils/quotes_data.dart';
import '../widgets/quote_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _prompts = [
    'Take 2 minutes to breathe deeply and reset.',
    'Pick one small task and finish it completely.',
    'Write down the top 3 things you are grateful for today.',
    'Move your body for at least 5 minutes right now.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productivio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Daily Motivation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Swipe through quotes from different people and pick one small action to do now.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                itemCount: quotes.length,
                itemBuilder: (context, index) {
                  final q = quotes[index];
                  final prompt = _prompts[index % _prompts.length];
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: QuoteWidget(text: q.text, author: q.author),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: kElevationToShadow[1],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.bolt_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                prompt,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
