import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';
import '../common_widgets/custom_widgets.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isNewPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: ColorConstants.background,
              padding: const EdgeInsets.only(
                top: 10,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: CustomBackButton(),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                        color: ColorConstants.textcolor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'Current Password',
                      style: GoogleFonts.poppins(
                        color: ColorConstants.silenttextcolor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: ColorConstants.silenttextcolor,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            style: GoogleFonts.poppins(
                              color: ColorConstants.textcolor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: 'Enter current password',
                              hintStyle: GoogleFonts.poppins(
                                color: ColorConstants.silenttextcolor
                                    .withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: ColorConstants.divider.withOpacity(0.3)),

                    const SizedBox(height: 21),

                    Text(
                      'New Password',
                      style: GoogleFonts.poppins(
                        color: ColorConstants.silenttextcolor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: ColorConstants.silenttextcolor,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            style: GoogleFonts.poppins(
                              color: ColorConstants.textcolor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: 'Enter new password',
                              hintStyle: GoogleFonts.poppins(
                                color: ColorConstants.silenttextcolor
                                    .withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                          child: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: ColorConstants.silenttextcolor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: ColorConstants.divider.withOpacity(0.3)),

                    const SizedBox(height: 21),

                    Text(
                      'Confirm New Password',
                      style: GoogleFonts.poppins(
                        color: ColorConstants.silenttextcolor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: ColorConstants.silenttextcolor,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            style: GoogleFonts.poppins(
                              color: ColorConstants.textcolor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: 'Confirm new password',
                              hintStyle: GoogleFonts.poppins(
                                color: ColorConstants.silenttextcolor
                                    .withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: ColorConstants.divider.withOpacity(0.3)),

                    const SizedBox(height: 8),

                    Text(
                      'Both Passwords Must Match',
                      style: GoogleFonts.poppins(
                        color: ColorConstants.silenttextcolor,
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPasswordController.text.isEmpty ||
                                _newPasswordController.text.isEmpty ||
                                _confirmPasswordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    'Please fill all fields',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_newPasswordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    'New passwords do not match',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text(
                                  'Password updated successfully',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: ColorConstants.button,
                              ),
                            );

                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Change Password',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.textcolor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
