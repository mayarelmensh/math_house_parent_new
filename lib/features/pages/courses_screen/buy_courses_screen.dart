import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_chapter_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/di/di.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/payment_methods_response_dm.dart';
import '../../../data/models/student_selected.dart';
import '../../../domain/entities/courses_response_entity.dart';
import '../../../domain/entities/payment_methods_response_entity.dart';
import '../../widgets/custom_elevated_button.dart';
import '../payment_methods/cubit/payment_methods_cubit.dart';
import '../payment_methods/cubit/payment_methods_states.dart';
import '../promo_code_screen/cubit/promo_code_cubit.dart';
import '../promo_code_screen/cubit/promo_code_states.dart';
import 'cubit/buy_chapter_states.dart';
import 'cubit/buy_course_cubit.dart';
import 'cubit/buy_course_states.dart';
import 'cubit/chapter_data_cubit.dart';
import 'cubit/courses_cubit.dart';
import 'cubit/courses_states.dart';
import 'dart:developer' as developer;

class BuyCourseScreen extends StatefulWidget {
  final bool isLiveSession;

  const BuyCourseScreen({super.key, this.isLiveSession = false});

  @override
  State<BuyCourseScreen> createState() => _BuyCourseScreenState();
}

class _BuyCourseScreenState extends State<BuyCourseScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? base64String;
  Uint8List? imageBytes;
  ChapterDataCubit chapterDataCubit = getIt<ChapterDataCubit>();
  BuyCourseCubit buyCourseCubit = getIt<BuyCourseCubit>();
  final List<int> _selectedChapterIds = [];

  bool get isTablet => MediaQuery.of(context).size.width > 600;
  bool get isDesktop => MediaQuery.of(context).size.width > 1024;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesCubit>().getCoursesList(SelectedStudent.studentId);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: widget.isLiveSession ? 'Live Sessions' : 'Courses',
      ),
      body: BlocBuilder<CoursesCubit, CoursesStates>(
        builder: (context, state) {
          if (state is CoursesLoadingState) {
            return _buildLoadingState();
          } else if (state is CoursesErrorState) {
            return _buildErrorState(state.error.errorMsg);
          } else if (state is CoursesSuccessState) {
            final allCourses = state.coursesResponseEntity.courses ?? [];
            if (allCourses.isEmpty) return _buildEmptyState();

            final filteredCourses = _filterCourses(allCourses);

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCoursesHeader(filteredCourses.length),
                  Expanded(child: _buildCoursesList(filteredCourses)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24.r : 16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search For Courses',
          hintStyle: TextStyle(color: AppColors.grey[500]),
          prefixIcon: Icon(Icons.search, color: AppColors.grey[500]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.grey[500]),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: isTablet ? 16.h : 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesHeader(int courseCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isLiveSession ? 'Live Sessions' : 'Available Courses',
            style: TextStyle(
              fontSize: isTablet ? 20.sp : 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey[800],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$courseCount Courses',
              style: TextStyle(
                fontSize: isTablet ? 14.sp : 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List<CourseEntity> courses) {
    return RefreshIndicator(
      onRefresh: () async => context.read<CoursesCubit>().getCoursesList(SelectedStudent.studentId),
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.2).clamp(0.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
                ),
              );
              return Transform.translate(
                offset: Offset(
                  0,
                  50.h * (1 - delayedAnimation.value.clamp(0.0, 1.0)),
                ),
                child: Opacity(
                  opacity: delayedAnimation.value.clamp(0.0, 1.0),
                  child: CourseCard(
                    course: courses[index],
                    onTap: () => _navigateToCourseDetails(courses[index]),
                    onBuy: () => _showPaymentMethodsBottomSheet(course: courses[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24.r : 20.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            widget.isLiveSession ? 'Loading Live Classes...' : 'Loading Courses',
            style: TextStyle(
              fontSize: isTablet ? 18.sp : 16.sp,
              color: AppColors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isTablet ? 40.r : 32.r),
        padding: EdgeInsets.all(isTablet ? 32.r : 24.r),
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
                size: isTablet ? 56.r : 48.r,
                color: AppColors.red,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'An error occurred',
              style: TextStyle(
                fontSize: isTablet ? 20.sp : 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: isTablet ? 16.sp : 14.sp,
                color: AppColors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.read<CoursesCubit>().getCoursesList(SelectedStudent.studentId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 16.sp : 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isTablet ? 40.r : 32.r),
        padding: EdgeInsets.all(isTablet ? 32.r : 24.r),
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: isTablet ? 56.sp : 48.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.isLiveSession ? 'No live sessions available' : 'No courses available',
              style: TextStyle(
                fontSize: isTablet ? 20.sp : 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for new courses',
              style: TextStyle(
                fontSize: isTablet ? 16.sp : 14.sp,
                color: AppColors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CourseEntity> _filterCourses(List<CourseEntity> courses) {
    return courses.where((course) {
      return (course.courseName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (course.courseDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _navigateToCourseDetails(CourseEntity course) {
    _selectedChapterIds.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _buildCourseDetailsBottomSheet(course),
    );
  }

  Widget _buildCourseDetailsBottomSheet(CourseEntity course) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                      children: [
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: AppColors.grey[300],
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                        if (course.courseImage != null && course.courseImage!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              course.courseImage!,
                              height: isTablet ? 250.h : 200.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: isTablet ? 250.h : 200.h,
                                color: AppColors.grey[200],
                                child: Icon(Icons.error, color: AppColors.red),
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),
                        Text(
                          course.courseName ?? "Course Name",
                          style: TextStyle(
                            fontSize: isTablet ? 24.sp : 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        if (course.courseDescription != null && course.courseDescription!.isNotEmpty)
                          Text(
                            course.courseDescription!,
                            style: TextStyle(
                              fontSize: isTablet ? 18.sp : 16.sp,
                              height: 1.5,
                              color: AppColors.gray,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 20.h),
                        if (course.chapters != null && course.chapters!.isNotEmpty) ...[
                          Text(
                            "Course Chapters",
                            style: TextStyle(
                              fontSize: isTablet ? 18.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...course.chapters!.map(
                                (chapter) => Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              color: AppColors.white,
                              child: ExpansionTile(
                                title: Text(
                                  chapter.chapterName ?? "Chapter",
                                  style: TextStyle(color: AppColors.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: chapter.chapterPrice != null
                                    ? Text(
                                  "Price: ${chapter.chapterPrice} \$",
                                  style: TextStyle(color: AppColors.green),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                                    : null,
                                leading: chapter.chapterPrice != null
                                    ? Checkbox(
                                  value: _selectedChapterIds.contains(chapter.id),
                                  onChanged: (value) {
                                    setModalState(() {
                                      if (value == true) {
                                        _selectedChapterIds.add(chapter.id!);
                                      } else {
                                        _selectedChapterIds.remove(chapter.id);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                )
                                    : null,
                                trailing: chapter.chapterPrice != null
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight,
                                  ),
                                  onPressed: () {
                                    _selectedChapterIds.clear();
                                    _selectedChapterIds.add(chapter.id!);
                                    _showPaymentMethodsBottomSheet(
                                      course: course,
                                      chapters: [chapter],
                                    );
                                  },
                                  child: Text(
                                    "Buy",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                                    : null,
                                children: [
                                  if (chapter.lessons != null && chapter.lessons!.isNotEmpty)
                                    ...chapter.lessons!.map(
                                          (lesson) => ListTile(
                                        leading: Icon(
                                          Icons.play_circle_outline,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          lesson.lessonName ?? "Lesson",
                                          style: TextStyle(
                                            color: AppColors.darkGrey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedChapterIds.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: CustomElevatedButton(
                                text: 'Buy Selected Chapters (${_selectedChapterIds.length})',
                                onPressed: () {
                                  final selectedChapters = course.chapters!
                                      .where((chapter) => _selectedChapterIds.contains(chapter.id))
                                      .toList();
                                  _showPaymentMethodsBottomSheet(
                                    course: course,
                                    chapters: selectedChapters,
                                  );
                                },
                                backgroundColor: AppColors.primaryColor,
                                textStyle: TextStyle(color: AppColors.white),
                              ),
                            ),
                        ],
                        SizedBox(height: 20.h),
                        if (course.price != null)
                          Container(
                            padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.green.withOpacity(0.1),
                                  AppColors.green.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.green),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Course Price",
                                  style: TextStyle(
                                    fontSize: isTablet ? 18.sp : 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gray,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "${course.price} \$",
                                  style: TextStyle(
                                    fontSize: isTablet ? 26.sp : 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                CustomElevatedButton(
                                  text: 'Buy Course',
                                  onPressed: () => _showPaymentMethodsBottomSheet(course: course),
                                  backgroundColor: AppColors.primaryColor,
                                  textStyle: TextStyle(color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPaymentMethodsBottomSheet({
    required CourseEntity course,
    List<ChaptersEntity>? chapters,
  }) {
    final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
    final buyCourseCubit = getIt<BuyCourseCubit>();
    final chapterDataCubit = getIt<BuyChapterCubit>();
    final promoCodeCubit = getIt<PromoCodeCubit>();

    String? selectedPaymentMethodId = 'Wallet';
    double? newPrice;
    final TextEditingController promoController = TextEditingController();
    bool isPromoExpanded = false;

    setState(() {
      imageBytes = null;
      base64String = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
      enableDrag: true,
      isDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          double originalPrice = chapters == null
              ? (course.price?.toDouble() ?? 0.0)
              : chapters.fold(
            0.0,
                (sum, chapter) => sum + (chapter.chapterPrice?.toDouble() ?? 0.0),
          );

          double finalPrice = newPrice ?? originalPrice;

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: paymentMethodsCubit),
                  BlocProvider.value(value: buyCourseCubit),
                  BlocProvider.value(value: chapterDataCubit),
                  BlocProvider.value(value: promoCodeCubit),
                ],
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<BuyCourseCubit, BuyCourseStates>(
                      listener: (context, state) {
                        if (state is BuyCoursePaymentPendingState) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentWebViewScreen(
                                paymentLink: state.paymentLink,
                                buyCourseCubit: buyCourseCubit,
                              ),
                            ),
                          );
                        } else if (state is BuyCourseSuccessState) {
                          showTopSnackBar(
                            context,
                            'Course purchase is pending!',
                            AppColors.green,
                          );
                          Navigator.pop(context);
                        } else if (state is BuyCourseErrorState) {
                          showTopSnackBar(
                            context,
                            state.message ?? 'Something went wrong, please try again',
                            AppColors.red,
                          );
                        }
                      },
                    ),
                    BlocListener<BuyChapterCubit, BuyChapterStates>(
                      listener: (context, state) {
                        if (state is BuyChapterSuccessState) {
                          if (state.paymentLink != null && state.paymentLink!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterPaymentWebViewScreen(
                                  paymentLink: state.paymentLink!,
                                  onPaymentResult: (isSuccess, errorMessage) {
                                    if (isSuccess) {
                                      showTopSnackBar(
                                        context,
                                        'Chapter${chapters!.length > 1 ? 's' : ''} purchased successfully!',
                                        AppColors.green,
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      showTopSnackBar(
                                        context,
                                        errorMessage ?? 'Payment failed',
                                        AppColors.red,
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          } else {
                            showTopSnackBar(
                              context,
                              'Chapter${chapters!.length > 1 ? 's' : ''} purchase is pending!',
                              AppColors.green,
                            );
                            Navigator.pop(context);
                          }
                        } else if (state is BuyChapterErrorState) {
                          showTopSnackBar(
                            context,
                            state.error ?? 'Something went wrong, please try again',
                            AppColors.red,
                          );
                        }
                      },
                    ),
                    BlocListener<PromoCodeCubit, PromoCodeStates>(
                      listener: (context, state) {
                        if (state is PromoCodeSuccessState) {
                          setModalState(() {
                            newPrice = state.response.newPrice?.toDouble();
                          });
                          showTopSnackBar(
                            context,
                            'Promo code applied successfully!',
                            AppColors.green,
                          );
                        } else if (state is PromoCodeErrorState) {
                          showTopSnackBar(
                            context,
                            'Invalid promo code, please try again',
                            AppColors.red,
                          );
                        }
                      },
                    ),
                  ],
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(top: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.grey[300],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                          child: Text(
                            'Select Payment Method',
                            style: TextStyle(
                              fontSize: isTablet ? 20.sp : 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.w : 16.w),
                            children: [
                              Text(
                                chapters == null
                                    ? 'Course: ${course.courseName ?? 'Unknown'}'
                                    : 'Chapter${chapters.length > 1 ? 's' : ''}: ${chapters.length > 1 ? '${chapters.length} Chapters' : chapters.first.chapterName ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: isTablet ? 18.sp : 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12.h),
                              if (chapters == null) ...[
                                BlocBuilder<PromoCodeCubit, PromoCodeStates>(
                                  builder: (context, promoState) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.grey[50],
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(color: AppColors.grey[200]!),
                                      ),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setModalState(() {
                                                isPromoExpanded = !isPromoExpanded;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.local_offer,
                                                    color: AppColors.primary,
                                                    size: isTablet ? 24.sp : 20.sp,
                                                  ),
                                                  SizedBox(width: 12.w),
                                                  Text(
                                                    'Promo Code',
                                                    style: TextStyle(
                                                      fontSize: isTablet ? 18.sp : 16.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  if (newPrice != null)
                                                    Text(
                                                      'Applied',
                                                      style: TextStyle(
                                                        fontSize: isTablet ? 14.sp : 12.sp,
                                                        color: AppColors.green,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  SizedBox(width: 8.w),
                                                  Icon(
                                                    isPromoExpanded
                                                        ? Icons.keyboard_arrow_up
                                                        : Icons.keyboard_arrow_down,
                                                    color: AppColors.grey[600],
                                                    size: isTablet ? 24.sp : 20.sp,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isPromoExpanded)
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                isTablet ? 20.w : 16.w,
                                                0,
                                                isTablet ? 20.w : 16.w,
                                                isTablet ? 20.h : 16.h,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller: promoController,
                                                          keyboardType: TextInputType.number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.digitsOnly,
                                                          ],
                                                          decoration: InputDecoration(
                                                            hintText: 'Enter promo code',
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8.r),
                                                              borderSide: BorderSide(color: AppColors.grey[300]!),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8.r),
                                                              borderSide: BorderSide(color: AppColors.primary),
                                                            ),
                                                            contentPadding: EdgeInsets.symmetric(
                                                              horizontal: isTablet ? 16.w : 12.w,
                                                              vertical: isTablet ? 16.h : 12.h,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      ElevatedButton(
                                                        onPressed: promoState is PromoCodeLoadingState
                                                            ? null
                                                            : () {
                                                          if (promoController.text.isEmpty) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Please enter a promo code'),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                          final promoCode = int.tryParse(promoController.text);
                                                          if (promoCode == null) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Please enter a valid promo code'),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                          promoCodeCubit.applyPromoCode(
                                                            promoCode: promoCode,
                                                            courseId: course.id ?? 0,
                                                            userId: SelectedStudent.studentId,
                                                            originalAmount: originalPrice,
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: AppColors.primary,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8.r),
                                                          ),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: isTablet ? 20.w : 16.w,
                                                            vertical: isTablet ? 16.h : 12.h,
                                                          ),
                                                        ),
                                                        child: promoState is PromoCodeLoadingState
                                                            ? SizedBox(
                                                          width: isTablet ? 24.w : 20.w,
                                                          height: isTablet ? 24.h : 20.h,
                                                          child: CircularProgressIndicator(
                                                            color: AppColors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                            : Text(
                                                          'Apply',
                                                          style: TextStyle(
                                                            color: AppColors.white,
                                                            fontSize: isTablet ? 16.sp : 14.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (newPrice != null) ...[
                                                    SizedBox(height: 12.h),
                                                    Container(
                                                      padding: EdgeInsets.all(isTablet ? 16.w : 12.w),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.green.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8.r),
                                                        border: Border.all(color: AppColors.green.withOpacity(0.3)),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.check_circle,
                                                            color: AppColors.green,
                                                            size: isTablet ? 20.sp : 16.sp,
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          Expanded(
                                                            child: Text(
                                                              'Promo code applied! You save ${(originalPrice - newPrice!).toStringAsFixed(0)}'
                                                              ,
                                                              style: TextStyle(
                                                                fontSize: isTablet ? 14.sp : 12.sp,
                                                                color: AppColors.green,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              setModalState(() {
                                                                newPrice = null;
                                                                promoController.clear();
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
                                                              size: isTablet ? 20.sp : 16.sp,
                                                              color: AppColors.red,
                                                            ),
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(
                                                              minWidth: isTablet ? 28.w : 24.w,
                                                              minHeight: isTablet ? 28.h : 24.h,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 12.h),
                              ],
                              Container(
                                padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Column(
                                  children: [
                                    if (newPrice != null && newPrice != originalPrice) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Original Price:',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16.sp : 14.sp,
                                              color: AppColors.grey[600],
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          Text(
                                            '${originalPrice.toStringAsFixed(2)} ',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16.sp : 14.sp,
                                              color: AppColors.grey[600],
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                    ],
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Final Price:',
                                          style: TextStyle(
                                            fontSize: isTablet ? 18.sp : 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.grey[800],
                                          ),
                                        ),
                                        Text(
                                          '${finalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: isTablet ? 20.sp : 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: newPrice != null ? AppColors.green : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Duration: ${chapters == null ? (course.allPrices?.isNotEmpty == true ? course.allPrices!.first.duration ?? 30 : 30) : (chapters.first.chapterAllPrices?.isNotEmpty == true ? chapters.first.chapterAllPrices!.first.duration ?? 30 : 30)} days',
                                style: TextStyle(
                                  fontSize: isTablet ? 16.sp : 14.sp,
                                  color: AppColors.grey[700],
                                ),
                              ),
                              if (selectedPaymentMethodId != 'Wallet' && selectedPaymentMethodId != '10') ...[
                                SizedBox(height: 16.h),
                                if (imageBytes != null)
                                  Container(
                                    width: double.infinity,
                                    height: isTablet ? 200.h : 150.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: Colors.grey[200],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.memory(
                                        imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: isTablet ? 200.h : 150.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: Colors.grey[200],
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      size: isTablet ? 48.sp : 40.sp,
                                    ),
                                  ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showImageSourceBottomSheet(context, setModalState),
                                        icon: Icon(Icons.upload_file, color: AppColors.white),
                                        label: Text(
                                          'Upload Invoice Image',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: isTablet ? 16.sp : 14.sp,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isTablet ? 28.w : 24.w,
                                            vertical: isTablet ? 16.h : 12.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (imageBytes != null) ...[
                                      SizedBox(width: 8.w),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            imageBytes = null;
                                            base64String = null;
                                          });
                                          setModalState(() {});
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: isTablet ? 28.sp : 24.sp,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 16.h),
                              ],
                              BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
                                bloc: paymentMethodsCubit,
                                builder: (context, state) {
                                  if (state is PaymentMethodsLoadingState) {
                                    return Center(
                                      child: CircularProgressIndicator(color: AppColors.primary),
                                    );
                                  } else if (state is PaymentMethodsSuccessState) {
                                    final methods = [
                                      PaymentMethodDm(
                                        id: 'Wallet',
                                        payment: 'Wallet',
                                        paymentType: 'Wallet',
                                        description: 'Pay using your wallet balance',
                                        logo: '',
                                      ),
                                      ...state.paymentMethodsResponse.paymentMethods!.map((method) {
                                        // If the method ID is '10', override the payment name
                                        if (method.id.toString() == '10') {
                                          return PaymentMethodDm(
                                            id: method.id,
                                            payment: 'Visacard/Mastercard', // Ensure the name is always Visacard/Mastercard
                                            paymentType: method.paymentType,
                                            description: method.description,
                                            logo: method.logo,
                                          );
                                        }
                                        return method;
                                      }).toList(),
                                    ];
                                    return Column(
                                      children: methods.map((method) {
                                        final isSelected = selectedPaymentMethodId == method.id.toString();
                                        return GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedPaymentMethodId = method.id.toString();
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 16.h),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isSelected
                                                    ? [
                                                  AppColors.primary.withOpacity(0.3),
                                                  AppColors.primary.withOpacity(0.1),
                                                ]
                                                    : [
                                                  AppColors.white,
                                                  AppColors.lightGray,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16.r),
                                              border: Border.all(
                                                color: isSelected ? AppColors.primary : AppColors.grey[300]!,
                                                width: isSelected ? 3.w : 1.w,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.grey.withOpacity(isSelected ? 0.3 : 0.15),
                                                  spreadRadius: 1,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3.h),
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: isTablet ? 70.w : 60.w,
                                                        height: isTablet ? 70.h : 60.h,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(12.r),
                                                          color: AppColors.lightGray,
                                                        ),
                                                        child: method.logo != null && method.logo!.isNotEmpty
                                                            ? ClipRRect(
                                                          borderRadius: BorderRadius.circular(12.r),
                                                          child: Image.network(
                                                            method.logo!,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, _, __) => Icon(
                                                              Icons.payment,
                                                              color: AppColors.primary,
                                                              size: isTablet ? 32.sp : 28.sp,
                                                            ),
                                                          ),
                                                        )
                                                            : Icon(
                                                          method.paymentType?.toLowerCase() == 'wallet'
                                                              ? Icons.account_balance_wallet
                                                              : Icons.payment,
                                                          color: AppColors.primary,
                                                          size: isTablet ? 32.sp : 28.sp,
                                                        ),
                                                      ),
                                                      SizedBox(width: 16.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              method.payment ?? "Unknown Payment",
                                                              style: TextStyle(
                                                                fontSize: isTablet ? 20.sp : 18.sp,
                                                                fontWeight: FontWeight.bold,
                                                                color: isSelected ? AppColors.primary : AppColors.darkGray,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            SizedBox(height: 4.h),
                                                            Container(
                                                              padding: EdgeInsets.symmetric(
                                                                horizontal: 12.w,
                                                                vertical: 4.h,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: _getPaymentTypeColor(method.paymentType),
                                                                borderRadius: BorderRadius.circular(12.r),
                                                              ),
                                                              child: Text(
                                                                _getPaymentTypeText(method.paymentType),
                                                                style: TextStyle(
                                                                  color: AppColors.white,
                                                                  fontSize: isTablet ? 14.sp : 12.sp,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (isSelected)
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: AppColors.primary,
                                                          size: isTablet ? 28.sp : 24.sp,
                                                        ),
                                                    ],
                                                  ),
                                                  if (method.description != null &&
                                                      method.description!.isNotEmpty &&
                                                      method.id.toString() != '10') ...[
                                                    SizedBox(height: 12.h),
                                                    InkWell(
                                                      onTap: () => _handlePaymentDescription(method.description!),
                                                      child: Container(
                                                        padding: EdgeInsets.all(isTablet ? 16.w : 12.w),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8.r),
                                                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              _isUrl(method.description!) ? Icons.link : Icons.content_copy,
                                                              color: AppColors.primary,
                                                              size: isTablet ? 20.sp : 16.sp,
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            Expanded(
                                                              child: Text(
                                                                method.description!,
                                                                style: TextStyle(
                                                                  fontSize: isTablet ? 16.sp : 14.sp,
                                                                  color: AppColors.primary,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.touch_app,
                                                              color: AppColors.primary,
                                                              size: isTablet ? 20.sp : 16.sp,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ] else if (method.id.toString() == '10') ...[
                                                    SizedBox(height: 12.h),
                                                    Container(
                                                      padding: EdgeInsets.all(isTablet ? 16.w : 12.w),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8.r),
                                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.info_outline,
                                                            color: AppColors.primary,
                                                            size: isTablet ? 20.sp : 16.sp,
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          Expanded(
                                                            child: Text(
                                                              'Press "Confirm Purchase" to proceed with the payment link',
                                                              style: TextStyle(
                                                                fontSize: isTablet ? 16.sp : 14.sp,
                                                                color: AppColors.primary,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  } else if (state is PaymentMethodsErrorState) {
                                    return Center(
                                      child: Text(
                                        'Something went wrong, please try again',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18.sp : 16.sp,
                                          color: AppColors.grey[600],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: (selectedPaymentMethodId != null &&
                                (selectedPaymentMethodId == 'Wallet' ||
                                    selectedPaymentMethodId == '10' ||
                                    base64String != null))
                                ? () async {
                              String imageData;
                              if (selectedPaymentMethodId == 'Wallet' || selectedPaymentMethodId == '10') {
                                imageData = 'wallet';
                              } else {
                                if (base64String == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please upload the invoice image'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                imageData = 'data:image/jpeg;base64,$base64String';
                              }

                              try {
                                if (chapters == null) {
                                  await buyCourseCubit.buyPackage(
                                    courseId: "${course.id ?? 0}",
                                    paymentMethodId: selectedPaymentMethodId!,
                                    amount: finalPrice.toStringAsFixed(2),
                                    userId: "${SelectedStudent.studentId}",
                                    duration: "${course.allPrices?.isNotEmpty == true ? course.allPrices!.first.duration ?? 30 : 30}",
                                    image: imageData,
                                    promoCode: promoController.text.isNotEmpty ? promoController.text : null,
                                  );
                                } else {
                                  await chapterDataCubit.buyChapters(
                                    courseId: "${course.id ?? 0}",
                                    paymentMethodId: selectedPaymentMethodId!,
                                    amount: finalPrice.toStringAsFixed(2),
                                    userId: "${SelectedStudent.studentId}",
                                    chapters: chapters
                                        .map((chapter) => {
                                      'chapter_id': "${chapter.id ?? 0}",
                                      'duration': "${chapter.chapterAllPrices?.isNotEmpty == true ? chapter.chapterAllPrices!.first.duration ?? 30 : 30}",
                                    })
                                        .toList(),
                                    image: imageData,
                                    promoCode: promoController.text.isNotEmpty ? promoController.text : null,
                                  );
                                }
                              } catch (e) {
                                developer.log('Error in purchase: $e');
                                showTopSnackBar(
                                  context,
                                  'Something went wrong, please try again: $e',
                                  AppColors.red,
                                );
                              }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: isTablet ? 20.h : 16.h),
                              minimumSize: Size(double.infinity, isTablet ? 56.h : 50.h),
                            ),
                            child: Text(
                              'Confirm Purchase',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: isTablet ? 18.sp : 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
  }

  bool _isUrl(String text) {
    return Uri.tryParse(text)?.hasScheme ?? false && (text.startsWith('http://') || text.startsWith('https://'));
  }

  void _handlePaymentDescription(String description) async {
    if (_isUrl(description)) {
      try {
        final uri = Uri.parse(description);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
          );
        }
      } catch (e) {
        showTopSnackBar(context, 'Failed to open link', AppColors.red);
      }
    } else {
      try {
        await Clipboard.setData(ClipboardData(text: description));
        showTopSnackBar(context, 'Copied to clipboard', AppColors.green);
      } catch (e) {
        showTopSnackBar(context, 'Failed to copy', AppColors.red);
      }
    }
  }

  void _showImageSourceBottomSheet(BuildContext parentContext, StateSetter setModalState) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: isTablet ? 20.sp : 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImage(ImageSource.camera, context, setModalState),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: isTablet ? 48.sp : 40.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: isTablet ? 16.sp : 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImage(ImageSource.gallery, context, setModalState),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: isTablet ? 48.sp : 40.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: isTablet ? 16.sp : 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext bottomSheetContext, StateSetter setModalState) async {
    try {
      Navigator.pop(bottomSheetContext);
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final List<int> imageFileBytes = await imageFile.readAsBytes();
        final String imageBase64 = base64Encode(imageFileBytes);
        setState(() {
          imageBytes = Uint8List.fromList(imageFileBytes);
          base64String = imageBase64;
        });
        setModalState(() {});
        showTopSnackBar(context, 'Payment proof uploaded successfully', AppColors.green);
      }
    } catch (e) {
      showTopSnackBar(context, 'Something went wrong, please try again', AppColors.red);
    }
  }

  Color _getPaymentTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return AppColors.green;
      case 'link':
        return AppColors.blue;
      case 'integration':
        return AppColors.purple;
      case 'text':
        return AppColors.orange;
      case 'wallet':
        return AppColors.yellow;
      default:
        return AppColors.grey[500]!;
    }
  }

  String _getPaymentTypeText(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return 'Phone';
      case 'link':
        return 'Link';
      case 'integration':
        return 'Online';
      case 'text':
        return 'Manual';
      case 'wallet':
        return 'Wallet';
      default:
        return 'Other';
    }
  }
}

class ChapterPaymentWebViewScreen extends StatefulWidget {
  final String paymentLink;
  final Function(bool, String?) onPaymentResult;

  const ChapterPaymentWebViewScreen({
    super.key,
    required this.paymentLink,
    required this.onPaymentResult,
  });

  @override
  State<ChapterPaymentWebViewScreen> createState() => _ChapterPaymentWebViewScreenState();
}

class _ChapterPaymentWebViewScreenState extends State<ChapterPaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  bool get isTablet => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            developer.log('Chapter WebView Page Started: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            developer.log('Chapter WebView URL: $url');
            setState(() {
              _isLoading = false;
            });
            _handlePaymentResult(url);
          },
          onNavigationRequest: (request) {
            developer.log('Chapter Navigation Request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));
  }

  void _handlePaymentResult(String url) {
    developer.log('Chapter WebView URL: $url');
    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pop();
        widget.onPaymentResult(true, null);
      });
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      String errorMessage = 'Payment failed';
      if (url.contains('txn_response_code=DECLINED')) {
        errorMessage = 'Payment was declined by the payment gateway';
      } else if (url.contains('error_occured=true')) {
        errorMessage = 'An error occurred during payment processing';
      }
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pop();
        widget.onPaymentResult(false, errorMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Chapter Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        foregroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
            widget.onPaymentResult(false, 'Payment cancelled by user');
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentLink;
  final BuyCourseCubit buyCourseCubit;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentLink,
    required this.buyCourseCubit,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  bool get isTablet => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            developer.log('WebView Page Started: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            developer.log('WebView URL: $url');
            setState(() {
              _isLoading = false;
            });
            _handlePaymentResult(url);
          },
          onWebResourceError: (WebResourceError error) {
            developer.log('WebView Error: ${error.description}');
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (request) {
            developer.log('Navigation Request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));
  }

  void _handlePaymentResult(String url) {
    developer.log('WebView URL: $url');
    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pop();
        widget.buyCourseCubit.handlePaymentResult(url);
      });
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pop();
        widget.buyCourseCubit.handlePaymentResult(url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Complete Payment'),
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final VoidCallback onBuy;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onBuy,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool get isTablet =>
      MediaQuery
          .of(context)
          .size
          .width > 600;

  bool get isDesktop =>
      MediaQuery
          .of(context)
          .size
          .width > 1024;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(bottom: isTablet ? 20.h : 16.h),
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: BorderRadius.circular(16.r),
              color: AppColors.white,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseImage(),
                      SizedBox(width: isTablet ? 20.w : 16.w),
                      Expanded(child: _buildCourseDetails()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseImage() {
    return Hero(
      tag: 'course_image_${widget.course.id ?? 0}',
      child: Container(
        width: isTablet ? 100.w : 85.w,
        height: isTablet ? 100.w : 85.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: widget.course.courseImage?.isNotEmpty == true
              ? Image.network(
            widget.course.courseImage!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholderImage(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2.w,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          )
              : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school,
          size: isTablet ? 48.sp : 40.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.course.courseName ?? 'Course Name',
                style: TextStyle(
                  fontSize: isTablet ? 20.sp : 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                  height: 1.2.h,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildArrowIcon(),
          ],
        ),
        SizedBox(height: 8.h),
        if (widget.course.courseDescription != null)
          Text(
            widget.course.courseDescription!,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: AppColors.grey[600],
              height: 1.4.h,
            ),
            maxLines: isTablet ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: 12.h),
        _buildCourseStats(),
        SizedBox(height: 8.h),
        if (widget.course.price != null) _buildPriceSection(),
      ],
    );
  }

  Widget _buildCourseStats() {
    return Wrap(
      spacing: isTablet ? 12.w : 8.w,
      runSpacing: 8.h,
      children: [
        _buildStatItem(
          icon: Icons.bookmark_outline,
          text: '${widget.course.chaptersCount ?? 0} Chapters',
          color: AppColors.primary,
        ),
        _buildStatItem(
          icon: Icons.play_circle_outline,
          text: '${widget.course.lessonsCount ?? 0} Lessons',
          color: AppColors.grey[600]!,
        ),
        _buildStatItem(
          icon: Icons.video_library,
          text: '${widget.course.videosCount ?? 0} Videos',
          color: AppColors.blue,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isTablet ? 16.sp : 14.sp, color: color),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 14.sp : 13.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.w : 12.w,
        vertical: isTablet ? 8.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            size: isTablet ? 18.sp : 16.sp,
            color: AppColors.green,
          ),
          SizedBox(width: 4.w),
          Text(
            '${widget.course.price} '
            ,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 10.w : 8.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: isTablet ? 18.sp : 16.sp,
        color: AppColors.primary,
      ),
    );
  }
}