import 'dart:math' as math;

class GeneratedStory {
  const GeneratedStory({
    required this.title,
    required this.paragraphs,
    required this.practiceLine,
  });

  final String title;
  final List<String> paragraphs;
  final String practiceLine;
}

class AiStoryService {
  Future<GeneratedStory> generateForSound(String sound) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final s = sound.toLowerCase();
    final rng = math.Random(s.hashCode);

    final kids = ['Mina', 'Ravi', 'Tara', 'Nila', 'Arun'];
    final places = ['meadow', 'forest path', 'river bank', 'sunny garden'];
    final friends = ['rabbit', 'parrot', 'butterfly', 'turtle'];
    final actions = ['hummed', 'sang', 'clapped', 'whispered'];

    final kid = kids[rng.nextInt(kids.length)];
    final place = places[rng.nextInt(places.length)];
    final pal = friends[rng.nextInt(friends.length)];
    final action = actions[rng.nextInt(actions.length)];
    final repeated = '$s, $s, $s';

    return GeneratedStory(
      title: 'The ${s.toUpperCase()} Song in the $place',
      paragraphs: [
        '$kid and a little $pal walked into the $place. '
            '$kid $action, "$repeated!" and the $pal smiled.',
        'They found a tiny drum and tapped in rhythm: $s... $s... $s. '
            'Each time they said $s, they pointed to the letter sound.',
        'Soon, all the birds joined them and repeated the sound. '
            '$kid laughed, "When we say $s clearly, words become easy and fun!"',
      ],
      practiceLine: 'Practice line: Say "$s" slowly 5 times, then quickly 5 times.',
    );
  }
}
