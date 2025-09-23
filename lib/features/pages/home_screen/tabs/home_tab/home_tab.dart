import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/build_card_home.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import '../../../my_packages_screen/cubit/my_package_cubit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if studentId is 0 and show SnackBar
    if (SelectedStudent.studentId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a student first.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),

          ),
        );
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 220.w).floor();
    final childAspectRatio = screenWidth > 600 ? 1.2 : 1.0;

    return Scaffold(
      appBar: CustomAppBar(
        showArrowBack: false,
        actions: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Image.asset("assets/images/logo.png"),
          ),
        ],
        title: 'Home',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GridView for Home Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount.clamp(2, 4),
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                padding: EdgeInsets.all(20.r),
                children: [
                  HomeCard(
                    icon: Icons.person,
                    title: "Students",
                    subtitle: "Select your son",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.getStudent);
                    },
                  ),
                  HomeCard(
                    icon: Icons.attach_money,
                    title: "Packages",
                    subtitle: "View students",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.packagesScreen);
                    },
                  ),
                  HomeCard(
                    icon: Icons.settings,
                    title: "Courses",
                    subtitle: "Go to Courses",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.selectScreen);
                    },
                  ),
                  HomeCard(
                    icon: Icons.credit_score,
                    title: "Score Sheet",
                    subtitle: "Go to Score Sheet",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.scoreSheet);
                    },
                  ),
                  HomeCard(
                    icon: Icons.notifications,
                    title: "Notifications",
                    subtitle: "View alerts",
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.notificationsScreen,
                      );
                    },
                  ),
                  HomeCard(
                    icon: Icons.account_balance_wallet,
                    title: "Payments",
                    subtitle: "Manage payments",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.paymentsScreen);
                    },
                  ),
                ],
              ),
            ),
            // My Packages Section as Bullet Points
            SizedBox(height: 20.h),
            Text(
              'Your Active Package',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            BlocBuilder<MyPackageCubit, MyPackageState>(
              builder: (context, state) {
                if (state is MyPackageInitial) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preparing your packages...'),
                      SizedBox(height: 2.h),
                      Text(
                        'You must check if you have selected your student.',
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  );
                } else if (state is MyPackageLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 4.w,
                    ),
                  );
                } else if (state is MyPackageLoaded) {
                  if (state.package.exams == 0 &&
                      state.package.questions == 0 &&
                      state.package.lives == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Active Packages',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'You don\'t have any active packages.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () {
                            context.read<MyPackageCubit>().fetchMyPackageData(
                              userId: SelectedStudent.studentId,
                            );
                          },
                          child: Text(
                            'Refresh',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulletPoint(
                        icon: Icons.quiz,
                        label: 'Exams',
                        value: '${state.package.exams ?? 0}',
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 8.h),
                      _buildBulletPoint(
                        icon: Icons.question_answer,
                        label: 'Questions',
                        value: '${state.package.questions ?? 0}',
                        color: AppColors.blue,
                      ),
                      SizedBox(height: 8.h),
                      _buildBulletPoint(
                        icon: Icons.live_tv,
                        label: 'Lives',
                        value: '${state.package.lives ?? 0}',
                        color: AppColors.green,
                      ),
                    ],
                  );
                } else if (state is MyPackageError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Loading Packages',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'You must check if you have selected your student.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () {
                          context.read<MyPackageCubit>().fetchMyPackageData(
                            userId: SelectedStudent.studentId,
                          );
                        },
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8.sp, color: color),
        SizedBox(width: 8.w),
        Icon(icon, size: 20.sp, color: color),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}



class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    final crossAxisCount = (screenWidth / (isDesktop ? 300.w : isTablet ? 250.w : 220.w)).floor().clamp(2, 4);

    final childAspectRatio = isDesktop ? 1.3 : isTablet ? 1.2 : 1.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payments',
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.w : 12.w, vertical: 10.h),
            child: Image.asset(
              "assets/images/logo.png",
              // width: isTablet ? 40.w : 32.w,
              // height: isTablet ? 40.h : 32.h,
            ),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isTablet ? 12.w : 10.w,
        mainAxisSpacing: isTablet ? 12.h : 10.h,
        padding: EdgeInsets.all(isTablet ? 20.r : 15.r),
        children: [
          HomeCard(
            icon: Icons.account_balance_wallet,
            title: "Recharge Wallet",
            subtitle: "Add funds to your wallet",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.rechargeWallet);
            },
          ),
          HomeCard(
            icon: Icons.history,
            title: "Payment History",
            subtitle: "View your payment history",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.paymentHistory);
            },
          ),
          HomeCard(
            icon: Icons.account_balance,
            title: "Wallet History",
            subtitle: "Check your wallet transactions",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.walletHistory);
            },
          ),
        ],
      ),
    );
  }
}

