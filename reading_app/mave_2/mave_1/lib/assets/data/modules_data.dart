import '../../models/module_data.dart';

class ModulesData {
  static ModuleData firstSounds = ModuleData(
    title: 'First Sounds',
    sounds: [
      SoundData(
        name: 'mama',
        syllables: ['ma', 'ma'],
        audioPath: 'audio/mama.wav',
        animationPath: 'lib/assets/animations/mama.lottie',
      ),
      SoundData(
        name: 'papa',
        syllables: ['pa', 'pa'],
        audioPath: 'audio/papa.wav',
        animationPath: 'lib/assets/animations/mama.lottie',
      ),
      SoundData(
        name: 'dada',
        syllables: ['da', 'da'],
        audioPath: 'audio/dada.wav',
        animationPath: 'lib/assets/animations/dada.lottie',
      ),
      SoundData(
        name: 'baba',
        syllables: ['ba', 'ba'],
        audioPath: 'audio/baba.wav',
        animationPath: 'lib/assets/animations/mama.lottie',
      ),
      SoundData(
        name: 'aaaa',
        syllables: ['aa', 'aa'],
        audioPath: 'audio/aaa.wav',
        animationPath: 'lib/assets/animations/mama.lottie',
      ),
      SoundData(
        name: 'ooo',
        syllables: ['ooo'],
        audioPath: 'audio/ooo.wav',
        animationPath: 'lib/assets/animations/mama.lottie',
      ),
      SoundData(
        name: 'eee',
        syllables: ['eee'],
        audioPath: 'audio/eee.wav',
        animationPath: 'lib/assets/animations/mama.lottie',
      ),
    ],
  );

  static ModuleData animalSounds = ModuleData(
    title: 'Animal Sounds',
    sounds: [
      SoundData(
        name: 'moo',
        syllables: ['moo'],
        audioPath: 'audio/moo.wav',
        animationPath: 'lib/assets/images/cow.png',
      ),
      SoundData(
        name: 'woof',
        syllables: ['woof'],
        audioPath: 'audio/woof.wav',
        animationPath: 'lib/assets/images/dog.png',
      ),
      SoundData(
        name: 'coo',
        syllables: ['coo'],
        audioPath: 'audio/coo.wav',
        animationPath: 'lib/assets/images/pigeon.png',
      ),
      SoundData(
        name: 'quack',
        syllables: ['quack'],
        audioPath: 'audio/quack.wav',
        animationPath: 'lib/assets/images/duck.png',
      ),
      SoundData(
        name: 'hiss',
        syllables: ['hiss'],
        audioPath: 'audio/hiss.wav',
        animationPath: 'lib/assets/images/snake.png',
      ),
    ],
  );

  static ModuleData combinations = ModuleData(
    title: 'Combinations',
    sounds: [],
  );

  static ModuleData words = ModuleData(title: 'Words', sounds: []);
}
