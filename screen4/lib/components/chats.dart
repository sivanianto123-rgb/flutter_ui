import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final List<Map<String, dynamic>> chats = [
 {
      "name": "Geopart Etdsien",
      "message": "Your Order Just Arrived!",
      "time": "13:47",
      "image": "lib/assets/images/anger.png",
      "read": true,  },
 {
      "name": "Stevano Clirover",
      "message": "Your Order Just Arrived!",
      "time": "11:23",
      "image": "lib/assets/images/neutral.png",
      "unreadCount": 3,},
{
      "name": "Elisia Justin",
      "message": "Your Order Just Arrived!",
      "time": "11:23",
      "image": "lib/assets/images/smiley.png",
      "unreadCount": 0,},
{
      "name": "Geopart Etdsien",
      "message": "Your Order Just Arrived!",
      "time": "13:47",
      "image": "lib/assets/images/anger.png",
      "read": true,},];

  @override
  Widget build(BuildContext context) {
  return SingleChildScrollView(
child: Padding(  padding: EdgeInsets.only(right: 32),
   child: Column(
     children:
	chats.map((chat) {
         return Column(
	children: [
           Row(
     crossAxisAlignment: CrossAxisAlignment.center,
       children: [
          CircleAvatar(
              backgroundImage: AssetImage(chat["image"]),
                radius: 24,
               ),
          SizedBox(width: 24),
                   Expanded(
                   child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                       chat["name"],
                            style: TextStyle(
                 fontWeight: FontWeight.bold,
                     fontSize: 16,
            ),),
                 SizedBox(height: 3),
               Row(
            children: [
		Expanded(
                       child: Text(
                     chat["message"],
                          style: TextStyle(
                                  color: Colors.grey[600],
                               fontSize: 14,
                            ),
                        overflow: TextOverflow.ellipsis,
                          ),
                              ),
                            if (chat.containsKey("read") && chat["read"])
                                    Icon(
		Icons.done_all,
                               color: Colors.deepOrangeAccent,
                              size: 16,
                             ),   ],),],),
                ),

		Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
           children: [
                     Text(
           chat["time"],
                     style: TextStyle(
                         fontSize: 12,
                        color: Colors.grey,
              ),
             ),
                  if (chat.containsKey("unreadCount") &&
                      chat["unreadCount"] > 0)
                 Container(
                       margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.all(6),
                         decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                           ),
                       child: Text(
                       "${chat["unreadCount"]}",
		style: TextStyle(
                      color: Colors.white,
                       fontSize: 12,
                         ),  ),
                         ),
                  ],
                ),
                      ],
                ),
            SizedBox(height: 20), // Space between chat items
        ],
        );
    }).toList(),
        ),
      ),
 );}}
