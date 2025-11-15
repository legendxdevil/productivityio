class Task {
  final int id; // unique integer id
  final String title;
  final DateTime dueAt; // local time
  const Task({required this.id, required this.title, required this.dueAt});
}

class EventItem {
  final int id; // unique integer id
  final String title;
  final String topic; // short topic / subtitle
  final String place; // venue or place name
  final String location; // address / map link
  final String description; // longer description
  final DateTime eventAt; // main event time (local)
  final DateTime? reachAt; // optional: time you want to reach there
  final List<int> notifyHoursBefore; // e.g. [24, 6, 1]
  const EventItem({
    required this.id,
    required this.title,
    required this.topic,
    required this.place,
    required this.location,
    required this.description,
    required this.eventAt,
    this.reachAt,
    this.notifyHoursBefore = const [24],
  });
}

enum NoteType { text, sketch, flowchart }

class Note {
  final int id; // unique integer id
  final String title;
  final String body;
  final NoteType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> imageUrls; // online images (URLs)
  final List<String> localImagePaths; // images picked from device

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.type = NoteType.text,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imageUrls,
    List<String>? localImagePaths,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        imageUrls = imageUrls ?? const [],
        localImagePaths = localImagePaths ?? const [];

  Note copyWith({
    String? title,
    String? body,
    NoteType? type,
    DateTime? updatedAt,
    List<String>? imageUrls,
    List<String>? localImagePaths,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      imageUrls: imageUrls ?? this.imageUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
    );
  }
}
