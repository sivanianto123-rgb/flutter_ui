import 'package:flutter/material.dart';
import 'package:schedule_app/styles/colors/colors.dart';
import 'package:schedule_app/widgets/schedule/schedule.dart';
import 'package:schedule_app/widgets/subjects/subjects.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundcolor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF197561),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.search, color: AppColors.primarycolor),
                  ),
                  SizedBox(width: 90),
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/bimage.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primarycolor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Subjects(), SizedBox(height: 28), Schedule()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
