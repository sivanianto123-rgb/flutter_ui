import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

/// Sends a progress report email to the parent via Firestore's `mail` collection.
///
/// Requires the Firebase Extension "Trigger Email from Firestore" to be installed:
///   https://extensions.dev/extensions/firebase/firestore-send-email
///
/// Extension setup (one-time in Firebase Console):
///   1. Install the extension → set collection to `mail`
///   2. Configure your SMTP provider (Gmail, SendGrid, etc.)
///
/// Every document written to `mail` is automatically sent by the extension.
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  /// Sends a session completion report to [parentEmail].
  ///
  /// [childName]    — e.g. "Aria"
  /// [syllable]     — e.g. "ma"
  /// [scores]       — activity ID → accuracy (0.0–1.0) for this session
  /// [totalStars]   — cumulative star count
  Future<void> sendSessionReport({
    required String parentEmail,
    required String childName,
    required String syllable,
    required Map<String, double> scores,
    required int totalStars,
  }) async {
    if (!FirebaseService.isReady) {
      debugPrint('[ReportService] Firebase not ready — skipping email report');
      return;
    }
    if (parentEmail.isEmpty) {
      debugPrint('[ReportService] No parent email set — skipping report');
      return;
    }

    try {
      final html = _buildHtml(
        childName:  childName,
        syllable:   syllable,
        scores:     scores,
        totalStars: totalStars,
      );

      await FirebaseFirestore.instance.collection('mail').add({
        'to':      parentEmail,
        'message': {
          'subject': '${childName}\'s reading progress with Mave!',
          'html':    html,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[ReportService] Report queued for $parentEmail');
    } catch (e) {
      debugPrint('[ReportService] Failed to queue report: $e');
    }
  }

  String _buildHtml({
    required String childName,
    required String syllable,
    required Map<String, double> scores,
    required int totalStars,
  }) {
    final syllableUpper = syllable.toUpperCase();
    final overall = scores.isEmpty
        ? 0
        : (scores.values.reduce((a, b) => a + b) / scores.length * 100).round();

    final activityRows = scores.entries.map((e) {
      final label    = _activityLabel(e.key);
      final pct      = (e.value * 100).round();
      final color    = pct >= 80 ? '#6BCB77' : pct >= 50 ? '#FFE66D' : '#FF6B6B';
      final barWidth = (pct * 1.8).round(); // max ~180px
      return '''
        <tr>
          <td style="padding:8px 0;color:#4A4A6A;font-size:14px;">$label</td>
          <td style="padding:8px 0;">
            <div style="background:#f0f0f8;border-radius:8px;height:14px;width:180px;overflow:hidden;">
              <div style="background:$color;height:14px;width:${barWidth}px;border-radius:8px;"></div>
            </div>
          </td>
          <td style="padding:8px 12px;color:#1A1A2E;font-weight:700;font-size:14px;">$pct%</td>
        </tr>
      ''';
    }).join();

    return '''
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#f5f5ff;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5ff;padding:32px 0;">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

        <!-- Header -->
        <tr>
          <td style="background:linear-gradient(135deg,#1A1A2E,#533483);padding:40px 40px 32px;text-align:center;">
            <div style="font-size:48px;margin-bottom:8px;">🦉</div>
            <h1 style="color:#ffffff;margin:0;font-size:28px;font-weight:900;letter-spacing:1px;">Mave</h1>
            <p style="color:rgba(255,255,255,0.7);margin:8px 0 0;font-size:15px;">Reading starts with a sound</p>
          </td>
        </tr>

        <!-- Greeting -->
        <tr>
          <td style="padding:32px 40px 0;">
            <h2 style="color:#1A1A2E;font-size:22px;margin:0 0 8px;">
              Great session, $childName! 🌟
            </h2>
            <p style="color:#4A4A6A;font-size:15px;line-height:1.6;margin:0;">
              $childName just completed a <strong>"$syllableUpper" sound</strong> learning session.
              Here's how it went:
            </p>
          </td>
        </tr>

        <!-- Overall score -->
        <tr>
          <td style="padding:24px 40px;">
            <div style="background:linear-gradient(135deg,#FF6B6B,#FF9F43);border-radius:16px;padding:20px;text-align:center;">
              <p style="color:rgba(255,255,255,0.85);margin:0 0 4px;font-size:13px;text-transform:uppercase;letter-spacing:1px;">Overall Score</p>
              <p style="color:#ffffff;margin:0;font-size:52px;font-weight:900;line-height:1;">$overall%</p>
              <p style="color:rgba(255,255,255,0.85);margin:4px 0 0;font-size:14px;">⭐ $totalStars total stars earned</p>
            </div>
          </td>
        </tr>

        <!-- Activity breakdown -->
        <tr>
          <td style="padding:0 40px 8px;">
            <h3 style="color:#1A1A2E;font-size:16px;margin:0 0 12px;">Activity Breakdown</h3>
            <table width="100%" cellpadding="0" cellspacing="0">
              $activityRows
            </table>
          </td>
        </tr>

        <!-- Encouragement -->
        <tr>
          <td style="padding:16px 40px 40px;">
            <div style="background:#f0fff4;border-left:4px solid #6BCB77;border-radius:0 8px 8px 0;padding:16px;">
              <p style="color:#1A4A2E;font-size:14px;margin:0;line-height:1.6;">
                ${_encouragementMessage(overall, childName)}
              </p>
            </div>
          </td>
        </tr>

        <!-- Footer -->
        <tr>
          <td style="background:#f5f5ff;padding:24px 40px;text-align:center;border-top:1px solid #e8e8f0;">
            <p style="color:#9898B8;font-size:12px;margin:0;">
              Sent with ❤️ by Mave · Helping little ones learn to read
            </p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>
    ''';
  }

  String _activityLabel(String activityId) {
    // activityId format: 'ma_feed_monster', 'pa_bubble_hunt', etc.
    final parts = activityId.split('_');
    if (parts.length < 2) return activityId;
    final key = parts.sublist(1).join('_');
    const labels = {
      'listen_watch':  'Listen & Watch',
      'feed_monster':  'Feed the Monster',
      'bubble_hunt':   'Bubble Hunt',
      'sound_tracing': 'Sound Tracing',
      'echo_animal':   'Echo the Animal',
      'tap_grow':      'Tap & Grow',
      'whos_door':     "Who's Behind the Door",
      'phoneme_train': 'Phoneme Train',
      'storybook':     'Story Time',
      'word_reading':  'Word Reading',
    };
    return labels[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }

  String _encouragementMessage(int overall, String childName) {
    if (overall >= 90) {
      return '🏆 Wow! $childName is a superstar! Outstanding accuracy across all activities. Keep up the amazing work!';
    } else if (overall >= 70) {
      return '🌟 $childName is doing really well! A little more practice will make this sound feel completely natural.';
    } else if (overall >= 50) {
      return '💪 $childName is making great progress! Every session builds confidence. Keep practicing together!';
    } else {
      return '🌱 Every expert starts as a beginner! $childName is learning and growing. Consistency is the key — keep going!';
    }
  }
}
