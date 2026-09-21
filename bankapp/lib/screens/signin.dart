import 'package:bankapp/pages/bottomnavbar.dart';
import 'package:bankapp/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});
  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => BottomNavBar(onTap: (int index) {}, currentIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign In",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textcolor,
              ),
            ),

            SizedBox(height: 31),
            Text(
              "Email Address",
              style: GoogleFonts.poppins(color: ColorConstants.silenttextcolor),
            ),
            SizedBox(height: 9),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: ColorConstants.textcolor),
              decoration: InputDecoration(
                hintText: "xx@gmail.com",
                hintStyle: GoogleFonts.poppins(
                  color: ColorConstants.silenttextcolor,
                ),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.silenttextcolor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 22),
            Text(
              "Password",
              style: GoogleFonts.poppins(color: ColorConstants.silenttextcolor),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: ColorConstants.textcolor),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: ColorConstants.textcolor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.silenttextcolor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.textcolor),
                ),
              ),
            ),
            SizedBox(height: 37),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Sign In",
                  style: GoogleFonts.poppins(
                    color: ColorConstants.textcolor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 22),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I’m a new user. ",
                      style: GoogleFonts.poppins(
                        color: ColorConstants.silenttextcolor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                        color: ColorConstants.button,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
