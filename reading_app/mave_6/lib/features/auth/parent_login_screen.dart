import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../home/home_screen.dart';

class ParentLoginScreen extends ConsumerStatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  ConsumerState<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends ConsumerState<ParentLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sending = false;
  String? _status;
  StreamSubscription<Uri>? _linkSub;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _listenForOtpLinks();
  }

  Future<void> _listenForOtpLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleIncomingLink(initial.toString());
      }
      _linkSub = _appLinks.uriLinkStream.listen((uri) {
        unawaited(_handleIncomingLink(uri.toString()));
      });
    } catch (_) {
      // If link listener isn't available, user can still auth via deep link reopen.
    }
  }

  Future<void> _handleIncomingLink(String link) async {
    final ok = await ref
        .read(parentAuthControllerProvider)
        .tryCompleteOtpFromLink(link);
    if (!mounted) return;
    if (ok) {
      setState(() => _status = 'OTP verified. Signing you in...');
    }
  }

  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _status = null;
    });
    final email = _emailCtrl.text.trim();
    try {
      await ref.read(parentAuthControllerProvider).sendOtpLink(email);
      if (!mounted) return;
      setState(() {
        _status =
            'OTP link sent to $email. Open the email and tap the sign-in link.';
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final projectId = Firebase.app().options.projectId ?? '(unknown)';
      final head = 'Could not send OTP link: ${e.code}'
          '${(e.message != null && e.message!.isNotEmpty) ? ' — ${e.message}' : ''}';
      final tail = e.code == 'operation-not-allowed'
          ? '\n\nYour app is using Firebase project: $projectId\n'
              'In the Firebase Console, open that exact project → Build → '
              'Authentication → Sign-in method → Email / Password → enable the '
              'provider, then enable "Email link (passwordless sign-in)" and Save. '
              'If it is already on, try turning Email/Password off and on again, '
              'or check Google Cloud Console → APIs for this project: '
              'Identity Toolkit API must be enabled.'
          : '';
      setState(() => _status = '$head$tail');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Could not send OTP link: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Parent Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your email to get a one-time sign-in link (OTP validation).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Parent email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Please enter email';
                        return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                            ? null
                            : 'Enter a valid email';
                      },
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: _sending ? null : _sendOtp,
                      child: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send OTP Link'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () async {
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                      child: const Text('I opened the OTP link'),
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _status!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
