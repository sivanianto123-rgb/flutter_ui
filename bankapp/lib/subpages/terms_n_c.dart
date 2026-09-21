// terms_n_c.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

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
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: ColorConstants.textcolor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Terms & Condition',
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
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '15.1 ',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Thank you for visiting our Application Doctor 24×7 and enrolling as a member.',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '15.2 ',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Your privacy is important to us. To better protect your privacy, we are providing this notice explaining our policy with regards to the information you share with us. This privacy policy related to the information we collect, online from Application, received through the email, by fax or telephone, or in person or in any other way and retain and use for the purpose of providing you services. If you do not agree to the terms in this Policy, we kindly ask you not to use these portals and/or sign the contract document.',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '15.3 ',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text:
                                'In order to use the services of this Application, You are required to register yourself by verifying the authorised device. This Privacy Policy applies to your information that we collect and receive on and through Doctor 24×7; it does not apply to practices of businesses that we do not own or control or people we do not employ.',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '15.4 ',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text:
                                'By using this Application, you agree to the terms of this Privacy Policy.',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
