import 'package:flutter/material.dart';

class ImagePreloader {
  static final ImagePreloader _instance = ImagePreloader._internal();
  factory ImagePreloader() => _instance;
  ImagePreloader._internal();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  final List<String> _imagePaths = [
    'lib/assets/images/home_back.jpg',
    'lib/assets/images/sound_bg.jpg',
    'lib/assets/images/module_background.jpg',
    'lib/assets/images/first_s.jpg',
  ];

  Future<void> preloadImages(BuildContext context) async {
    if (_isLoaded) return;

    List<Future> futures = [];
    for (String path in _imagePaths) {
      futures.add(precacheImage(AssetImage(path), context));
    }

    await Future.wait(futures);
    _isLoaded = true;
  }
}
