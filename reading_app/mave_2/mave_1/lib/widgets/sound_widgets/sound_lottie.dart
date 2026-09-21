import 'dart:typed_data';
import '../../utils/common_imports/common_imports.dart';

class SoundLottie extends StatefulWidget {
  final String animationPath;

  const SoundLottie({Key? key, required this.animationPath}) : super(key: key);

  @override
  State<SoundLottie> createState() => _SoundLottieState();
}

class _SoundLottieState extends State<SoundLottie> {
  Uint8List? _cachedData;
  bool _loaded = false;

  bool get _isPng =>
      widget.animationPath.toLowerCase().endsWith('.png') ||
      widget.animationPath.toLowerCase().endsWith('.jpg') ||
      widget.animationPath.toLowerCase().endsWith('.jpeg');

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    if (widget.animationPath.isEmpty) {
      return SizedBox(
        height: screenHeight * 0.35,
        child: const Center(
          child: Icon(Icons.pets, size: 100, color: Color(0x96FFFFFF)),
        ),
      );
    }

    if (_isPng) {
      return SizedBox(
        height: screenHeight * 0.35,
        child: Image.asset(
          widget.animationPath,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      );
    }

    if (_loaded && _cachedData != null) {
      return SizedBox(
        height: screenHeight * 0.35,
        child: Lottie.memory(
          _cachedData!,
          fit: BoxFit.contain,
          repeat: true,
          renderCache: RenderCache.raster,
        ),
      );
    }

    return SizedBox(
      height: screenHeight * 0.35,
      child: DotLottieLoader.fromAsset(
        widget.animationPath,
        frameBuilder: (context, dotlottie) {
          if (dotlottie != null) {
            final data = dotlottie.animations.values.single;

            if (!_loaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _cachedData = data;
                    _loaded = true;
                  });
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
    );
  }
}
