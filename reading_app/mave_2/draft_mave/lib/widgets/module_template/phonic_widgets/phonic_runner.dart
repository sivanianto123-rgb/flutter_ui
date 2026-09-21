// import 'dart:math' as math;

// import '../../../utils/common_import.dart';

// class PhonicRunner extends StatefulWidget {
//   final String sound;

//   const PhonicRunner({super.key, required this.sound});

//   @override
//   State<PhonicRunner> createState() => _PhonicRunnerState();
// }

// class _PhonicRunnerState extends State<PhonicRunner>
//     with TickerProviderStateMixin {
//   late AnimationController _gameController;
//   late AnimationController _wordController;

//   final List<WordEnding> _endings = [];
//   final math.Random _random = math.Random();

//   bool _isJumping = false;
//   double _jumpProgress = 0;
//   int _endingIndex = 0;

//   String? _formedWord;
//   String? _formedEnding;

//   final double _playerX = 0.12;
//   final double _endingSpeed = 0.008;
//   final List<String> _wordEndings = ['t', 'd', 'g', 'n', 'll'];

//   @override
//   void initState() {
//     super.initState();
//     _gameController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();

//     _wordController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     _spawnEndings();
//   }

//   void _spawnEndings() async {
//     await Future.delayed(const Duration(seconds: 2));
//     while (mounted) {
//       await Future.delayed(const Duration(milliseconds: 200));
//       if (!mounted) return;

//       if (_endings.where((e) => !e.collected).isEmpty && _formedWord == null) {
//         _endings.add(
//           WordEnding(
//             position: 1.1,
//             ending: _wordEndings[_endingIndex % _wordEndings.length],
//           ),
//         );
//         _endingIndex++;
//       }
//     }
//   }

//   void _onTap() {
//     if (_isJumping || _formedWord != null) return;

//     for (var ending in _endings) {
//       if (!ending.collected &&
//           ending.position <= _playerX + 0.3 &&
//           ending.position > _playerX - 0.1) {
//         ending.collected = true;
//         _showFormedWord(ending.ending);
//         return;
//       }
//     }

//     _isJumping = true;
//     _jumpProgress = 0;
//   }

//   void _updateGame() {
//     if (_formedWord != null) return;

//     for (int i = _endings.length - 1; i >= 0; i--) {
//       _endings[i].position -= _endingSpeed;

//       if (_endings[i].position < -0.2) {
//         _endings.removeAt(i);
//       }
//     }

//     if (_isJumping) {
//       _jumpProgress += 0.03;
//       if (_jumpProgress >= 1.0) {
//         _isJumping = false;
//         _jumpProgress = 0;
//       }
//     }
//   }

//   void _showFormedWord(String ending) {
//     _formedWord = '${widget.sound}$ending';
//     _formedEnding = ending;
//     _wordController.forward(from: 0);

//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         _wordController.reverse().then((_) {
//           if (mounted) {
//             setState(() {
//               _formedWord = null;
//               _formedEnding = null;
//             });
//           }
//         });
//       }
//     });
//   }

//   double _getPlayerY(double s) {
//     final time = DateTime.now().millisecondsSinceEpoch * 0.004;
//     final waveY = math.sin(time) * s * 0.01;

//     if (_isJumping) {
//       final t = _jumpProgress;
//       final jumpArc = math.sin(t * math.pi);
//       return jumpArc * s * 0.1 + waveY * (1 - jumpArc);
//     }
//     return waveY;
//   }

//   @override
//   void dispose() {
//     _gameController.dispose();
//     _wordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final s = size.shortestSide;

//     return GestureDetector(
//       onTap: _onTap,
//       behavior: HitTestBehavior.opaque,
//       child: SizedBox(
//         width: size.width,
//         height: s * 0.25,
//         child: AnimatedBuilder(
//           animation: Listenable.merge([_gameController, _wordController]),
//           builder: (context, child) {
//             _updateGame();
//             final playerY = _getPlayerY(s);

//             return Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // Ground line
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: s * 0.025,
//                   child: Container(
//                     height: 2,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           AppColors.moduleCircleStroke.withValues(alpha: 0.0),
//                           AppColors.moduleCircleStroke.withValues(alpha: 0.6),
//                           AppColors.moduleCircleStroke.withValues(alpha: 0.6),
//                           AppColors.moduleCircleStroke.withValues(alpha: 0.0),
//                         ],
//                         stops: const [0.0, 0.15, 0.85, 1.0],
//                       ),
//                     ),
//                   ),
//                 ),

//                 if (_formedWord == null)
//                   Positioned(
//                     left: s * _playerX,
//                     bottom: s * 0.035 + playerY,
//                     child: Text(
//                       widget.sound,
//                       style: GoogleFonts.fredoka(
//                         fontSize: s * 0.07,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.moduleCircleStroke,
//                       ),
//                     ),
//                   ),

//                 ..._endings.where((e) => !e.collected).map((ending) {
//                   return Positioned(
//                     left: ending.position * size.width,
//                     bottom: s * 0.035,
//                     child: Text(
//                       ending.ending,
//                       style: GoogleFonts.fredoka(
//                         fontSize: s * 0.07,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.primaryText,
//                       ),
//                     ),
//                   );
//                 }),

