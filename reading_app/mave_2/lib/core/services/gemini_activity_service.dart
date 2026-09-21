import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/activity_spec.dart';
import '../models/sound_node.dart';

/// Calls Gemini 1.5 Flash to generate a story-first [ActivitySpec] for a
/// sound-learning activity.
///
/// Each call produces:
///   • [title]     — spoken by TTS first (e.g. "Learning the MA sound!")
///   • [storyText] — spoken by TTS second (2-3 warm sentences)
///   • [uiType]    — whitelisted game module to render
///
/// Blended nodes (Ma + Pa): Gemini weaves both sounds into one story and
/// returns [UiType.beeTrace] to encourage sustained vocalization.
///
/// On any network or parse failure [generate] returns [ActivitySpec.fallback]
/// so a toddler never sees an error screen.
class GeminiActivityService {
  GeminiActivityService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models'
      '/gemini-1.5-flash:generateContent';

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<ActivitySpec> generate(SoundNode node) async {
    final targetSound = node.primarySound;
    final isCombo     = node.prerequisites.isNotEmpty;

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': _buildPrompt(node, isCombo)},
                  ],
                },
              ],
              'generationConfig': {
                'responseMimeType': 'application/json',
                'temperature':      0.75,
                'maxOutputTokens':  400,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint('[Gemini] HTTP ${response.statusCode} → fallback');
        return ActivitySpec.fallback(targetSound);
      }

      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(body);

      if (content == null || content.trim().isEmpty) {
        return ActivitySpec.fallback(targetSound);
      }

      // Strip accidental markdown fences.
      final cleaned = content
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final spec = ActivitySpec.fromJson(cleaned, targetSound);
      debugPrint(
        '[Gemini] ${spec.uiType.name} · "${spec.title.substring(0, spec.title.length.clamp(0, 40))}"',
      );
      return spec;
    } catch (e) {
      debugPrint('[Gemini] Error: $e → fallback');
      return ActivitySpec.fallback(targetSound);
    }
  }

  // ── Prompt ─────────────────────────────────────────────────────────────────

  String _buildPrompt(SoundNode node, bool isCombo) {
    if (isCombo) {
      final s1 = node.prerequisites[0].toUpperCase();
      final s2 = node.prerequisites[1].toUpperCase();
      return '''
You are a children's activity designer for babies aged 1–3.
Generate a fun activity combining BOTH sounds "$s1" and "$s2".

Return ONLY a JSON object (no markdown):
{
  "title": "$s1 and $s2 together!",
  "storyText": "<2-3 warm, joyful sentences. Use words starting with '${s1.toLowerCase()}' AND '${s2.toLowerCase()}' in the same story. End with a question like 'Can you make the sound?'>",
  "uiType": "bee_trace"
}

Rules:
• title must be exactly "$s1 and $s2 together!"
• storyText max 40 words, age-appropriate, warm and encouraging
• uiType must be exactly "bee_trace" for combo activities
''';
    }

    final s = node.id.toUpperCase();
    return '''
You are a children's activity designer for babies aged 1–3.
Generate a phoneme activity for the sound "$s".

Return ONLY a JSON object (no markdown):
{
  "title": "Learning the $s sound!",
  "storyText": "<2-3 warm, joyful sentences naturally using words starting with '${node.id}'. End with 'Can you find the $s?'>",
  "uiType": "<choose ONE from: feed_monster, tap_pop>"
}

Rules:
• title must be exactly "Learning the $s sound!"
• storyText max 35 words, age-appropriate, warm and encouraging
• uiType must be one of: feed_monster, tap_pop
• Prefer feed_monster for engaging physical interaction
''';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? _extractContent(Map<String, dynamic> body) {
    try {
      final candidates = body['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;
      final parts = candidates[0]['content']['parts'] as List<dynamic>?;
      return parts?.first['text'] as String?;
    } catch (_) {
      return null;
    }
  }
}
