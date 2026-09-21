/// AI-generated activity specification returned by Gemini.
class ActivitySpec {
  const ActivitySpec({
    required this.title,
    required this.storyText,
    required this.uiType,
  });

  final String title;
  final String storyText;
  final String uiType;

  factory ActivitySpec.fromJson(Map<String, dynamic> json) => ActivitySpec(
    title:     json['title']     as String? ?? '',
    storyText: json['storyText'] as String? ?? '',
    uiType:    json['uiType']    as String? ?? 'default',
  );

  static const List<String> allowedUiTypes = ['storybook', 'flashcard', 'default'];
}