//                 if (_formedWord != null)
//                   Positioned.fill(
//                     child: Center(
//                       child: Transform.scale(
//                         scale: 0.5 + (_wordController.value * 0.5),
//                         child: Opacity(
//                           opacity: _wordController.value.clamp(0.0, 1.0),
//                           child: RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: widget.sound,
//                                   style: GoogleFonts.fredoka(
//                                     fontSize: s * 0.15,
//                                     fontWeight: FontWeight.w700,
//                                     color: AppColors.moduleCircleStroke,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: _formedEnding,
//                                   style: GoogleFonts.fredoka(
//                                     fontSize: s * 0.15,
//                                     fontWeight: FontWeight.w700,
//                                     color: AppColors.primaryText,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class WordEnding {
//   double position;
//   String ending;
//   bool collected;

//   WordEnding({
//     required this.position,
//     required this.ending,
//     this.collected = false,
//   });
// }
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/common_import.dart';

class PhonicRunner extends StatefulWidget {
  final String sound;
  final Function(String)? onWordFormed;

  const PhonicRunner({super.key, required this.sound, this.onWordFormed});

  @override
  State<PhonicRunner> createState() => _PhonicRunnerState();
}

class _PhonicRunnerState extends State<PhonicRunner>
    with TickerProviderStateMixin {
  late AnimationController _gameController;
  late AnimationController _wordController;

  final List<WordEnding> _endings = [];

  bool _isJumping = false;
  double _jumpProgress = 0;
  int _endingIndex = 0;

  String? _formedWord;
  String? _formedEnding;

  final double _playerX = 0.12;
  final double _endingSpeed = 0.008;
  final List<String> _wordEndings = ['ll'];

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _wordController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _spawnEndings();
  }

  void _spawnEndings() async {
    await Future.delayed(const Duration(seconds: 2));
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      if (_endings.where((e) => !e.collected).isEmpty && _formedWord == null) {
        _endings.add(
          WordEnding(
            position: 1.1,
            ending: _wordEndings[_endingIndex % _wordEndings.length],
          ),
        );
        _endingIndex++;
      }
    }
  }

  void _onTap() {
    if (_isJumping || _formedWord != null) return;

    for (var ending in _endings) {
      if (!ending.collected &&
          ending.position <= _playerX + 0.3 &&
          ending.position > _playerX - 0.1) {
        ending.collected = true;
        _showFormedWord(ending.ending);
        return;
      }
    }

    _isJumping = true;
    _jumpProgress = 0;
  }

  void _updateGame() {
    if (_formedWord != null) return;

    for (int i = _endings.length - 1; i >= 0; i--) {
      _endings[i].position -= _endingSpeed;

      if (_endings[i].position < -0.2) {
        _endings.removeAt(i);
      }
    }

    if (_isJumping) {
      _jumpProgress += 0.03;
      if (_jumpProgress >= 1.0) {
        _isJumping = false;
        _jumpProgress = 0;
      }
    }
  }

  void _showFormedWord(String ending) {
    _formedWord = '${widget.sound}$ending';
    _formedEnding = ending;
    _wordController.forward(from: 0);

    widget.onWordFormed?.call(_formedWord!);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _wordController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _formedWord = null;
              _formedEnding = null;
            });
          }
        });
      }
    });
  }

  double _getPlayerY(double s) {
    final time = DateTime.now().millisecondsSinceEpoch * 0.004;
    final waveY = math.sin(time) * s * 0.01;

    if (_isJumping) {
      final t = _jumpProgress;
      final jumpArc = math.sin(t * math.pi);
      return jumpArc * s * 0.1 + waveY * (1 - jumpArc);
    }
    return waveY;
  }

  @override
  void dispose() {
    _gameController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.shortestSide;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size.width,
        height: s * 0.25,
        child: AnimatedBuilder(
          animation: Listenable.merge([_gameController, _wordController]),
          builder: (context, child) {
            _updateGame();
            final playerY = _getPlayerY(s);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: s * 0.025,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.moduleCircleStroke.withValues(alpha: 0.0),
                          AppColors.moduleCircleStroke.withValues(alpha: 0.6),
                          AppColors.moduleCircleStroke.withValues(alpha: 0.6),
                          AppColors.moduleCircleStroke.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.15, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),

                if (_formedWord == null)
                  Positioned(
                    left: s * _playerX,
                    bottom: s * 0.035 + playerY,
                    child: Text(
                      widget.sound,
                      style: GoogleFonts.fredoka(
                        fontSize: s * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.moduleCircleStroke,
                      ),
                    ),
                  ),

                ..._endings.where((e) => !e.collected).map((ending) {
                  return Positioned(
                    left: ending.position * size.width,
                    bottom: s * 0.035,
                    child: Text(
                      ending.ending,
                      style: GoogleFonts.fredoka(
                        fontSize: s * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  );
                }),

                if (_formedWord != null)
                  Positioned.fill(
                    child: Center(
                      child: Transform.scale(
                        scale: 0.5 + (_wordController.value * 0.5),
                        child: Opacity(
                          opacity: _wordController.value.clamp(0.0, 1.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.sound,
                                  style: GoogleFonts.fredoka(
                                    fontSize: s * 0.15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.moduleCircleStroke,
                                  ),
                                ),
                                TextSpan(
                                  text: _formedEnding,
                                  style: GoogleFonts.fredoka(
                                    fontSize: s * 0.15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WordEnding {
  double position;
  String ending;
  bool collected;

  WordEnding({
    required this.position,
    required this.ending,
    this.collected = false,
  });
}
