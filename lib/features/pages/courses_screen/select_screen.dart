import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/build_card_home.dart';
import '../../../core/widgets/custom_app_bar.dart';

class SelectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 180.w).floor();
    final childAspectRatio = screenWidth > 600 ? 1.2 : 1.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Courses',
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Image.asset("assets/images/logo.png"),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 16.w),
        child: ListView(
          shrinkWrap: true,
          children: [
            HomeCard(
              icon: Icons.card_membership,
              title: "My Courses",
              subtitle: "View your courses",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.myCourse);
              },
            ),
            SizedBox(height: 16.h),
            HomeCard(
              icon: Icons.attach_money,
              title: "Buy Courses",
              subtitle: "Go to Buy Courses",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.buyCourse);
              },
            ),
          ],
        ),
      ),


    );
  }
}
