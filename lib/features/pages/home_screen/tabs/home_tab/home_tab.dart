import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/build_card_home.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/features/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:math_house_parent_new/features/pages/home_screen/cubit/home_screen_states.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeScreenCubit homeScreenCubit = getIt<HomeScreenCubit>();

  bool get isTablet => ScreenUtil().screenWidth > 600.w; // استخدام ScreenUtil
  bool get isDesktop => ScreenUtil().screenWidth > 1024.w;

  @override
  void initState() {
    super.initState();
    if (SelectedStudent.studentId != null && SelectedStudent.studentId != 0) {
      homeScreenCubit.fetchStudentData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtil().screenWidth; // استخدام ScreenUtil بدل MediaQuery
    final crossAxisCount = (screenWidth / (isDesktop ? 300.w : isTablet ? 250.w : 220.w)).floor().clamp(2, 4);
    final childAspectRatio = isDesktop ? 1.3 : isTablet ? 1.2 : 1.0;

    print("Screen width: $screenWidth, crossAxisCount: $crossAxisCount, childAspectRatio: $childAspectRatio");
    print("MediaQuery width: ${MediaQuery.of(context).size.width}");

    return BlocProvider.value(
      value: homeScreenCubit,
      child: Scaffold(
        backgroundColor: AppColors.grey[50],
        appBar: CustomAppBar(
          showArrowBack: false,
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.w : 12.w, vertical: 10.h),
              child: Image.asset("assets/images/logo.png"),
            ),
          ],
          title: 'Home',
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            if (SelectedStudent.studentId != null && SelectedStudent.studentId != 0) {
              await homeScreenCubit.fetchStudentData();
            }
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentInfoSection(),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: isTablet ? 12.w : 5.w, // متسق مع PaymentsScreen
                    mainAxisSpacing: isTablet ? 12.h : 5.h,
                    padding: EdgeInsets.all(isTablet ? 20.r : 15.r), // متسق مع PaymentsScreen
                    children: [
                      HomeCard(
                        icon: Icons.person_rounded,
                        title: "Students",
                        subtitle: "Select your son",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.getStudent);
                        },
                      ),
                      HomeCard(
                        icon: Icons.shopping_bag_rounded,
                        title: "Packages",
                        subtitle: "Buy packages",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.selectBuyOrMyPackagesScreen);
                        },
                      ),
                      HomeCard(
                        icon: Icons.school_rounded,
                        title: "Courses",
                        subtitle: "View courses",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.selectScreen);
                        },
                      ),
                      HomeCard(
                        icon: Icons.assessment_rounded,
                        title: "Score Sheet",
                        subtitle: "Check scores",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.scoreSheet);
                        },
                      ),
                      HomeCard(
                        icon: Icons.notifications_rounded,
                        title: "Notifications",
                        subtitle: "View alerts",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.notificationsScreen);
                        },
                      ),
                      HomeCard(
                        icon: Icons.account_balance_wallet_rounded,
                        title: "Payments",
                        subtitle: "Manage payments",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.paymentsScreen);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoSection() {
    return BlocBuilder<HomeScreenCubit, HomeStates>(
      bloc: homeScreenCubit,
      builder: (context, state) {
        if (SelectedStudent.studentId == null || SelectedStudent.studentId == 0) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            padding: EdgeInsets.all(isTablet ? 24.w : 10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orange.withOpacity(0.1),
                  AppColors.orange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.orange.withOpacity(0.3),
                width: 1.5.w, // متسق مع ScreenUtil
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.person_search_rounded,
                    color: AppColors.orange,
                    size: isTablet ? 32.sp : 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Student Selected',
                        style: TextStyle(
                          fontSize: isTablet ? 18.sp : 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Please select a student to continue',
                        style: TextStyle(
                          fontSize: isTablet ? 15.sp : 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoadingState) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: isTablet ? 28.w : 24.w,
                  height: isTablet ? 28.h : 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w, // متسق مع ScreenUtil
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Loading student data...',
                  style: TextStyle(
                    fontSize: isTablet ? 17.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey[700],
                  ),
                ),
              ],
            ),
          );
        } else if (state is HomeLoadedState) {
          final studentData = state.studentResponse.studentData;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.w : 20.w,
              vertical: isTablet ? 20.h : 10.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.primary.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5.w, // متسق مع ScreenUtil
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 14.w : 12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: isTablet ? 28.sp : 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            studentData?.nickName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: isTablet ? 20.sp : 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.grey[900],
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 15.w),
                          _buildInfoDot(studentData?.grade ?? '', Colors.green, true),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildInfoDot(studentData?.category ?? '', Colors.purple, false),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is HomeErrorState) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.1),
                  Colors.red.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1.5.w, // متسق مع ScreenUtil
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: isTablet ? 32.sp : 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Loading Data',
                        style: TextStyle(
                          fontSize: isTablet ? 18.sp : 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        state.error ?? 'Failed to load student data. Please try again.',
                        style: TextStyle(
                          fontSize: isTablet ? 15.sp : 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoDot(String text, Color color, bool grade) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 8.w : 7.w,
          height: isTablet ? 8.h : 7.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          grade ? 'grade: $text' : text,
          style: TextStyle(
            fontSize: isTablet ? 15.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey[700],
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
      backgroundColor: AppColors.grey[50],
      appBar: CustomAppBar(
        title: 'Payments',
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.w : 12.w, vertical: 10.h),
            child: Image.asset("assets/images/logo.png"),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isTablet ? 12.w : 5.w,
        mainAxisSpacing: isTablet ? 12.h : 5.h,
        padding: EdgeInsets.all(isTablet ? 20.r : 15.r),
        children: [
          HomeCard(
            icon: Icons.account_balance_wallet_rounded,
            title: "Recharge Wallet",
            subtitle: "Add funds to your wallet",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.rechargeWallet);
            },
          ),
          HomeCard(
            icon: Icons.history_rounded,
            title: "Payment History",
            subtitle: "View your payment history",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.paymentHistory);
            },
          ),
          HomeCard(
            icon: Icons.account_balance_rounded,
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