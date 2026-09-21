import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../assets/data/alphablock_data.dart';
import '../../widgets/alpha_blocks_widgets/confetti_overlay.dart';
import '../../widgets/alpha_blocks_widgets/drop_zone.dart';
import '../../widgets/alpha_blocks_widgets/letter_blocks.dart';
import '../../widgets/alpha_blocks_widgets/start_counter.dart';
import '../../widgets/back_button.dart';


class AlphablocksGame extends StatefulWidget {
  AlphablocksGame({Key? key}) : super(key: key);

  @override
  State<AlphablocksGame> createState() => _AlphablocksGameState();
}

class _AlphablocksGameState extends State<AlphablocksGame> {
  int _stars = 0;
  int _currentWordIndex = 0;
  List<String?> _placedLetters = [];
  List<Map<String, dynamic>> _scrambledLetters = [];
  Set<String> _usedIds = {};
  bool _showConfetti = false;
  bool _showStar = false;
  bool _isCorrect = false;
  int _shakeIndex = -1;
  final Random _random = Random();

  final List<Color> _letterColors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFD81B60),
    Color(0xFF5E35B1),
  ];

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  void _loadWord() {
    AlphablocksWord word = AlphablocksData.easyWords[_currentWordIndex];
    _placedLetters = List.filled(word.word.length, null);
    _usedIds = {};
    _isCorrect = false;
    _shakeIndex = -1;

    List<String> letters = word.word.split('');
    
    String jumbled = word.word;
    int attempts = 0;
    while (jumbled == word.word && attempts < 20) {
      letters.shuffle(_random);
      jumbled = letters.join();
      attempts++;
    }

    _scrambledLetters = [];
    for (int i = 0; i < letters.length; i++) {
      _scrambledLetters.add({
        'letter': letters[i],
        'id': '${letters[i]}_$i',
      });
    }

    setState(() {});
  }

  void _onLetterDropped(String letterId, int index) {
    if (_isCorrect) return;
    if (_placedLetters[index] != null) return;

    String letter = letterId.split('_')[0];
    AlphablocksWord word = AlphablocksData.easyWords[_currentWordIndex];
    String expectedLetter = word.word[index];

    if (letter == expectedLetter) {
      setState(() {
        _placedLetters[index] = letter;
        _usedIds.add(letterId);
      });
      _checkAnswer();
    } else {
      setState(() => _shakeIndex = index);
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) setState(() => _shakeIndex = -1);
      });
    }
  }

  void _checkAnswer() {
    AlphablocksWord word = AlphablocksData.easyWords[_currentWordIndex];

    if (_placedLetters.contains(null)) return;

    String formed = _placedLetters.join();

    if (formed == word.word) {
      _onCorrectAnswer();
    }
  }

  void _onCorrectAnswer() {
    setState(() {
      _isCorrect = true;
      _showStar = true;
      _showConfetti = true;
    });
  }

  void _onStarComplete() {
    setState(() {
      _stars++;
      _showStar = false;
    });
  }

  void _onConfettiComplete() {
    setState(() => _showConfetti = false);

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) _nextWord();
    });
  }

  void _nextWord() {
    setState(() {
      _currentWordIndex = (_currentWordIndex + 1) % AlphablocksData.easyWords.length;
    });
    _loadWord();
  }

  void _resetWord() {
    _loadWord();
  }

  Color _getColorForLetter(String letter) {
    int index = letter.codeUnitAt(0) % _letterColors.length;
    return _letterColors[index];
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    AlphablocksWord currentWord = AlphablocksData.easyWords[_currentWordIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('lib/assets/images/sound_bg.jpg', fit: BoxFit.cover),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Spacer(),
                  _buildScrambledLetters(),
                  SizedBox(height: h * 0.06),
                  _buildDropZones(currentWord.word),
                  Spacer(),
                  _buildResetButton(),
                  SizedBox(height: h * 0.04),
                ],
              ),
            ),
            if (_showConfetti)
              ConfettiOverlay(onComplete: _onConfettiComplete),
            if (_showStar)
              Center(child: AnimatedStar(onComplete: _onStarComplete)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBackButton(onPressed: () => Navigator.pop(context)),
          StarCounter(stars: _stars),
        ],
      ),
    );
  }

  Widget _buildScrambledLetters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _scrambledLetters.map((item) {
        String letter = item['letter'];
        String id = item['id'];
        bool isUsed = _usedIds.contains(id);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: DraggableLetterBlock(
            letter: letter,
            letterId: id,
            color: _getColorForLetter(letter),
            isUsed: isUsed,
            size: 70,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropZones(String word) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(word.length, (i) {
        return DropZone(
          index: i,
          placedLetter: _placedLetters[i],
          expectedLetter: word[i],
          onLetterDropped: _onLetterDropped,
          isShaking: _shakeIndex == i,
        );
      }),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _resetWord,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          'Reset',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}