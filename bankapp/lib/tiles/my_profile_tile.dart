import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

class ProfileMenuTiles extends StatelessWidget {
  final Function(BuildContext) navigateToPaymentHistory;
  final Function(BuildContext) navigateToAllCards;

  const ProfileMenuTiles({
    super.key,
    required this.navigateToPaymentHistory,
    required this.navigateToAllCards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          buildMenuTile(
            context,
            icon: Icons.person_outline,
            title: 'Personal Information',
          ),
          buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment History',
            onTap: () => navigateToPaymentHistory(context),
          ),
          buildMenuTile(
            context,
            icon: Icons.credit_card,
            title: 'Banks and Cards',
            onTap: () => navigateToAllCards(context),
          ),
          buildMenuTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: ColorConstants.textcolor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          buildMenuTile(
            context,
            icon: Icons.message_outlined,
            title: 'Message Center',
          ),
          buildMenuTile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Address',
          ),
          buildMenuTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Icon(icon, color: ColorConstants.silenttextcolor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: ColorConstants.textcolor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: ColorConstants.silenttextcolor,
                      size: 24,
                    ),
              ],
            ),
          ),
        ),
        Divider(color: ColorConstants.divider.withOpacity(0.2), height: 1),
      ],
    );
  }
}
