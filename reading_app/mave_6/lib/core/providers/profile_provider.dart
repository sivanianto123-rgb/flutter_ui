import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────

class ChildProfile {
  final String  name;
  final String? parentEmail;

  const ChildProfile({required this.name, this.parentEmail});
}

// ── Notifier ──────────────────────────────────────────────────────────────

class ProfileNotifier extends AsyncNotifier<ChildProfile?> {
  @override
  Future<ChildProfile?> build() async {
    final data = await PreferencesService.loadProfile();
    if (data.name == null || data.name!.isEmpty) return null;
    return ChildProfile(name: data.name!, parentEmail: data.email);
  }

  Future<void> createProfile(String name, {String? parentEmail}) async {
    await PreferencesService.saveProfile(name, email: parentEmail);
    state = AsyncData(ChildProfile(name: name, parentEmail: parentEmail));
  }
}

// ── Provider ──────────────────────────────────────────────────────────────

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ChildProfile?>(() => ProfileNotifier());
