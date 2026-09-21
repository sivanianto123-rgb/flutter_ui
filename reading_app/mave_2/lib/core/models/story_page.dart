/// A single page of the storybook.
///
/// [sentence]    — text displayed and narrated on this page.
/// [imagePrompt] — Imagen prompt for illustration (reserved for future use).
/// [imagePath]   — local file path to cached image; null = show placeholder.
class StoryPage {
  const StoryPage({
    required this.sentence,
    required this.imagePrompt,
    this.imagePath,
  });

  final String  sentence;
  final String  imagePrompt;
  final String? imagePath;

  StoryPage copyWith({String? imagePath}) => StoryPage(
        sentence:    sentence,
        imagePrompt: imagePrompt,
        imagePath:   imagePath ?? this.imagePath,
      );

  // ── Hardcoded story libraries ──────────────────────────────────────────────

  /// Returns the curated story for [syllable], or the generic fallback.
  static List<StoryPage> forSyllable(String syllable) {
    switch (syllable.toLowerCase()) {
      case 'ma': return _maStory;
      case 'pa': return _paStory;
      default:   return fallback(syllable);
    }
  }

  // ── Ma story ───────────────────────────────────────────────────────────────

  static const List<StoryPage> _maStory = [
    StoryPage(
      sentence: 'Mama and Max wake up in the morning. "MA! MA! MA!" says Max.',
      imagePrompt: 'Cheerful mama bear and baby bear cub waking up in a cosy bedroom, warm sunrise light, watercolour style',
    ),
    StoryPage(
      sentence: 'Mama makes mango oatmeal. It smells amazing!',
      imagePrompt: 'Friendly mama bear stirring a bowl of porridge with mango slices, warm kitchen, soft watercolour',
    ),
    StoryPage(
      sentence: '"MA!" Max calls. He wants more mango. Mama smiles.',
      imagePrompt: 'Baby bear reaching up with paws toward mama bear who holds a mango, sunny kitchen, watercolour',
    ),
    StoryPage(
      sentence: 'Mama and Max march to the meadow. Their feet go MA MA MA!',
      imagePrompt: 'Mama bear and baby bear walking happily through a green meadow, cartoon watercolour style',
    ),
    StoryPage(
      sentence: 'Max sees a mole. "MA!" he shouts. The mole digs away.',
      imagePrompt: 'Cute baby bear pointing at a small mole popping from the ground, bright meadow, watercolour',
    ),
    StoryPage(
      sentence: 'At night Mama sings: "Ma ma ma, my little star." Max sleeps.',
      imagePrompt: 'Mama bear singing softly to sleeping baby bear under a starry night sky, cosy watercolour illustration',
    ),
  ];

  // ── Pa story ───────────────────────────────────────────────────────────────

  static const List<StoryPage> _paStory = [
    StoryPage(
      sentence: 'Papa and Pip play in the park. "PA! PA! PA!" laughs Pip.',
      imagePrompt: 'Papa penguin and baby penguin playing in a sunny park, watercolour style, warm colours',
    ),
    StoryPage(
      sentence: 'Papa picks ripe pears from the tree. Plop plop plop!',
      imagePrompt: 'Papa penguin reaching up to pick yellow pears from a tree, bright sunny day, watercolour',
    ),
    StoryPage(
      sentence: '"PA!" calls Pip. He wants a pear too. Papa passes one over.',
      imagePrompt: 'Baby penguin reaching up as papa penguin offers a pear, garden scene, soft watercolour',
    ),
    StoryPage(
      sentence: 'Papa and Pip pat the puppy. The puppy wags and goes PA-PA-PA!',
      imagePrompt: 'Penguin family petting a small fluffy puppy in a garden, cheerful watercolour illustration',
    ),
    StoryPage(
      sentence: 'Pip paints a picture for Papa. It has pears and a puppy!',
      imagePrompt: 'Baby penguin painting a picture on an easel, colourful art supplies around, watercolour style',
    ),
    StoryPage(
      sentence: 'Papa hugs Pip. "PA pa pa," he whispers. "I love you."',
      imagePrompt: 'Papa penguin hugging baby penguin under a glowing sunset, warm golden watercolour tones',
    ),
  ];

  // ── Generic fallback ───────────────────────────────────────────────────────

  static List<StoryPage> fallback(String syllable) {
    final s = syllable[0].toUpperCase() + syllable.substring(1);
    return [
      StoryPage(
        sentence: '$s — a sound so fun to say!',
        imagePrompt: 'Cheerful toddler opening mouth wide, warm kitchen, watercolour',
      ),
      StoryPage(
        sentence: 'Say it slow. Say it loud: $s!',
        imagePrompt: 'Smiling baby bear clapping paws together happily outdoors, watercolour',
      ),
      StoryPage(
        sentence: 'Great job! You said $s perfectly! 🌟',
        imagePrompt: 'Cute animals cheering and throwing confetti in a sunny meadow, watercolour',
      ),
    ];
  }
}
