---
name: ai-story
description: AI story generation for Mave using Gemini. Use when implementing
  the Story Screen, generating new stories after phonics mastery, or
  highlighting mastered phonemes in text.
argument-hint: "[phonemes] — e.g. m,a,s"
---

# AI Story Generation — Mave

## Story Generation Prompt Template
```
You are a children's literacy assistant for toddlers aged 0–3.

Generate a SHORT, simple story (4–6 sentences) using ONLY these phonics sounds
that the child has already mastered: $ARGUMENTS

Rules:
1. Use ONLY CVC words (Consonant-Vowel-Consonant) built from the mastered sounds.
2. Every word in the story must be decodable using only the listed phonemes.
   Exception: sight words [the, a, is, on, at, in, it] are allowed.
3. Sentences must be 4–6 words maximum.
4. Tone: warm, fun, gentle. No scary or confusing concepts.
5. Introduce a simple animal or character.
6. Return ONLY the story text. No titles. No explanation. No markdown.

Example (mastered: m, a, s, t):
"Sam sat on a mat. A cat sat too. Sam and the cat sat. Sam is a happy cat."
```

## Gemini API Call
```dart
// lib/features/phonics/services/story_service.dart
class StoryService {
  Future<String> generateStory(List<String> masteredPhonemes) async {
    final prompt = _buildPrompt(masteredPhonemes);
    final response = await GeminiClient.generateContent(
      model: 'gemini-2.0-flash',
      prompt: prompt,
      maxOutputTokens: 200,
      temperature: 0.7,
    );
    return response.text.trim();
  }
}
```

## Phoneme Highlighting
After story is returned, highlight mastered phonemes in the displayed text:
```dart
// Find all occurrences of mastered phoneme chars and wrap in RichText spans
TextSpan buildHighlightedStory(String story, List<String> phonemes) {
  // For each character in story, if it matches a mastered phoneme → highlight span
  // Highlight style: FontWeight.w900, color: maOrange, slight scale up
}
```

## Story Screen Features (per workflow)
1. Story text displayed in large Nunito font (20sp), line height 1.8
2. Mastered sounds highlighted in orange bold
3. Auto-narration plays on enter (TtsService.narrateStory)
4. Child can tap any WORD to re-hear it
5. "Next Sound →" button appears after story finishes playing
6. Stories cached locally by phoneme set key
