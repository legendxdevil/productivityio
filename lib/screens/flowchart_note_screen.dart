import 'package:flutter/material.dart';

import '../utils/models.dart';

class FlowchartNoteScreen extends StatefulWidget {
  final Note? initial;
  final bool readOnly;

  const FlowchartNoteScreen({super.key, this.initial, this.readOnly = false});

  @override
  State<FlowchartNoteScreen> createState() => _FlowchartNoteScreenState();
}

class _FlowchartNoteScreenState extends State<FlowchartNoteScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final List<TextEditingController> _nodeCtrls = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initial?.title ?? '';

    if (widget.initial != null && widget.initial!.body.isNotEmpty) {
      final lines = widget.initial!.body.split('\n');
      for (final line in lines) {
        _nodeCtrls.add(TextEditingController(text: line));
      }
    } else {
      _addNode();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final c in _nodeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNode() {
    setState(() {
      _nodeCtrls.add(TextEditingController());
    });
  }

  void _removeNode(int index) {
    if (index < 0 || index >= _nodeCtrls.length) return;
    setState(() {
      final c = _nodeCtrls.removeAt(index);
      c.dispose();
    });
  }

  void _saveAndPop() {
    if (widget.readOnly) return;
    final id = widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lines = _nodeCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final body = lines.join('\n');

    final note = Note(
      id: id,
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Flowchart note',
      body: body,
      type: NoteType.flowchart,
      createdAt: widget.initial?.createdAt,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.readOnly;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flowchart / Tree Note'),
        actions: [
          if (!readOnly)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save',
              onPressed: _saveAndPop,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              readOnly: readOnly,
              decoration: const InputDecoration(labelText: 'Title (optional)'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _nodeCtrls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle, size: 10),
                          if (index < _nodeCtrls.length - 1)
                            Container(
                              width: 2,
                              height: 32,
                              color: Colors.grey.shade400,
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _nodeCtrls[index],
                          readOnly: readOnly,
                          decoration: InputDecoration(
                            labelText: 'Node ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      if (!readOnly)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Remove node',
                          onPressed: () => _removeNode(index),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (!readOnly) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add node'),
                  onPressed: _addNode,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
