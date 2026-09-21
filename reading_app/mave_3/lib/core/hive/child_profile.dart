import 'package:hive/hive.dart';

part 'child_profile.g.dart';

@HiveType(typeId: 0)
class ChildProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  Map<String, int> levelProgress;

  @HiveField(2)
  int totalStars;

  @HiveField(3)
  String parentEmail;

  ChildProfile({
    required this.name,
    required this.parentEmail,
    Map<String, int>? levelProgress,
    this.totalStars = 0,
  }) : levelProgress = levelProgress ?? {};

  int getLevelFor(String syllable) => levelProgress[syllable] ?? 0;

  void setLevelFor(String syllable, int level) {
    levelProgress[syllable] = level;
    save();
  }

  void addStar() {
    totalStars++;
    save();
  }
}
