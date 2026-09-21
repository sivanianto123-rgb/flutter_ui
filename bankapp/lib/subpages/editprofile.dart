import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Required for input formatters
import 'package:bankapp/colors/colors.dart';

import '../common_widgets/custom_widgets.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nameController = TextEditingController(text: "Tanya Myroniuk");
  final _emailController = TextEditingController(
    text: "tanya.myroniuk@gmail.com",
  );
  final _phoneController = TextEditingController(text: "+8801712663389");

  DateTime _selectedDate = DateTime(2000, 9, 28);
  bool _showDatePicker = false;

  String savedName = "";
  String savedEmail = "";
  String savedPhone = "";

  void _saveChanges() {
    setState(() {
      savedName = _nameController.text;
      savedEmail = _emailController.text;
      savedPhone = _phoneController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully!',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: ColorConstants.button,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _showDatePickerModal() {
    setState(() {
      _showDatePicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                        child: CustomBackButton(),
                      ),
                      Center(
                        child: Text(
                          "Edit Profile",
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage: AssetImage(
                                      'lib/assets/images/profile.png',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                _nameController.text,
                                style: GoogleFonts.poppins(
                                  color: ColorConstants.textcolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Senior Designer",
                                style: GoogleFonts.poppins(
                                  color: ColorConstants.silenttextcolor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Full Name",
                          style: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outlined,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                style: GoogleFonts.poppins(
                                  color: ColorConstants.textcolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Enter your name',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(color: ColorConstants.divider),
                        SizedBox(height: 16),
                        Text(
                          "Email Address",
                          style: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              Icons.mail_outline,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                style: GoogleFonts.poppins(
                                  color: ColorConstants.textcolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Enter your email',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(color: ColorConstants.divider),
                        SizedBox(height: 10),
                        Text(
                          "Phone Number",
                          style: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: GoogleFonts.poppins(
                                  color: ColorConstants.textcolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Enter your phone number',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(color: ColorConstants.divider),
                        SizedBox(height: 10),
                        Text(
                          "Birth Date",
                          style: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 14),
                        GestureDetector(
                          onTap: _showDatePickerModal,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "${_selectedDate.day}",
                                      style: GoogleFonts.poppins(
                                        color: ColorConstants.textcolor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Divider(color: ColorConstants.divider),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      _getMonthName(_selectedDate.month),
                                      style: GoogleFonts.poppins(
                                        color: ColorConstants.textcolor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Divider(color: ColorConstants.divider),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "${_selectedDate.year}",
                                      style: GoogleFonts.poppins(
                                        color: ColorConstants.textcolor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Divider(color: ColorConstants.divider),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Center(
                          child: Text(
                            "Joined 28 Jan 2021",
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.button,
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _saveChanges,
                            child: Text(
                              "Save Changes",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.textcolor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showDatePicker)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDatePicker = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: ColorConstants.textcolor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showDatePicker = false;
                                        });
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.poppins(
                                          color: ColorConstants.silenttextcolor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showDatePicker = false;
                                        });
                                      },
                                      child: Text(
                                        "Done",
                                        style: GoogleFonts.poppins(
                                          color: ColorConstants.button,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: ColorConstants.divider.withOpacity(0.2),
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: _selectedDate,
                                  minimumDate: DateTime(1950),
                                  maximumDate: DateTime.now(),
                                  onDateTimeChanged: (DateTime newDate) {
                                    setState(() {
                                      _selectedDate = newDate;
                                    });
                                  },
                                  backgroundColor: ColorConstants.textcolor,
                                  dateOrder: DatePickerDateOrder.dmy,
                                ),
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
    );
  }
}
