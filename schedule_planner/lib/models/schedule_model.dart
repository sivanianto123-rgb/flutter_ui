enum ScheduleType { meeting, appointment, custom }

enum ScheduleImportance { low, medium, high, critical }

class ScheduleModel {
  String id;
  String title;
  DateTime date;
  String? time;
  ScheduleType type;
  ScheduleImportance importance;
  String? meetingLink;
  String? location;
  String? description;
  List<String> attendees;
  bool isCompleted;
  List<String> customFieldKeys;
  Map<String, String> customFieldValues;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.type,
    this.importance = ScheduleImportance.medium,
    this.meetingLink,
    this.location,
    this.description,
    this.attendees = const [],
    this.isCompleted = false,
    this.customFieldKeys = const [],
    this.customFieldValues = const {},
  });

  ScheduleModel copyWith({
    String? title,
    DateTime? date,
    String? time,
    ScheduleType? type,
    ScheduleImportance? importance,
    String? meetingLink,
    String? location,
    String? description,
    List<String>? attendees,
    bool? isCompleted,
    List<String>? customFieldKeys,
    Map<String, String>? customFieldValues,
  }) {
    return ScheduleModel(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      importance: importance ?? this.importance,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      description: description ?? this.description,
      attendees: attendees ?? this.attendees,
      isCompleted: isCompleted ?? this.isCompleted,
      customFieldKeys: customFieldKeys ?? this.customFieldKeys,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'time': time,
        'type': type.name,
        'importance': importance.name,
        'meetingLink': meetingLink,
        'location': location,
        'description': description,
        'attendees': attendees,
        'isCompleted': isCompleted,
        'customFieldKeys': customFieldKeys,
        'customFieldValues': customFieldValues,
      };

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
        time: json['time'],
        type: ScheduleType.values.byName(json['type']),
        importance: json['importance'] != null
            ? ScheduleImportance.values.byName(json['importance'])
            : ScheduleImportance.medium,
        meetingLink: json['meetingLink'],
        location: json['location'],
        description: json['description'],
        attendees: List<String>.from(json['attendees'] ?? []),
        isCompleted: json['isCompleted'] ?? false,
        customFieldKeys: List<String>.from(json['customFieldKeys'] ?? []),
        customFieldValues:
            Map<String, String>.from(json['customFieldValues'] ?? {}),
      );
}
