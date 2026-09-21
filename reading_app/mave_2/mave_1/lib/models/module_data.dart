class ModuleData {
  final String title;
  final List<SoundData> sounds;

  ModuleData({required this.title, required this.sounds});
}

class SoundData {
  final String name;
  final List<String> syllables;
  final String audioPath;
  final String animationPath;
  final double targetAccuracy;

  SoundData({
    required this.name,
    required this.syllables,
    required this.audioPath,
    required this.animationPath,
    this.targetAccuracy = 0.8,
  });
}
