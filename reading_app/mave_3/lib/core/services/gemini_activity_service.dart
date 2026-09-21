import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/activity_spec.dart';

class GeminiActivityService {
  GeminiActivityService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;

  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models'
      '/gemini-1.5-flash:generateContent';

  Future<ActivitySpec?> generateActivity(String syllable) async {
    if (_apiKey.isEmpty) return null;
    try {
      final prompt =
          'Generate a short toddler story (3-4 sentences) that features the '
          'syllable "$syllable" many times. Return JSON: '
          '{"title":"...","storyText":"...","uiType":"storybook"}';

      final response = await http
          .post(
            Uri.parse('$_url?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [{'parts': [{'text': prompt}]}],
              'generationConfig': {'responseMimeType': 'application/json'},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (body['candidates'] as List)[0]['content']['parts'][0]['text'] as String?;
      if (text == null) return null;

      final json = jsonDecode(text) as Map<String, dynamic>;
      return ActivitySpec.fromJson(json);
    } catch (e) {
      debugPrint('[GeminiActivity] Failed: $e');
      return null;
    }
  }
}
