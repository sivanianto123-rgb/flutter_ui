import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../providers/mave_state.dart';

/// Result of an STT/phonetic evaluation round.
class PhoneticResult {
  final bool matched;
  final double confidence;
  final String rawText;
  const PhoneticResult({
    required this.matched,
    required this.confidence,
    required this.rawText,
  });
}

/// Gemini Multimodal Live API service.
///
/// Endpoint: v1alpha (BidiGenerateContent)
/// Model:    gemini-2.5-flash-preview-native-audio-dialog
///
/// Streams:
///   [audioOutput]     — raw PCM bytes (24 kHz, 16-bit, mono) for playback
///   [phoneticResults] — structured STT evaluation responses
///   [npcStateEvents]  — MaveState.speaking / .idle driven by server events
class GeminiLiveService {
  // v1alpha endpoint — required for Gemini 2.5 flash native audio
  static const String _wsBase =
      'wss://generativelanguage.googleapis.com/ws/'
      'google.ai.generativelanguage.v1alpha.'
      'GenerativeService.BidiGenerateContent';

  static const String _model =
      'models/gemini-2.5-flash-preview-native-audio-dialog';

  static const String _systemInstruction =
      'You are Mave, a warm and playful tutor for a 2-year-old learning phonics. '
      'Speak slowly, clearly, and with great enthusiasm. '
      'Use very simple words and short sentences. '
      'Analyse audio input for phonetic matching — not perfect pronunciation. '
      'Celebrate every attempt.';

  WebSocketChannel? _channel;
  bool _setupComplete = false;

  final _audioOutputController = StreamController<Uint8List>.broadcast();
  final _phoneticResultController = StreamController<PhoneticResult>.broadcast();
  final _textController = StreamController<String>.broadcast();
  final _npcStateController = StreamController<MaveState>.broadcast();

  Stream<Uint8List> get audioOutput => _audioOutputController.stream;
  Stream<PhoneticResult> get phoneticResults => _phoneticResultController.stream;
  Stream<String> get textOutput => _textController.stream;

  /// Emits [MaveState.speaking] on incoming audio, [MaveState.idle] on turnComplete.
  Stream<MaveState> get npcStateEvents => _npcStateController.stream;

  bool get isReady => _setupComplete && _channel != null;

  String? _apiKey;

  void init(String apiKey) => _apiKey = apiKey;

  Future<void> connect() async {
    if (_apiKey == null || _apiKey!.isEmpty) return;

    final uri = Uri.parse('$_wsBase?key=$_apiKey');
    _channel = WebSocketChannel.connect(uri);
    _setupComplete = false;

    // Await TCP + WebSocket handshake before sending anything.
    try {
      await _channel!.ready;
    } catch (_) {
      _channel = null;
      return;
    }

    _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);
    _sendSetup();
  }

  void _sendSetup() {
    final setup = {
      'setup': {
        'model': _model,
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {'voiceName': 'Puck'},
            },
          },
        },
        'systemInstruction': {
          'parts': [
            {'text': _systemInstruction},
          ],
        },
      },
    };
    _channel?.sink.add(jsonEncode(setup));
  }

  void _onMessage(dynamic raw) {
    try {
      final Map<String, dynamic> msg = jsonDecode(raw as String);

      if (msg.containsKey('setupComplete')) {
        _setupComplete = true;
        return;
      }

      final serverContent = msg['serverContent'];
      if (serverContent == null) return;

      final modelTurn = serverContent['modelTurn'];
      if (modelTurn != null) {
        final parts = modelTurn['parts'] as List<dynamic>? ?? [];
        for (final part in parts) {
          final inlineData = part['inlineData'];
          if (inlineData != null) {
            final String? mimeType = inlineData['mimeType'] as String?;
            final String? dataB64 = inlineData['data'] as String?;
            if (mimeType != null &&
                mimeType.startsWith('audio/') &&
                dataB64 != null) {
              final bytes = base64.decode(dataB64);
              _audioOutputController.add(Uint8List.fromList(bytes));
              _npcStateController.add(MaveState.speaking);
            }
          }
          final text = part['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _textController.add(text);
            _evaluatePhonetic(text);
          }
        }
      }

      if (serverContent['turnComplete'] == true) {
        _npcStateController.add(MaveState.idle);
      }
    } catch (_) {}
  }

  void _evaluatePhonetic(String text) {
    final lower = text.toLowerCase();
    final bool matched = lower.contains('yes') ||
        lower.contains('correct') ||
        lower.contains('great') ||
        lower.contains('good') ||
        lower.contains('match') ||
        lower.contains('yay') ||
        lower.contains('well done');
    _phoneticResultController.add(PhoneticResult(
      matched: matched,
      confidence: matched ? 0.9 : 0.3,
      rawText: text,
    ));
  }

  void _onError(Object error) {
    _setupComplete = false;
    _channel = null;
  }

  void _onDone() {
    _setupComplete = false;
  }

  /// Ask Gemini to say [text] aloud via TTS.
  Future<void> speak(String text) async {
    if (!_setupComplete) await _waitForSetup();
    if (_channel == null) return;
    final msg = {
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': text},
            ],
          },
        ],
        'turnComplete': true,
      },
    };
    _channel!.sink.add(jsonEncode(msg));
  }

  /// Stream a chunk of 16-bit PCM audio (16 kHz) for STT analysis.
  void sendAudioChunk(List<int> pcmBytes) {
    if (_channel == null) return;
    final msg = {
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': 'audio/pcm;rate=16000',
            'data': base64.encode(Uint8List.fromList(pcmBytes)),
          },
        ],
      },
    };
    _channel!.sink.add(jsonEncode(msg));
  }

  /// Ask Gemini to evaluate whether the child's recent audio matched [targetWord].
  Future<void> evaluateAudio(String targetWord) async {
    if (!_setupComplete) await _waitForSetup();
    if (_channel == null) return;
    final msg = {
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {
                'text': 'Did the child just say "$targetWord"? '
                    'Reply YES or NO with one short encouraging sentence. '
                    'Be very lenient — any attempt counts.',
              },
            ],
          },
        ],
        'turnComplete': true,
      },
    };
    _channel!.sink.add(jsonEncode(msg));
  }

  Future<void> _waitForSetup({int retries = 40}) async {
    for (int i = 0; i < retries; i++) {
      if (_setupComplete) return;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _setupComplete = false;
  }

  void dispose() {
    disconnect();
    _audioOutputController.close();
    _phoneticResultController.close();
    _textController.close();
    _npcStateController.close();
  }
}

final geminiServiceProvider = Provider<GeminiLiveService>((ref) {
  final svc = GeminiLiveService();
  ref.onDispose(svc.dispose);
  return svc;
});
