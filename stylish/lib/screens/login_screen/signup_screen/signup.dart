import 'package:flutter/material.dart';
import 'package:stylish/styles/colors/colors.dart';

import '../sigin_screen/sigin_screen_components/common_textfield.dart';
import '../sigin_screen/sigin_screen_components/socials.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 19.0),

              const Text(
                'Create\nan Account',
                style: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 36.0),

              CustomTextField(
                hintText: 'Username or Email',
                controller: emailController,
                icon: Icons.person,
                backgroundColor: ColorsConstants.textfieldbackground,
              ),
              const SizedBox(height: 31.0),

              CustomTextField(
                hintText: 'Password',
                controller: passwordController,
                isPassword: true,
                icon: Icons.lock,
                backgroundColor: ColorsConstants.textfieldbackground,
              ),
              const SizedBox(height: 31.0),

              CustomTextField(
                hintText: 'Confirm Password',
                controller: confirmPasswordController,
                isPassword: true,
                icon: Icons.lock,
                backgroundColor: ColorsConstants.textfieldbackground,
              ),
              const SizedBox(height: 36.0),

              SizedBox(
                height: 66.0,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 1),
                        content: const Text('Account Created Successfully!'),
                        backgroundColor: ColorsConstants.primarycolor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsConstants.primarycolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64.0),

              const Text(
                '- OR Continue with -',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0, color: Colors.black54),
              ),
              const SizedBox(height: 20.0),

              SocialMediaButtons(
                onGoogleTap: () {},
                onFacebookTap: () {},
                onAppleTap: () {},
              ),
              const SizedBox(height: 30.0),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'I Already Have an Account ',
                          style: TextStyle(fontSize: 14.0, color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: ColorsConstants.primarycolor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
