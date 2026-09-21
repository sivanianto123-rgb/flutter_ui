import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';
import '../common_widgets/custom_widgets.dart';

class LanguageScreen extends StatefulWidget {
  final String currentLanguage;
  const LanguageScreen({Key? key, required this.currentLanguage})
    : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredLanguages = [];

  final List<Map<String, dynamic>> _languageList = [
    {
      'name': 'English',
      'flag': true,
      'flagPath': 'lib/assets/images/english.png',
    },
    {
      'name': 'Australia',
      'flag': true,
      'flagPath': 'lib/assets/images/australia.png',
    },
    {
      'name': 'French',
      'flag': true,
      'flagPath': 'lib/assets/images/french.png',
    },
    {
      'name': 'Spanish',
      'flag': true,
      'flagPath': 'lib/assets/images/spanish.png',
    },
    {
      'name': 'America',
      'flag': true,
      'flagPath': 'lib/assets/images/sweden.png',
    },
    {
      'name': 'Vietnamese',
      'flag': true,
      'flagPath': 'lib/assets/images/vietnamese.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
    _filteredLanguages = List.from(_languageList);
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLanguages);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = List.from(_languageList);
      } else {
        _filteredLanguages =
            _languageList
                .where((lang) => lang['name'].toLowerCase().contains(query))
                .toList();
      }
    });
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
                        Navigator.pop(context, _selectedLanguage);
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
                      'Language',
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: ColorConstants.cardcolor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Icon(
                              Icons.search,
                              color: ColorConstants.silenttextcolor,
                            ),
                          ),
                          TextField(
                            controller: _searchController,
                            style: GoogleFonts.poppins(
                              color: ColorConstants.textcolor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search Language',
                              hintStyle: GoogleFonts.poppins(
                                color: ColorConstants.silenttextcolor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                left: 50,
                                right: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemCount: _filteredLanguages.length,
                        separatorBuilder:
                            (context, index) => Divider(
                              color: ColorConstants.divider.withOpacity(0.3),
                              height: 1,
                            ),
                        itemBuilder: (context, index) {
                          final language = _filteredLanguages[index];
                          final isSelected =
                              language['name'] == _selectedLanguage;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedLanguage = language['name'];
                                });

                                Navigator.pop(context, _selectedLanguage);
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Row(
                                  children: [
                                    if (language['flag'] == true)
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                          language['flagPath'],
                                        ),
                                      )
                                    else
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.1),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        language['name'],
                                        style: GoogleFonts.poppins(
                                          color: ColorConstants.textcolor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: ColorConstants.button,
                                        child: Icon(
                                          Icons.check,
                                          color: ColorConstants.textcolor,
                                          size: 16,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
