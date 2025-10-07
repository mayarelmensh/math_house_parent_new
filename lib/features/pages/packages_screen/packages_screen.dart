import 'package:dartz/dartz.dart' as selectedPackage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import '../../../core/di/di.dart';
import '../../../data/models/student_selected.dart';
import '../../../data/models/my_course_model.dart';
import '../my_courses_screen/cuibt/my_courses_cuibt.dart';
import '../my_courses_screen/cuibt/my_courses_states.dart';
import 'cubit/packages_cubit.dart';
import 'cubit/packages_states.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  _PackagesScreenState createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  MyCourse? selectedCourse;
  String? selectedModuleFilter;
  final packagesCubit = getIt<PackagesCubit>();
  final myCoursesCubit = getIt<MyCoursesCubit>();
  bool _isLoadButtonPressed = false;

  @override
  void initState() {
    super.initState();
    if (SelectedStudent.studentId != null) {
      myCoursesCubit.fetchMyCourses(SelectedStudent.studentId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    packagesCubit.close();
    super.dispose();
  }

  void _loadPackages() {
    setState(() => _isLoadButtonPressed = true);
    Future.delayed(Duration(milliseconds: 200), () => setState(() => _isLoadButtonPressed = false));

    final studentId = SelectedStudent.studentId;
    print(studentId);

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a student first',
            style: TextStyle(fontSize: 13.sp, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (selectedCourse != null) {
      packagesCubit.getPackagesForCourse(
        courseId: selectedCourse!.id,
        userId: studentId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a course first',
            style: TextStyle(fontSize: 13.sp, color: Colors.white),
          ),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  List filterPackagesByModule(List packages) {
    if (selectedModuleFilter == null || selectedModuleFilter == 'All')
      return packages;
    return packages.where((p) => p.module == selectedModuleFilter).toList();
  }

  Widget _buildCompactSelectionRow() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1.r,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Course & Filter",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Course Selection
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade100, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: BlocBuilder<MyCoursesCubit, MyCoursesState>(
                    bloc: myCoursesCubit,
                    builder: (context, state) {
                      if (state is MyCoursesLoading || state is MyCoursesRefreshing) {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          child: Center(
                            child: SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 2.w,
                              ),
                            ),
                          ),
                        );
                      }
                      else if (state is MyCoursesLoaded) {
                        final courses = state.courses;
                        return DropdownButtonFormField<MyCourse>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            hintText: "Select Course",
                            prefixIcon: Icon(
                              Icons.school,
                              color: AppColors.primaryColor,
                              size: 18.sp,
                            ),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: selectedCourse,
                          items: courses.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c.courseName,
                                style: TextStyle(
                                  fontSize: 16.5.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedCourse = val);
                          },
                        );
                      }
                      else if (state is MyCoursesEmpty) {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          child: Text(
                            "No courses available",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        child: Text(
                          "Error loading courses",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // Module Filter
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade100, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      hintText: "Filter",
                      prefixIcon: Icon(
                        Icons.filter_list,
                        color: AppColors.primaryColor,
                        size: 18.sp,
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: selectedModuleFilter,
                    items:  [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text("All", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(
                        value: 'Live',
                        child: Text("Live", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(
                        value: 'Question',
                        child: Text("Question", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(
                        value: 'Exam',
                        child: Text("Exam", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => selectedModuleFilter = val);
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Load Button
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(_isLoadButtonPressed ? 0.2 : 0.35),
                  spreadRadius: 1.r,
                  blurRadius: 6.r,
                  offset: Offset(0, _isLoadButtonPressed ? 1.h : 3.h),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: _loadPackages,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Load Packages",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPackageCard(dynamic package) {
    bool _isBuyButtonPressed = false;

    return StatefulBuilder(
      builder: (context, setCardState) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1.r,
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with package name and module badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        package.name ?? "Unnamed Package",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getModuleGradientColors(package.module),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: _getModuleColor(package.module).withOpacity(0.25),
                            spreadRadius: 1.r,
                            blurRadius: 4.r,
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getModuleIcon(package.module),
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _getModuleText(package.module),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Price and Duration
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Price Section
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade100.withOpacity(0.2),
                                    spreadRadius: 1.r,
                                    blurRadius: 4.r,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.green.shade700,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Price",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${package.price ?? 0} \$",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 36.h,
                        width: 1.w,
                        color: Colors.grey.shade200,
                      ),

                      // Duration Section
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Duration",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${package.duration ?? 0} days",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade100.withOpacity(0.2),
                                    spreadRadius: 1.r,
                                    blurRadius: 4.r,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.blue.shade700,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Buy Button
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(_isBuyButtonPressed ? 0.2 : 0.35),
                        spreadRadius: 1.r,
                        blurRadius: 6.r,
                        offset: Offset(0, _isBuyButtonPressed ? 1.h : 3.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTapDown: (_) => setCardState(() => _isBuyButtonPressed = true),
                      onTapCancel: () => setCardState(() => _isBuyButtonPressed = false),
                      onTap: () {
                        setCardState(() => _isBuyButtonPressed = false);
                        if (SelectedStudent.studentId != null) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.paymentMethodsScreen,
                            arguments: {
                              'packageId': package.id,
                              'packageName': package.name,
                              'packagePrice': package.price,
                              'packageModule': package.module,
                              'packageDuration': package.duration,
                            },
                          );
                          debugPrint(
                            "🛒 Buy package: ${package.id}, for student: ${SelectedStudent.studentId} ",
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select a student first',
                                style: TextStyle(fontSize: 13.sp, color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(12.w),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Buy Package',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getModuleColor(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return Colors.red.shade600;
      case 'question':
        return Colors.blue.shade600;
      case 'exam':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  List<Color> _getModuleGradientColors(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return [Colors.red.shade500, Colors.red.shade700];
      case 'question':
        return [Colors.blue.shade500, Colors.blue.shade700];
      case 'exam':
        return [Colors.purple.shade500, Colors.purple.shade700];
      default:
        return [Colors.grey.shade500, Colors.grey.shade700];
    }
  }

  IconData _getModuleIcon(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return Icons.live_tv;
      case 'question':
        return Icons.quiz;
      case 'exam':
        return Icons.assignment;
      default:
        return Icons.help;
    }
  }

  String _getModuleText(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return 'Live';
      case 'question':
        return 'Question';
      case 'exam':
        return 'Exam';
      default:
        return module ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => myCoursesCubit),
        BlocProvider(create: (_) => packagesCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: CustomAppBar(title: "Packages"),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Column(
            children: [
              // Compact Selection Row
              _buildCompactSelectionRow(),

              // Packages List
              Expanded(
                child: BlocBuilder<PackagesCubit, PackagesStates>(
                  builder: (context, state) {
                    if (state is PackagesLoadingState) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryColor,
                              strokeWidth: 3.w,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Loading packages...",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is PackagesSpecificCourseSuccessState) {
                      var packages = filterPackagesByModule(state.packagesResponseList);
                      if (packages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1.r,
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.inbox_outlined,
                                  size: 60.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "No packages available",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Try changing the filter or selecting another course",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: packages.length,
                        itemBuilder: (_, i) {
                          final pkg = packages[i];
                          return _buildEnhancedPackageCard(pkg);
                        },
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1.r,
                                  blurRadius: 6.r,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.touch_app_outlined,
                              size: 60.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Select course first",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "Then press 'Load Packages' button",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}