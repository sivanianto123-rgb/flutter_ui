import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../providers/child_performance_provider.dart';
import '../providers/profile_provider.dart';

class ProgressReportService {
  static const _reportWebhookUrl = String.fromEnvironment(
    'REPORT_WEBHOOK_URL',
    defaultValue: '',
  );

  static String buildReportBody({
    required ChildProfile profile,
    required ChildPerformance performance,
    String? zoneName,
  }) {
    final reading = (performance.readingSkill * 100).round();
    final sounds = (performance.soundAccuracy * 100).round();
    final listening = (performance.listeningSkill * 100).round();
    final words = (performance.wordAccuracy * 100).round();
    final sentences = (performance.sentenceAccuracy * 100).round();
    final overall = (performance.overallProgress * 100).round();

    return '''
Hi Parent,

Here is ${profile.name}'s latest Mave learning report${zoneName == null ? '' : ' after $zoneName'}:

- Overall progress: $overall%
- Reading skill: $reading%
- Sound match: $sounds%
- Story listening: $listening%
- Word zone: $words%
- Sentence zone: $sentences%

Session summary:
- Reading sessions: ${performance.readingSessions}
- Story sessions: ${performance.storySessions}
- Bubble pops: ${performance.bubbleCorrect}/${performance.bubbleTargetTotal}
- Word answers: ${performance.wordCorrect}/${performance.wordTotal}
- Sentence answers: ${performance.sentenceCorrect}/${performance.sentenceTotal}

Generated from Mave.
''';
  }

  static Future<bool> emailReport({
    required ChildProfile profile,
    required ChildPerformance performance,
    String? zoneName,
  }) async {
    final toEmail = profile.parentEmail?.trim();
    if (toEmail == null || toEmail.isEmpty) return false;

    final subject = 'Mave progress report for ${profile.name}';
    final body = buildReportBody(
      profile: profile,
      performance: performance,
      zoneName: zoneName,
    );
    final uri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) return false;
      return launchUrl(uri);
    } catch (_) {
      // Avoid app crash if platform channel/plugin isn't ready on runtime.
      return false;
    }
  }

  static Future<bool> sendAutomaticReport({
    required ChildProfile profile,
    required ChildPerformance performance,
    required String zoneName,
  }) async {
    final toEmail = profile.parentEmail?.trim();
    if (toEmail == null || toEmail.isEmpty) return false;
    final body = buildReportBody(
      profile: profile,
      performance: performance,
      zoneName: zoneName,
    );

    if (_reportWebhookUrl.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(_reportWebhookUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to': toEmail,
            'subject': 'Mave report: ${profile.name} - $zoneName',
            'body': body,
            'zone': zoneName,
            'childName': profile.name,
          }),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Fall through to mail client fallback.
      }
    }

    return emailReport(
      profile: profile,
      performance: performance,
      zoneName: zoneName,
    );
  }
}
