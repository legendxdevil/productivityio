import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/models.dart';

class SketchNoteScreen extends StatefulWidget {
  final Note? initial;
  final bool readOnly;

  const SketchNoteScreen({super.key, this.initial, this.readOnly = false});

  @override
  State<SketchNoteScreen> createState() => _SketchNoteScreenState();
}

class _SketchNoteScreenState extends State<SketchNoteScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final TextEditingController _titleCtrl = TextEditingController();
  final List<_Stroke> _strokes = [];
  Color _currentColor = Colors.black;
  double _currentWidth = 3;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleCtrl.text = widget.initial!.title;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final box = _repaintKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = box?.globalToLocal(details.globalPosition) ?? details.localPosition;
    setState(() {
      _strokes.add(
        _Stroke(points: [localPos], color: _currentColor, width: _currentWidth),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = _repaintKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = box?.globalToLocal(details.globalPosition) ?? details.localPosition;
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.last.points.add(localPos);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // nothing extra; stroke already finished
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
    });
  }

  Future<void> _saveSketch() async {
    if (widget.readOnly) return;
    final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final Uint8List pngBytes = byteData.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: _titleCtrl.text.trim().isEmpty ? 'Sketch note' : _titleCtrl.text.trim(),
      body: '',
      type: NoteType.sketch,
      localImagePaths: [filePath],
    );

    if (!mounted) return;
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly && widget.initial != null && widget.initial!.localImagePaths.isNotEmpty) {
      final path = widget.initial!.localImagePaths.first;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sketch Note'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.file(File(path)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sketch Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _saveSketch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Pen:'),
                const SizedBox(width: 8),
                _ColorDot(
                  color: Colors.black,
                  selected: _currentColor == Colors.black,
                  onTap: () => setState(() => _currentColor = Colors.black),
                ),
                _ColorDot(
                  color: Colors.blue,
                  selected: _currentColor == Colors.blue,
                  onTap: () => setState(() => _currentColor = Colors.blue),
                ),
                _ColorDot(
                  color: Colors.red,
                  selected: _currentColor == Colors.red,
                  onTap: () => setState(() => _currentColor = Colors.red),
                ),
                _ColorDot(
                  color: Colors.green,
                  selected: _currentColor == Colors.green,
                  onTap: () => setState(() => _currentColor = Colors.green),
                ),
                const Spacer(),
                const Text('Size'),
                Slider(
                  value: _currentWidth,
                  min: 1,
                  max: 8,
                  divisions: 7,
                  label: _currentWidth.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _currentWidth = v),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear',
                  onPressed: _clearCanvas,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.grey.shade200,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: CustomPaint(
                        painter: _SketchPainter(strokes: _strokes),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  final List<_Stroke> strokes;

  _SketchPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SketchPainter oldDelegate) => oldDelegate.strokes != strokes;
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _Stroke({required this.points, required this.color, required this.width});
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.black26,
              width: selected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
