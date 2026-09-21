const _vowels = 'aeiou';

bool isVowel(String char) =>
    char.length == 1 && _vowels.contains(char.toLowerCase());

bool isConsonant(String char) =>
    char.length == 1 && RegExp(r'[a-z]', caseSensitive: false).hasMatch(char) && !isVowel(char);

/// Split a word into readable chunks. When two consonants sit between vowels,
/// split between them (e.g. establish -> es, tab, lish).
List<String> splitSyllables(String word) {
  final w = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  if (w.isEmpty) return [];

  final vowelPositions = <int>[
    for (var i = 0; i < w.length; i++)
      if (isVowel(w[i])) i,
  ];
  if (vowelPositions.isEmpty) return [w];

  final chunks = <String>[];
  var start = 0;

  for (var vi = 0; vi < vowelPositions.length; vi++) {
    final vPos = vowelPositions[vi];
    final isLastVowel = vi == vowelPositions.length - 1;
    var end = w.length;

    if (!isLastVowel) {
      final nextV = vowelPositions[vi + 1];
      final between = w.substring(vPos + 1, nextV);
      if (between.length >= 2) {
        end = vPos + 2;
      } else if (between.length == 1) {
        end = nextV;
      } else {
        end = vPos + 1;
      }
    }

    chunks.add(w.substring(start, end));
    start = end;
  }

  if (start < w.length) {
    chunks.add(w.substring(start));
  }

  return chunks.where((c) => c.isNotEmpty).toList();
}

List<int> vowelIndices(String word) {
  final w = word.toLowerCase();
  return [
    for (var i = 0; i < w.length; i++)
      if (isVowel(w[i])) i,
  ];
}

List<int> consonantIndices(String word) {
  final w = word.toLowerCase();
  return [
    for (var i = 0; i < w.length; i++)
      if (isConsonant(w[i])) i,
  ];
}
