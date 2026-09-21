import 'package:bankapp/tiles/my_profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/subpages/editprofile.dart';
import 'package:bankapp/subpages/paymenthistory.dart';
import 'package:bankapp/subpages/allcards.dart';
import 'package:bankapp/common_widgets/custom_widgets.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

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

                  Center(
                    child: Text(
                      'Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textcolor,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfile(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      'lib/assets/images/profile.png',
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanya Myroniuk',
                        style: GoogleFonts.poppins(
                          color: ColorConstants.textcolor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Senior Designer',
                        style: GoogleFonts.poppins(
                          color: ColorConstants.silenttextcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ProfileMenuTiles(
                navigateToPaymentHistory: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Paymenthistory(),
                    ),
                  );
                },
                navigateToAllCards: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllCards()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
