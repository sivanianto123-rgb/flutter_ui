import 'dart:math';

class KoalaChallengeData {
  final String title;
  final String sadAnimation;
  final String happyAnimation;
  final String sadLabel;
  final String happyLabel;

  KoalaChallengeData({
    required this.title,
    required this.sadAnimation,
    required this.happyAnimation,
    required this.sadLabel,
    required this.happyLabel,
  });

  static final List<KoalaChallengeData> challenges = [
    KoalaChallengeData(
      title: 'Lets make Mr Koala\nhappy',
      sadAnimation: 'lib/assets/animations/koala_sad.lottie',
      happyAnimation: 'lib/assets/animations/koala_happy.lottie',
      sadLabel: 'Sad',
      happyLabel: 'Happy',
    ),
    KoalaChallengeData(
      title: 'Lets make Mr Koala\nstop crying',
      sadAnimation: 'lib/assets/animations/koala_crying.lottie',
      happyAnimation: 'lib/assets/animations/koala_happy.lottie',
      sadLabel: 'Crying',
      happyLabel: 'Happy',
    ),
    KoalaChallengeData(
      title: 'Lets make Mr Koala\nlaugh',
      sadAnimation: 'lib/assets/animations/koala_sad.lottie',
      happyAnimation: 'lib/assets/animations/koala_laughing.lottie',
      sadLabel: 'Sad',
      happyLabel: 'Laughing',
    ),
    KoalaChallengeData(
      title: 'Lets feed Mr Koala',
      sadAnimation: 'lib/assets/animations/koala_angry.lottie',
      happyAnimation: 'lib/assets/animations/koala_eat.lottie',
      sadLabel: 'Hungry',
      happyLabel: 'Eating',
    ),
    KoalaChallengeData(
      title: 'Lets calm Mr Koala\ndown',
      sadAnimation: 'lib/assets/animations/koala_angry.lottie',
      happyAnimation: 'lib/assets/animations/koala_happy.lottie',
      sadLabel: 'Angry',
      happyLabel: 'Happy',
    ),
  ];

  static KoalaChallengeData getRandomChallenge() {
    final random = Random();
    return challenges[random.nextInt(challenges.length)];
  }
}
