import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  const AppSettings({
    required this.volume,
    required this.isMuted,
    required this.isDarkMode,
  });

  final double volume;
  final bool isMuted;
  final bool isDarkMode;

  AppSettings copyWith({
    double? volume,
    bool? isMuted,
    bool? isDarkMode,
  }) {
    return AppSettings(
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
      : super(
          const AppSettings(
            volume: 0.75,
            isMuted: false,
            isDarkMode: false,
          ),
        );

  void setVolume(double value) {
    state = state.copyWith(volume: value);
  }

  void setMuted(bool value) {
    state = state.copyWith(isMuted: value);
  }

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);
