import 'dart:typed_data';
import '../../../utils/common_imports/common_imports.dart';

class KoalaContainer extends StatefulWidget {
  final bool isCorrect;

  const KoalaContainer({Key? key, required this.isCorrect}) : super(key: key);

  @override
  State<KoalaContainer> createState() => _KoalaContainerState();
}

class _KoalaContainerState extends State<KoalaContainer> {
  static const _happyPath = 'lib/assets/animations/Koala_happy.lottie';
  static const _sadPath = 'lib/assets/animations/Koala_sad.lottie';

  static Uint8List? _happyData;
  static Uint8List? _sadData;

  Uint8List? get _currentData => widget.isCorrect ? _happyData : _sadData;
  String get _currentPath => widget.isCorrect ? _happyPath : _sadPath;

  void _cacheData(Uint8List data) {
    if (widget.isCorrect) {
      _happyData = data;
    } else {
      _sadData = data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: widget.isCorrect ? 1.0 : 0.5,
      child: SizedBox(
        height: screenHeight * 0.35,
        child: _currentData != null
            ? Lottie.memory(
                _currentData!,
                fit: BoxFit.contain,
                repeat: true,
                renderCache: RenderCache.raster,
              )
            : DotLottieLoader.fromAsset(
                _currentPath,
                frameBuilder: (context, dotlottie) {
                  if (dotlottie != null) {
                    final data = dotlottie.animations.values.single;

                    if (_currentData == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _cacheData(data));
                        }
                      });
                    }

                    return Lottie.memory(
                      data,
                      fit: BoxFit.contain,
                      repeat: true,
                      renderCache: RenderCache.raster,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}
