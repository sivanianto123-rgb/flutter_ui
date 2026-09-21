import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "lib/assets/images/gr_one.png",
      "title": "Fastest Payment in\nthe world",
      "description":
          "Integrate multiple payment methods to help you up the process quickly",
    },
    {
      "image": "lib/assets/images/gr_two.png",
      "title": "The most Secure\nPlatform for Customer",
      "description":
          "Built-in Fingerprint, face recognition and more, keeping you\ncompletely safe",
    },
    {
      "image": "lib/assets/images/gr_three.png",
      "title": "Paying for Everything is \nEasy and Convenient",
      "description":
          "Built-in Fingerprint, face recognition \nand more, keeping you completely safe",
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Signin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 250,
                        child: Image.asset(
                          _onboardingData[index]['image']!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == dotIndex ? 19 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color:
                                  _currentPage == dotIndex
                                      ? ColorConstants.button
                                      : ColorConstants.dotmain,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        _onboardingData[index]['title']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: _nextPage,
              child: Container(
                width: 335,
                height: 56,
                decoration: BoxDecoration(
                  color: ColorConstants.button,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
