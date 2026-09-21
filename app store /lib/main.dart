import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[800],
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SearchField(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SuggestedSection(),
                      SizedBox(height: 20),
                      BrowseSection(screenWidth: screenWidth),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border(top: BorderSide(color: Colors.grey[900]!, width: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NavBarItem(
                icon: Icons.article_outlined,
                label: 'Today',
                isSelected: false,
              ),
              NavBarItem(
                icon: Icons.sports_esports_outlined,
                label: 'Games',
                isSelected: false,
              ),
              NavBarItem(icon: Icons.apps, label: 'Apps', isSelected: false),
              NavBarItem(
                icon: Icons.gamepad_outlined,
                label: 'Arcade',
                isSelected: false,
              ),
              NavBarItem(icon: Icons.search, label: 'Search', isSelected: true),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 24),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Games, Apps, Stories and More',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: Icon(Icons.mic, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

class SuggestedSection extends StatelessWidget {
  const SuggestedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Suggested',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 2),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
        SizedBox(height: 10),
        SuggestedItem(
          imageUrl:
              'https://media.pocketgamer.com/artwork/na-wfertn/candy_crush_saga_5th_birthday_app_icon_png_820.webp',
          title: 'Candy Crush Soda Saga',
          description: 'Sugary Match 3 Puzzle Games!',
        ),
        Divider(color: Colors.grey[850], thickness: 0.5, height: 1),
        SuggestedItem(
          imageUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXYbJuInoBYLjrrgWddFFBeSNIIfJzVZro1_hcUK20yMprV-zaE1fItFWkYMnnFb6LY-Q&usqp=CAU',
          title: 'Among Us',
          description: '10 player thriller',
        ),
        Divider(color: Colors.grey[850], thickness: 0.5, height: 1),
        SuggestedItem(
          imageUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNhmTjAA9b6pxW66oI7vxaLeulgSPnuaHA_gEN7q4G4I2sNmK1SSI8WdtpLTslKhLBELQ&usqp=CAU',
          title: 'Pico Park',
          description: 'Cooperative puzzle game',
        ),
      ],
    );
  }
}

class SuggestedItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const SuggestedItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'In-App Purchases',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              elevation: 0,
              minimumSize: Size(0, 32),
            ),
            child: Text(
              'Get',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class BrowseSection extends StatelessWidget {
  final double screenWidth;

  const BrowseSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Browse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 2),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
        SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          childAspectRatio: 1.6,
          physics: NeverScrollableScrollPhysics(),
          children: [
            CategoryItem(
              label: 'Top Apps',
              color: Color(0xFF4A90E2),
              iconData: Icons.star,
            ),
            CategoryItem(
              label: 'Top Games',
              color: Color(0xFFF5A623),
              iconData: Icons.star,
            ),
            CategoryItem(
              label: 'Social Networking',
              color: Color(0xFF9B59B6),
              iconData: Icons.chat_bubble,
            ),
            CategoryItem(
              label: 'Casual Games',
              color: Color(0xFF2CC0D9),
              iconData: Icons.rocket,
            ),
          ],
        ),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String label;
  final Color color;
  final IconData iconData;

  const CategoryItem({
    super.key,
    required this.label,
    required this.color,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: 12,
            child: Icon(iconData, color: color, size: 32),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
