class ChecklistItem {
  String id;
  String text;
  bool isChecked;

  ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  ChecklistItem copyWith({String? id, String? text, bool? isChecked}) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isChecked': isChecked,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'],
        text: json['text'],
        isChecked: json['isChecked'] ?? false,
      );
}
