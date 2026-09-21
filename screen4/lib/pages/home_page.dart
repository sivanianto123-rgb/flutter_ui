import 'package:flutter/material.dart';
import 'package:screen4/components/bottomnavbar.dart';
import 'package:screen4/components/chats.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
 Widget build(BuildContext context) {
 return Scaffold(
   backgroundColor: Colors.white,
 body: Padding(
padding: const EdgeInsets.only(top: 120, left: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
	children: [
	const Text(
	"All Messages",
	style: TextStyle(
	fontSize: 18,
	fontWeight: FontWeight.bold,
                color: Colors.black,
        ),
     ),
      const SizedBox(height: 24),
         Expanded(child: ChatList()),
       ],
      ),
   ),
	bottomNavigationBar: const BottomNavbar(),
  ); }}
