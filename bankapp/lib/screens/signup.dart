import 'package:flutter/material.dart';
import 'package:bankapp/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign Up",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textcolor,
              ),
            ),

            SizedBox(height: 32),

            Text("Full Name", style: GoogleFonts.poppins(color: Colors.grey)),
            SizedBox(height: 8),

            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tanya Myroniuk",
                hintStyle: TextStyle(color: ColorConstants.textcolor),
                prefixIcon: Icon(Icons.person, color: ColorConstants.textcolor),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.silenttextcolor),
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              "Phone Number",
              style: GoogleFonts.poppins(color: ColorConstants.silenttextcolor),
            ),
            SizedBox(height: 8),

            TextField(
              style: TextStyle(color: ColorConstants.textcolor),
              decoration: InputDecoration(
                hintText: "+8801712663389",
                hintStyle: TextStyle(color: ColorConstants.textcolor),
                prefixIcon: Icon(Icons.phone, color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              "Email Address",
              style: GoogleFonts.poppins(color: ColorConstants.silenttextcolor),
            ),

            SizedBox(height: 8),

            TextField(
              style: TextStyle(color: ColorConstants.textcolor),
              decoration: InputDecoration(
                hintText: "tanyamyroniuk@gmail.com",
                hintStyle: TextStyle(color: ColorConstants.textcolor),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.silenttextcolor),
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              "Password",
              style: GoogleFonts.poppins(color: ColorConstants.silenttextcolor),
            ),
            SizedBox(height: 8),

            TextField(
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
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                    color: ColorConstants.textcolor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account. ",
                      style: GoogleFonts.poppins(
                        color: ColorConstants.silenttextcolor,
                      ),
                    ),

                    Text(
                      "Sign In",
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
