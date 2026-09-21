import 'checklist_item.dart';

enum NoteType { note, checklist, recipe }

class NoteModel {
  String id;
  String title;
  String content;
  NoteType type;
  DateTime date;
  bool isCompleted;
  List<ChecklistItem> checklist;
  List<String> ingredients;
  List<String> steps;

  NoteModel({
    required this.id,
    required this.title,
    this.content = '',
    required this.type,
    required this.date,
    this.isCompleted = false,
    this.checklist = const [],
    this.ingredients = const [],
    this.steps = const [],
  });

  NoteModel copyWith({
    String? title,
    String? content,
    NoteType? type,
    DateTime? date,
    bool? isCompleted,
    List<ChecklistItem>? checklist,
    List<String>? ingredients,
    List<String>? steps,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      checklist: checklist ?? this.checklist,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type.name,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
        'checklist': checklist.map((e) => e.toJson()).toList(),
        'ingredients': ingredients,
        'steps': steps,
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'],
        title: json['title'],
        content: json['content'] ?? '',
        type: NoteType.values.byName(json['type']),
        date: DateTime.parse(json['date']),
        isCompleted: json['isCompleted'] ?? false,
        checklist: (json['checklist'] as List? ?? [])
            .map((e) => ChecklistItem.fromJson(e))
            .toList(),
        ingredients: List<String>.from(json['ingredients'] ?? []),
        steps: List<String>.from(json['steps'] ?? []),
      );
}
