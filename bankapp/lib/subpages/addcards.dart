import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/tiles/card_tile.dart';

import '../common_widgets/custom_widgets.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController cardHolderController = TextEditingController(
    text: "Tanya Myroniuk",
  );
  final TextEditingController cardNumberController = TextEditingController(
    text: "4562 1122 4595 7852",
  );
  final TextEditingController expiryDateController = TextEditingController(
    text: "09/2024",
  );
  final TextEditingController cvvController = TextEditingController(
    text: "698",
  );

  @override
  void dispose() {
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String text) {
    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += text[i];
    }

    return formatted;
  }

  String _formatExpiryDate(String text) {
    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 6) {
      text = text.substring(0, 6);
    }

    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';

      if (year.isNotEmpty) {
        return '$month/$year';
      } else {
        return month;
      }
    }

    return text;
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
                      "Add New Card",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    CardTile(
                      cardHolder: cardHolderController.text,
                      cardNumber: cardNumberController.text,
                      expiryDate: expiryDateController.text,
                      cvv: cvvController.text,
                    ),
                    const SizedBox(height: 30),

                    _buildEditableField(
                      "Cardholder Name",
                      cardHolderController,
                      maxLength: 26,
                      keyboardType: TextInputType.name,
                    ),
                    Divider(color: ColorConstants.divider),

                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEditableField(
                                "Expiry Date",
                                expiryDateController,
                                maxLength: 7, 
                                keyboardType: TextInputType.number,
                                formatFunction: _formatExpiryDate,
                              ),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: ColorConstants.divider,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEditableField(
                                "3-digit CVV",
                                cvvController,
                                maxLength: 3,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: ColorConstants.divider,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    _buildEditableField(
                      "Card Number",
                      cardNumberController,
                      maxLength: 19, 
                      keyboardType: TextInputType.number,
                      formatFunction: _formatCardNumber,
                    ),
                    Divider(color: ColorConstants.divider),

                    const SizedBox(height: 70),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 30.0),
                        child: _buildSaveButton(context),
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

  Widget _buildEditableField(
    String title,
    TextEditingController controller, {
    int maxLength = 50,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String Function(String)? formatFunction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: ColorConstants.silenttextcolor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: (text) {
              if (formatFunction != null) {
                final formatted = formatFunction(text);
                if (formatted != text) {
                  controller.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              }
              setState(() {});
            },
            style: GoogleFonts.poppins(
              color: ColorConstants.textcolor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            keyboardType: keyboardType,
            inputFormatters:
                inputFormatters ??
                [LengthLimitingTextInputFormatter(maxLength)],
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterText: "",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.button,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Your card is saved"),
              backgroundColor: ColorConstants.button,
              behavior: SnackBarBehavior.fixed,
              duration: const Duration(seconds: 2),
            ),
          );
        },

        child: Text(
          "Save Card",
          style: GoogleFonts.poppins(
            color: ColorConstants.textcolor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
