import 'package:flutter/material.dart';
import 'package:stylish/screens/login_screen/forgot_password/forgot_password.dart';
import 'package:stylish/screens/login_screen/signup_screen/signup.dart';
import 'package:stylish/styles/colors/colors.dart';
import 'sigin_screen_components/common_textfield.dart';
import 'sigin_screen_components/socials.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                'Welcome\nBack!',
                style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w700),
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
              const SizedBox(height: 10.0),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: ColorsConstants.primarycolor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36.0),

              SizedBox(
                height: 66.0,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsConstants.primarycolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Create An Account ',
                          style: TextStyle(fontSize: 14.0, color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Sign Up',
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
