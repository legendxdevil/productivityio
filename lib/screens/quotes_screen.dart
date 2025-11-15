import 'package:flutter/material.dart';
import '../utils/quotes_data.dart';
import '../widgets/quote_widget.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motivational Quotes')),
      body: PageView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final q = quotes[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuoteWidget(text: q.text, author: q.author),
            ),
          );
        },
      ),
    );
  }
}
