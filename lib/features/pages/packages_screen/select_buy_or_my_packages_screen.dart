import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/build_card_home.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';

import '../my_packages_screen/cubit/my_package_cubit.dart';

class SelectBuyOrMyPackagesScreen extends StatelessWidget {
  const SelectBuyOrMyPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: CustomAppBar(
        title: 'Packages',
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
              title: "My Packages",
              subtitle: "View your Packages",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.myPackagesScreen);
              },
            ),
            SizedBox(height: 16.h),
            HomeCard(
              icon: Icons.attach_money,
              title: "Buy Packages",
              subtitle: "Go to Buy Packages",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.packagesScreen);
              },
            ),
            SizedBox(height: 16.h),
            // HomeCard(
            //   icon: Icons.card_giftcard,
            //   title: "Buy Packages",
            //   subtitle: "Go to Buy packages",
            //   onTap: () {
            //     Navigator.pushNamed(context, AppRoutes.packagesScreen);
            //   },
            // ),
            // SizedBox(height: 16.h),
            // HomeCard(
            //   icon: Icons.inventory,
            //   title: "My Packages",
            //   subtitle: "View your active packages",
            //   onTap: () {
            //     // No navigation, show package details inline
            //   },
            //   child: Padding(
            //     padding: EdgeInsets.all(16.r),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Your Active Package',
            //           style: TextStyle(
            //             fontSize: 18.sp,
            //             fontWeight: FontWeight.bold,
            //             color: AppColors.primaryColor,
            //           ),
            //         ),
            //         SizedBox(height: 2.h),
            //         BlocBuilder<MyPackageCubit, MyPackageState>(
            //           builder: (context, state) {
            //             if (state is MyPackageInitial) {
            //               return Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text('Preparing your packages...'),
            //                   SizedBox(height: 2.h),
            //                   Text(
            //                     'You must check if you have selected your student.',
            //                     style: TextStyle(
            //                       color: AppColors.darkGray,
            //                       fontSize: 14.sp,
            //                     ),
            //                   ),
            //                 ],
            //               );
            //             } else if (state is MyPackageLoading) {
            //               return Center(
            //                 child: CircularProgressIndicator(
            //                   color: AppColors.primary,
            //                   strokeWidth: 4.w,
            //                 ),
            //               );
            //             } else if (state is MyPackageLoaded) {
            //               if (state.package.exams == 0 &&
            //                   state.package.questions == 0 &&
            //                   state.package.lives == 0) {
            //                 return Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       'No Active Packages',
            //                       style: TextStyle(
            //                         fontSize: 16.sp,
            //                         fontWeight: FontWeight.w600,
            //                         color: AppColors.primaryColor,
            //                       ),
            //                     ),
            //                     SizedBox(height: 8.h),
            //                     Text(
            //                       'You don\'t have any active packages.',
            //                       style: TextStyle(
            //                         fontSize: 14.sp,
            //                         color: AppColors.grey,
            //                       ),
            //                     ),
            //                     SizedBox(height: 8.h),
            //                     TextButton(
            //                       onPressed: () {
            //                         context.read<MyPackageCubit>().fetchMyPackageData(
            //                           userId: SelectedStudent.studentId,
            //                         );
            //                       },
            //                       child: Text(
            //                         'Refresh',
            //                         style: TextStyle(
            //                           color: AppColors.primary,
            //                           fontSize: 14.sp,
            //                           fontWeight: FontWeight.w600,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 );
            //               }
            //               return Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   _buildBulletPoint(
            //                     icon: Icons.quiz,
            //                     label: 'Exams',
            //                     value: '${state.package.exams ?? 0}',
            //                     color: AppColors.primary,
            //                   ),
            //                   SizedBox(height: 8.h),
            //                   _buildBulletPoint(
            //                     icon: Icons.question_answer,
            //                     label: 'Questions',
            //                     value: '${state.package.questions ?? 0}',
            //                     color: AppColors.blue,
            //                   ),
            //                   SizedBox(height: 8.h),
            //                   _buildBulletPoint(
            //                     icon: Icons.live_tv,
            //                     label: 'Lives',
            //                     value: '${state.package.lives ?? 0}',
            //                     color: AppColors.green,
            //                   ),
            //                 ],
            //               );
            //             } else if (state is MyPackageError) {
            //               return Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       Text(
            //                         'Error Loading Packages',
            //                         style: TextStyle(
            //                           fontSize: 16.sp,
            //                           fontWeight: FontWeight.w600,
            //                           color: AppColors.red,
            //                         ),
            //                       ),
            //                       TextButton(
            //                         onPressed: () {
            //                           context.read<MyPackageCubit>().fetchMyPackageData(
            //                             userId: SelectedStudent.studentId,
            //                           );
            //                         },
            //                         child: Text(
            //                           'Try Again',
            //                           style: TextStyle(
            //                             color: AppColors.primary,
            //                             fontSize: 14.sp,
            //                             fontWeight: FontWeight.w600,
            //                           ),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   SizedBox(height: 3.h),
            //                   Text(
            //                     'You must check if you have selected your student.',
            //                     style: TextStyle(
            //                       fontSize: 14.sp,
            //                       color: AppColors.black,
            //                     ),
            //                   ),
            //                 ],
            //               );
            //             }
            //             return const SizedBox.shrink();
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }


}