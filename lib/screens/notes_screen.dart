import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/models.dart';
import 'note_editor_screen.dart';
import 'sketch_note_screen.dart';
import 'flowchart_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> _notes = [];

  Future<void> _openEditor({Note? note}) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(initial: note)),
    );
    if (result == null) return;
    setState(() {
      final index = _notes.indexWhere((n) => n.id == result.id);
      if (index >= 0) {
        _notes[index] = result;
      } else {
        _notes.add(result);
      }
    });
  }

  Future<void> _createSketchNote() async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => const SketchNoteScreen()),
    );
    if (result == null) return;
    setState(() {
      _notes.add(result);
    });
  }

  Future<void> _createFlowchartNote() async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => const FlowchartNoteScreen()),
    );
    if (result == null) return;
    setState(() {
      _notes.add(result);
    });
  }

  void _deleteNote(Note note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: _notes.isEmpty
          ? const Center(
              child: Text('No notes yet. Tap + to create one.'),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: note.localImagePaths.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(note.localImagePaths.first),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.note_outlined),
                    title: Text(note.title),
                    subtitle: Text(
                      note.type == NoteType.sketch
                          ? 'Sketch note'
                          : note.type == NoteType.flowchart
                              ? 'Flowchart / tree note'
                              : note.body.isEmpty
                                  ? 'Empty note'
                                  : note.body.length > 80
                                      ? '${note.body.substring(0, 80)}...'
                                      : note.body,
                    ),
                    onTap: () {
                      if (note.type == NoteType.sketch) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SketchNoteScreen(
                              initial: note,
                              readOnly: true,
                            ),
                          ),
                        );
                      } else if (note.type == NoteType.flowchart) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlowchartNoteScreen(
                              initial: note,
                              readOnly: true,
                            ),
                          ),
                        );
                      } else {
                        _openEditor(note: note);
                      }
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteNote(note),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final choice = await showModalBottomSheet<String>(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notes_outlined),
                      title: const Text('Text note'),
                      onTap: () => Navigator.of(context).pop('text'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.gesture_outlined),
                      title: const Text('Sketch note'),
                      onTap: () => Navigator.of(context).pop('sketch'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_tree_outlined),
                      title: const Text('Flowchart / tree note'),
                      onTap: () => Navigator.of(context).pop('flowchart'),
                    ),
                  ],
                ),
              );
            },
          );

          if (choice == 'text') {
            _openEditor();
          } else if (choice == 'sketch') {
            _createSketchNote();
          } else if (choice == 'flowchart') {
            _createFlowchartNote();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
