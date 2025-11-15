import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../utils/models.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? initial;

  const NoteEditorScreen({super.key, this.initial});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  final TextEditingController _imageUrlCtrl = TextEditingController();
  late List<String> _imageUrls;
  late List<String> _localImagePaths;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initial?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.initial?.body ?? '');
    _imageUrls = List<String>.from(widget.initial?.imageUrls ?? []);
    _localImagePaths = List<String>.from(widget.initial?.localImagePaths ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportAsPdf() async {
    final doc = pw.Document();

    final List<pw.Widget> content = [];

    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isNotEmpty) {
      content.add(
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
      );
      content.add(pw.SizedBox(height: 16));
    }

    if (body.isNotEmpty) {
      content.add(
        pw.Text(body, style: const pw.TextStyle(fontSize: 14)),
      );
    }

    // Add images (local first, then from URLs)
    final hasImages = _localImagePaths.isNotEmpty || _imageUrls.isNotEmpty;
    if (hasImages && (title.isNotEmpty || body.isNotEmpty)) {
      content.add(pw.SizedBox(height: 16));
    }

    // Local images (gallery or sketches)
    for (final path in _localImagePaths) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);
        content.add(pw.SizedBox(height: 8));
        content.add(
          pw.Center(
            child: pw.Image(image, height: 200, fit: pw.BoxFit.contain),
          ),
        );
      } catch (_) {
        // Ignore broken image
      }
    }

    // Network images from URLs
    for (final url in _imageUrls) {
      try {
        final image = await networkImage(url);
        content.add(pw.SizedBox(height: 8));
        content.add(
          pw.Center(
            child: pw.Image(image, height: 200, fit: pw.BoxFit.contain),
          ),
        );
      } catch (_) {
        // Ignore invalid URLs or failures
      }
    }

    doc.addPage(
      pw.MultiPage(
        build: (context) => content,
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  void _saveAndPop() {
    final id = widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final note = Note(
      id: id,
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Untitled',
      body: _bodyCtrl.text.trim(),
      type: widget.initial?.type ?? NoteType.text,
      createdAt: widget.initial?.createdAt,
      updatedAt: DateTime.now(),
      imageUrls: _imageUrls,
      localImagePaths: _localImagePaths,
    );
    Navigator.of(context).pop(note);
  }

  void _addImageUrl() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _imageUrls.add(url);
      _imageUrlCtrl.clear();
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _localImagePaths.add(picked.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export as PDF',
            onPressed: _exportAsPdf,
          ),
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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Add image from URL',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_link_outlined),
                  onPressed: _addImageUrl,
                ),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  tooltip: 'Pick from gallery',
                  onPressed: _pickImageFromGallery,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imageUrls.length + _localImagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index < _imageUrls.length) {
                    final url = _imageUrls[index];
                    return AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          );
                        }),
                      ),
                    );
                  } else {
                    final localIndex = index - _imageUrls.length;
                    final path = _localImagePaths[localIndex];
                    return AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          );
                        }),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
