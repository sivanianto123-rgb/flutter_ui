/// A single page in the Level 9 storybook.
class StoryPage {
  const StoryPage({
    required this.text,
    required this.syllable,
  });

  final String text;
  final String syllable;

  static List<StoryPage> forSyllable(String syllable) {
    const stories = <String, List<String>>{
      'ma': [
        'Mama makes magical mango cake.',
        'The monkey munches on maple leaves.',
        'Mia the mouse meets a merry moose.',
        'Moon and stars make the sky magical.',
      ],
      'pa': [
        'Papa paints pretty purple parrots.',
        'A panda plays in the park all day.',
        'Pip the puppy pounces on pink petals.',
        'Pandas pick peachy peaches in the park.',
      ],
      'ma_pa': [
        'Mama and Papa play with the panda.',
        'The monkey meets the parrot.',
        'Mia and Pip make friends in the park.',
        'Mama makes pancakes. Papa makes mango smoothie.',
      ],
    };

    final texts = stories[syllable] ?? stories['ma']!;
    return texts.map((t) => StoryPage(text: t, syllable: syllable)).toList();
  }
}
