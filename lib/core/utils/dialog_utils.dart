import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';

class DialogUtils {
  static void showLoading({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 5,
          contentPadding: EdgeInsets.all(16.r),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 2.w,
                  backgroundColor: AppColors.grey[200],
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: AppColors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext dialogContext) {
    if (Navigator.canPop(dialogContext)) {
      Navigator.pop(dialogContext);
    }
  }

  static void showMessage({
    required BuildContext context,
    required String message,
    String? title,
    String? posActionName,
    Function? posAction,
    String? negActionName,
    Function? negAction,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        List<Widget> actions = [];

        if (posActionName != null) {
          actions.add(
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                posAction?.call();
              },
              child: Text(
                posActionName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        if (negActionName != null) {
          actions.add(
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                negAction?.call();
              },
              child: Text(
                negActionName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: AppColors.grey[600],
                ),
              ),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 5,
          contentPadding: EdgeInsets.all(16.r),
          title: Column(
            children: [
              Icon(
                title == 'Success' ? Icons.check_circle : Icons.error_outline,
                color: title == 'Success'
                    ? AppColors.primaryColor
                    : AppColors.red,
                size: 40.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                title ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: AppColors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: actions,
        );
      },
    );
  }
}
