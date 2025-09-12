import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/domain/entities/login_response_entity.dart';
import 'package:math_house_parent_new/domain/entities/get_students_response_entity.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_routes.dart';
import '../../widgets/custom_elevated_button.dart';
import '../students_screen/cubit/students_screen_cubit.dart';
import '../students_screen/cubit/students_screen_states.dart';
import 'cubit/profile_screen_cubit.dart';
import 'cubit/profile_screen_states.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

ProfileCubit profileCubit = getIt<ProfileCubit>();
GetStudentsCubit getStudentsCubit = getIt<GetStudentsCubit>();

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    profileCubit.loadProfile();
    getStudentsCubit.getMyStudents();
  }

  // تحديد إذا كانت الشاشة تابلت أو دسكتوب
  bool get isTablet => MediaQuery.of(context).size.width > 600;
  bool get isDesktop => MediaQuery.of(context).size.width > 1024;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => profileCubit..loadProfile()),
        BlocProvider(create: (_) => getStudentsCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(
          title: "Profile",
          showArrowBack: false,
          actions: [
            IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: Icon(Icons.logout, color: AppColors.white, size: 24.sp),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.w : isTablet ? 24.w : 16.w),
          child: Column(
            children: [
              // -------------------- Parent Profile Card --------------------
              BlocBuilder<ProfileCubit, ProfileStates>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return _buildLoadingCard();
                  } else if (state is ProfileLoaded) {
                    return _buildParentInfoCard(state.parent);
                  } else if (state is ProfileError) {
                    return _buildErrorCard(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: isDesktop ? 32.h : 24.h),

              // -------------------- Students Section --------------------
              BlocBuilder<GetStudentsCubit, GetStudentsStates>(
                builder: (context, state) {
                  if (state is GetStudentsLoadingState) {
                    return _buildStudentsLoadingCard();
                  } else if (state is GetMyStudents) {
                    return _buildChildrenSection(state.myStudents, context);
                  } else if (state is GetStudentsErrorState) {
                    return _buildStudentsErrorCard(state.error.errorMsg);
                  }
                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: isDesktop ? 32.h : 24.h),

              // -------------------- Action Buttons --------------------
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // =======================
  // 🟢 Parent Profile Card
  // =======================
  Widget _buildParentInfoCard(ParentLoginEntity parent) {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.w : isTablet ? 24.w : 16.w),
        child: Column(
          children: [
            Text(
              parent.name ?? 'unselected name',
              style: TextStyle(
                fontSize: isDesktop ? 28.sp : isTablet ? 26.sp : 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 24.h : 16.h),
            _buildContactInfo(
              icon: Icons.email,
              label: parent.email ?? 'unselected email',
            ),
            SizedBox(height: isDesktop ? 16.h : 12.h),
            _buildContactInfo(
              icon: Icons.phone,
              label: parent.phone ?? 'unselected phone',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: isDesktop ? 24.sp : 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontSize: isDesktop ? 18.sp : isTablet ? 17.sp : 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  // 🟢 Loading States
  // =======================
  Widget _buildLoadingCard() {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 4.w,
        ),
      ),
    );
  }

  Widget _buildStudentsLoadingCard() {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 4.w,
            ),
            SizedBox(height: 16.h),
            Text(
              "Loading students's data...",
              style: TextStyle(
                color: AppColors.gray,
                fontSize: isDesktop ? 18.sp : 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // 🟢 Error States
  // =======================
  Widget _buildErrorCard(String message) {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.red, size: 48.sp),
          SizedBox(height: 12.h),
          Text(
            'Error Occurred',
            style: TextStyle(
              fontSize: isDesktop ? 20.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              color: AppColors.gray,
              fontSize: isDesktop ? 16.sp : 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsErrorCard(String error) {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(Icons.error_outline, color: AppColors.red, size: 48.sp),
        SizedBox(height: 12.h),
        Text(
          "Failed to load students",
          style: TextStyle(
            fontSize: isDesktop ? 18.sp : 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.red,
          )),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              color: AppColors.gray,
              fontSize: isDesktop ? 14.sp : 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          ],
        ),
      ),
    );
  }

  // =======================
  // 🟢 Students Section
  // =======================
  Widget _buildChildrenSection(
      List<StudentsEntity> students,
      BuildContext context,
      ) {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.w : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppColors.primary,
                    size: isDesktop ? 28.sp : 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "My Students",
                  style: TextStyle(
                    fontSize: isDesktop ? 24.sp : isTablet ? 23.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "${students.length}",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: isDesktop ? 16.sp : 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            if (students.isEmpty)
              _buildEmptyStudentsState()
            else
              ...students
                  .map((student) => _buildChildCard(student, context))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStudentsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: isDesktop ? 72.sp : 64.sp,
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            "No students registered",
            style: TextStyle(
              fontSize: isDesktop ? 20.sp : 18.sp,
              color: AppColors.grey.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(StudentsEntity student, BuildContext dialogContext) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<GetStudentsCubit>().selectStudent(student.id!);
            _showChildDetails(student, dialogContext);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: isDesktop ? 60.w : 50.w,
                  height: isDesktop ? 60.h : 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      student.nickName?.isNotEmpty == true
                          ? student.nickName![0].toUpperCase()
                          : "S",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isDesktop ? 24.sp : 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.nickName ?? "unselected student",
                        style: TextStyle(
                          fontSize: isDesktop ? 20.sp : 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "students number: ${student.id}",
                        style: TextStyle(
                          fontSize: isDesktop ? 16.sp : 14.sp,
                          color: AppColors.gray.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: isDesktop ? 18.sp : 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================
  // 🟢 Action Buttons
  // =======================
  Widget _buildActionButtons(BuildContext dialogContext) {
    return Container(
      width: isDesktop ? 600.w : double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(dialogContext),
              icon: Icon(Icons.logout, color: AppColors.white, size: 24.sp),
              label: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: BorderSide(color: AppColors.primaryColor, width: 2.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  // 🟢 Dialog Methods
  // =======================
  void _showChildDetails(StudentsEntity student, BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              width: isDesktop ? 48.w : 40.w,
              height: isDesktop ? 48.h : 40.h,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.nickName?.isNotEmpty == true
                      ? student.nickName![0].toUpperCase()
                      : "S",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              student.nickName ?? "Student",
              style: TextStyle(
                fontSize: isDesktop ? 22.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        content: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Student's Number", "${student.id}"),
              SizedBox(height: 8.h),
              _buildDetailRow("Nick Name", student.nickName ?? "Unselected"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Close",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: isDesktop ? 16.sp : 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: isDesktop ? 16.sp : 14.sp,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: isDesktop ? 16.sp : 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.logout,
                color: AppColors.red,
                size: isDesktop ? 28.sp : 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              "Log Out",
              style: TextStyle(
                fontSize: isDesktop ? 22.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        content: Text(
          "Are You Sure To Log Out",
          style: TextStyle(
            fontSize: isDesktop ? 18.sp : 16.sp,
            color: AppColors.gray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.gray,
                fontSize: isDesktop ? 16.sp : 14.sp,
              ),
            ),
          ),
          CustomElevatedButton(
            text: 'Log Out',
            onPressed: () {
              SharedPreferenceUtils.removeData(key: 'token');
              Navigator.pushNamedAndRemoveUntil(
                dialogContext,
                AppRoutes.loginRoute,
                    (route) => false,
              );
            },
            backgroundColor: AppColors.primaryColor,
            textStyle: TextStyle(
              color: AppColors.white,
              fontSize: isDesktop ? 16.sp : 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

