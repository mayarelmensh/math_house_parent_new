import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/features/pages/students_screen/cubit/students_screen_cubit.dart';
import 'package:math_house_parent_new/features/pages/students_screen/cubit/students_screen_states.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import '../../widgets/custom_elevated_button.dart';

class MyStudentsScreen extends StatefulWidget {
  const MyStudentsScreen({super.key});

  @override
  State<MyStudentsScreen> createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends State<MyStudentsScreen> {
  final GetStudentsCubit studentsCubit = getIt<GetStudentsCubit>();

  @override
  void initState() {
    super.initState();
    studentsCubit.getMyStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Students", showArrowBack: false),
      body: BlocBuilder<GetStudentsCubit, GetStudentsStates>(
        bloc: studentsCubit,
        builder: (context, state) {
          if (state is GetStudentsLoadingState) {
            return Center(
              heightFactor: 17.333,
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 3.w,
              ),
            );
          } else if (state is GetStudentsErrorState) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(32.r),
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: AppColors.red,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'An error occurred',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Check the internet connection",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    CustomElevatedButton(
                      text: 'Try Again',
                      onPressed: () => studentsCubit.getMyStudents(),
                      backgroundColor: AppColors.primaryColor,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is GetMyStudents) {
            if (state.myStudents.isEmpty) {
              return Center(
                child: Container(
                  margin: EdgeInsets.all(32.r),
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          size: 48.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No students found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add a student to get started',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      CustomElevatedButton(
                        text: 'Add Student',
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.getStudent);
                        },
                        backgroundColor: AppColors.primaryColor,
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: state.myStudents.length,
              itemBuilder: (context, index) {
                final student = state.myStudents[index];
                final selectedId = context
                    .watch<GetStudentsCubit>()
                    .selectedStudentId;
                final isSelected = student.id == selectedId;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: isSelected
                        ? BorderSide(color: AppColors.primaryColor, width: 2.w)
                        : BorderSide(color: Colors.transparent),
                  ),
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.white,
                  margin: EdgeInsets.only(bottom: 12.h),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: isSelected
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withOpacity(0.5),
                      child: Text(
                        student.nickName?.substring(0, 1).toUpperCase() ?? "?",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      student.nickName ?? "Unknown",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${student.email ?? ""}${student.category?.cateName != null ? " \n ${student.category!.cateName}" : ""}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey[600],
                      ),
                    ),
                    onTap: () {
                      final cubit = context.read<GetStudentsCubit>();
                      cubit.selectStudent(student.id!);
                      SelectedStudent.studentId = student.id!;
                      SharedPreferenceUtils.saveData(
                        key: 'studentId',
                        value: student.id!,
                      );
                      SharedPreferenceUtils.saveData(
                        key: 'studentCategory',
                        value: student.category?.cateName ?? '',
                      );
                      debugPrint("✅ Selected Student ID: ${student.id}, Category: ${student.category?.cateName}");
                      AppRoutes.goToHome(context);
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}