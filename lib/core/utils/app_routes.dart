import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/features/pages/my_packages_screen/cubit/my_package_cubit.dart';

class AppRoutes {
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgetPasswordRoute = '/forgetPassword';
  static const String getStudent = '/getStudent';
  static const String mainScreen = '/mainScreen';
  static const String confirmationScreen = '/confirmationScreen';
  static const String packagesScreen = '/packagesScreen';
  static const String paymentMethodsScreen = '/paymentMethodsScreen';
  static const String myStudentScreen = '/myStudentScreen';
  static const String buyPackageScreen = '/buyPackageScreen';
  static const String paymentHistory = '/paymentHistory';
  static const String paymentInvoice = '/paymentInvoice';
  static const String buyCourse = '/buyCourse';
  static const String scoreSheet = '/scoreSheet';
  static const String rechargeWallet = '/rechargeWallet';
  static const String walletHistory = '/walletHistory';
  static const String myPackagesScreen = '/myPackagesScreen';
  static const String notificationsScreen = '/notificationsScreen';
  static const String myCourse = '/myCourse';
  static const String splashScreen = '/splashScreen';
  static const String paymentsScreen = '/paymentsScreen';
  static const String selectScreen = '/selectScreen';

  static void goToHome(BuildContext context) {
    if (SelectedStudent.studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            "Please select a student first",
            style: TextStyle(fontSize: 14.sp, color: AppColors.white),
          ),
          padding: EdgeInsets.all(12.r),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }
    context.read<MyPackageCubit>().fetchMyPackageData(
      userId: SelectedStudent.studentId,
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      mainScreen,
      (route) => false,
      arguments: 1, // HomeTab index
    );
  }

  static void goToProfile(BuildContext context) {
    if (SelectedStudent.studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            "Please select a student first",
            style: TextStyle(fontSize: 14.sp, color: AppColors.white),
          ),
          padding: EdgeInsets.all(12.r),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      mainScreen,
      (route) => false,
      arguments: 2, // ProfileScreen index
    );
  }

  static void goToMyStudents(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      mainScreen,
      (route) => false,
      arguments: 0, // MyStudentsScreen index
    );
  }
}
