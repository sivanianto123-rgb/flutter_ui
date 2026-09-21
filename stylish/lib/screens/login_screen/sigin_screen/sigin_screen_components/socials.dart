import 'package:flutter/material.dart';

class SocialMediaButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;
  final VoidCallback onAppleTap;

  const SocialMediaButtons({
    Key? key,
    required this.onGoogleTap,
    required this.onFacebookTap,
    required this.onAppleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onGoogleTap,
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/google.png'),
            radius: 27.0,
          ),
        ),
        const SizedBox(width: 20.0),
        GestureDetector(
          onTap: onFacebookTap,
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/facebook.png'),
            radius: 27.0,
          ),
        ),
        const SizedBox(width: 20.0),
        GestureDetector(
          onTap: onAppleTap,
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/apple.png'),
            radius: 27.0,
          ),
        ),
      ],
    );
  }
}
