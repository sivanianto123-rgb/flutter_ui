import 'package:flutter/material.dart';
import 'package:stylish/styles/colors/colors.dart';
import '../sigin_screen/sigin_screen_components/common_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

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
                'Forgot\nPassword?',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 36.0),

              CustomTextField(
                hintText: 'Enter your email address',
                controller: emailController,
                icon: Icons.email,
                backgroundColor: ColorsConstants.textfieldbackground,
              ),
              const SizedBox(height: 26.0),

              Align(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: ColorsConstants.primarycolor,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' We will send you a message to set or reset your new password',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: ColorsConstants.unselectedtext,
                        ),
                      ),
                    ],
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
                    'Submit',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
