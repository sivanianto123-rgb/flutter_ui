import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/screens/signin.dart';
import 'package:bankapp/subpages/change_passwords.dart';
import 'package:bankapp/subpages/languages.dart';
import 'package:bankapp/subpages/myprofile.dart';
import 'package:bankapp/subpages/terms_n_c.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isBiometricEnabled = false;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
                    Center(
                      child: Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          color: ColorConstants.textcolor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Signin(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.logout_outlined,
                          color: ColorConstants.textcolor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'General',
                          style: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildListTile(
                          context,
                          'Language',
                          trailingText: selectedLanguage,
                          onTap: () async {
                            final newLanguage = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LanguageScreen(
                                      currentLanguage: selectedLanguage,
                                    ),
                              ),
                            );

                            if (newLanguage != null &&
                                newLanguage != selectedLanguage) {
                              setState(() {
                                selectedLanguage = newLanguage;
                              });
                            }
                          },
                        ),
                        Divider(color: ColorConstants.divider.withOpacity(0.3)),

                        _buildListTile(
                          context,
                          'My Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyProfile(),
                              ),
                            );
                          },
                        ),
                        Divider(color: ColorConstants.divider.withOpacity(0.3)),
                        _buildListTile(context, 'Contact Us', onTap: () {}),
                        Divider(color: ColorConstants.divider.withOpacity(0.3)),

                        const SizedBox(height: 20),
                        Text(
                          'Security',
                          style: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildListTile(
                          context,
                          'Change Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePassword(),
                              ),
                            );
                          },
                        ),
                        Divider(color: ColorConstants.divider.withOpacity(0.3)),

                        _buildListTile(
                          context,
                          'Privacy Policy',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const TermsAndConditions(),
                              ),
                            );
                          },
                        ),
                        Divider(color: ColorConstants.divider.withOpacity(0.3)),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Choose what data you share with us',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        // Biometric Setting
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biometric',
                                style: GoogleFonts.poppins(
                                  color: ColorConstants.textcolor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Switch(
                                value: isBiometricEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    isBiometricEnabled = value;
                                  });
                                },
                                activeColor: ColorConstants.button,
                              ),
                            ],
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

  Widget _buildListTile(
    BuildContext context,
    String title, {
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: ColorConstants.background,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: ColorConstants.textcolor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                trailingText != null
                    ? Text(
                      trailingText,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                    : Icon(
                      Icons.arrow_forward_ios,
                      color: ColorConstants.silenttextcolor,
                      size: 16,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
