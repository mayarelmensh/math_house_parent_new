import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/custom_snack_bar.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/domain/entities/courses_response_entity.dart';
import 'package:math_house_parent_new/domain/entities/payment_methods_response_entity.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_chapter_cubit.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_course_cubit.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_course_states.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_chapter_states.dart';
import 'package:math_house_parent_new/features/pages/promo_code_screen/cubit/promo_code_cubit.dart';
import 'package:math_house_parent_new/features/pages/promo_code_screen/cubit/promo_code_states.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/features/widgets/custom_elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

import '../../../data/models/payment_methods_response_dm.dart';
import '../payment_methods/cubit/payment_methods_cubit.dart';
import '../payment_methods/cubit/payment_methods_states.dart';
import 'buy_courses_screen.dart';

class CoursesPaymentMethodsScreen extends StatefulWidget {
  final CourseEntity course;
  final ChaptersEntity? chapter;

  const CoursesPaymentMethodsScreen({
    Key? key,
    required this.course,
    this.chapter,
  }) : super(key: key);

  @override
  _CoursesPaymentMethodsScreenState createState() => _CoursesPaymentMethodsScreenState();
}

class _CoursesPaymentMethodsScreenState extends State<CoursesPaymentMethodsScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final buyCourseCubit = getIt<BuyCourseCubit>();
  final buyChapterCubit = getIt<BuyChapterCubit>();
  final promoCodeCubit = getIt<PromoCodeCubit>();
  final ImagePicker _picker = ImagePicker();

  String? base64String;
  Uint8List? imageBytes;
  PaymentMethodDm? selectedMethod;
  String? selectedPaymentMethodId = 'Wallet';
  double? newPrice;
  final TextEditingController promoController = TextEditingController();
  bool isPromoExpanded = false;

  final PaymentMethodDm _walletPaymentMethod = PaymentMethodDm(
    id: 'Wallet',
    payment: 'Wallet',
    paymentType: 'Wallet',
    description: 'Pay using your wallet balance',
    logo: '',
  );

  final PaymentMethodDm _paymobPaymentMethod = PaymentMethodDm(
    id: '10',
    payment: 'Visacard/ Mastercard',
    paymentType: 'integration',
    description: 'Pay using Paymob',
    logo: 'https://cdn.paymob.com/images/logos/paymob-logo.png',
  );

  bool get isTablet => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
    });
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    buyCourseCubit.close();
    buyChapterCubit.close();
    promoCodeCubit.close();
    promoController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
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

        showTopSnackBar(
          context,
          'Payment proof uploaded successfully',
          AppColors.green,
        );
      }
    } catch (e) {
      showTopSnackBar(
        context,
        'Error selecting image: ${e.toString()}',
        AppColors.red,
      );
    }
  }

  void showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
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
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
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
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
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

  Widget _buildCompactInfoCard() {
    double originalPrice = widget.chapter == null
        ? (widget.course.price?.toDouble() ?? 0.0)
        : (widget.chapter!.chapterPrice?.toDouble() ?? 0.0);
    double finalPrice = newPrice ?? originalPrice;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2.h),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.book,
              color: AppColors.primaryColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapter == null
                      ? widget.course.courseName ?? "N/A"
                      : widget.chapter!.chapterName ?? "N/A",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      widget.chapter == null ? 'Course' : 'Chapter',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${widget.chapter == null ? (widget.course.allPrices?.isNotEmpty == true ? widget.course.allPrices!.first.duration ?? 30 : 30) : (widget.chapter!.chapterAllPrices?.isNotEmpty == true ? widget.chapter!.chapterAllPrices!.first.duration ?? 30 : 30)} Days",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${finalPrice.toStringAsFixed(2)} EGP",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    double originalPrice = widget.chapter == null
        ? (widget.course.price?.toDouble() ?? 0.0)
        : (widget.chapter!.chapterPrice?.toDouble() ?? 0.0);

    return BlocBuilder<PromoCodeCubit, PromoCodeStates>(
      bloc: promoCodeCubit,
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
                  setState(() {
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
                                courseId: widget.course.id ?? 0,
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
                                  'Promo code applied! You save ${(originalPrice - newPrice!).toStringAsFixed(0)} EGP',
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
                                  setState(() {
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
    );
  }

  Widget _buildPriceSection() {
    double originalPrice = widget.chapter == null
        ? (widget.course.price?.toDouble() ?? 0.0)
        : (widget.chapter!.chapterPrice?.toDouble() ?? 0.0);
    double finalPrice = newPrice ?? originalPrice;

    return Container(
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
                  '${originalPrice.toStringAsFixed(2)} EGP',
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
                '${finalPrice.toStringAsFixed(2)} EGP',
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
    );
  }

  Widget _buildPaymentProofSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Proof',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey[800],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Upload a screenshot or photo of your payment confirmation',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8.h),
          if (imageBytes != null)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 100.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.primary),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade100,
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 22.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No image selected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: showImageSourceBottomSheet,
                  icon: Icon(
                    Icons.upload_file,
                    color: AppColors.white,
                    size: 16.sp,
                  ),
                  label: Text(
                    'Upload Image',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              if (imageBytes != null) ...[
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        imageBytes = null;
                        base64String = null;
                      });
                    },
                    icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedPaymentMethodId == method.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethodId = method.id;
          if (method.id == 'Wallet' || method.id == '10') {
            imageBytes = null;
            base64String = null;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
              AppColors.primary.withOpacity(0.15),
              AppColors.primary.withOpacity(0.05),
            ]
                : [AppColors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: isSelected ? 6 : 3,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: method.logo != null && method.logo!.isNotEmpty
                          ? Image.network(
                        method.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Icon(
                          Icons.payment,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      )
                          : Icon(
                        method.paymentType?.toLowerCase() == 'wallet'
                            ? Icons.account_balance_wallet
                            : Icons.payment,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.payment ?? "Unknown Payment",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getPaymentTypeColor(method.paymentType),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _getPaymentTypeText(method.paymentType),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    )
                  else
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected && method.description != null && method.description!.isNotEmpty && method.id != '10')
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        method.description!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (method.paymentType?.toLowerCase() == 'phone') ...[
                        SizedBox(height: 6.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: method.description!),
                              );
                              showTopSnackBar(
                                context,
                                'Payment number copied to clipboard',
                                AppColors.green,
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              size: 12.sp,
                              color: AppColors.white,
                            ),
                            label: Text(
                              'Copy Payment Number',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              minimumSize: Size(0, 28.h),
                            ),
                          ),
                        ),
                      ],
                      if (method.paymentType?.toLowerCase() == 'link' || method.paymentType?.toLowerCase() == 'integration') ...[
                        SizedBox(height: 6.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final url = method.description!;
                              final uri = Uri.tryParse(url);
                              if (uri != null) {
                                final canLaunch = await canLaunchUrl(uri);
                                if (canLaunch) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.inAppWebView,
                                    webViewConfiguration: const WebViewConfiguration(
                                      enableJavaScript: true,
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  showTopSnackBar(
                                    context,
                                    'Invalid URL',
                                    AppColors.red,
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              Icons.link,
                              size: 12.sp,
                              color: AppColors.white,
                            ),
                            label: Text(
                              'Open Payment Link',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              minimumSize: Size(0, 28.h),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (isSelected && method.id == '10')
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Press "Confirm Purchase" to proceed with the payment link',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void confirmPurchase() async {
    if (selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
      if (widget.chapter == null) {
        await buyCourseCubit.buyPackage(
          courseId: "${widget.course.id ?? 0}",
          paymentMethodId: selectedPaymentMethodId!,
          amount: (newPrice ?? widget.course.price?.toDouble() ?? 0.0).toStringAsFixed(2),
          userId: "${SelectedStudent.studentId}",
          duration: "${widget.course.allPrices?.isNotEmpty == true ? widget.course.allPrices!.first.duration ?? 30 : 30}",
          image: imageData,
          promoCode: promoController.text.isNotEmpty ? promoController.text : null,
        );
      } else {
        await buyChapterCubit.buyChapter(
          courseId: "${widget.course.id ?? 0}",
          paymentMethodId: selectedPaymentMethodId!,
          amount: (newPrice ?? widget.chapter!.chapterPrice?.toDouble() ?? 0.0).toStringAsFixed(2),
          userId: "${SelectedStudent.studentId}",
          chapterId: "${widget.chapter!.id ?? 0}",
          duration: "${widget.chapter!.chapterAllPrices?.isNotEmpty == true ? widget.chapter!.chapterAllPrices!.first.duration ?? 30 : 30}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: 'Payment Methods',
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PromoCodeCubit, PromoCodeStates>(
            bloc: promoCodeCubit,
            listener: (context, state) {
              if (state is PromoCodeSuccessState) {
                setState(() {
                  newPrice = state.response.newPrice;
                });
                showTopSnackBar(
                  context,
                  'Promo code applied successfully',
                  AppColors.green,
                );
              } else if (state is PromoCodeErrorState) {
                showTopSnackBar(
                  context,
                  state.error,
                  AppColors.red,
                );
              }
            },
          ),
          BlocListener<BuyCourseCubit, BuyCourseStates>(
            bloc: buyCourseCubit,
            listener: (context, state) {
              if (state is BuyCourseSuccessState) {
                if (state.paymentLink != null && state.paymentLink!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentWebViewScreen(
                        paymentLink: state.paymentLink!,
                        buyCourseCubit: buyCourseCubit,
                      ),
                    ),
                  );
                } else {
                  showTopSnackBar(
                    context,
                    'Course purchased successfully',
                    AppColors.green,
                  );
                  Navigator.pop(context);
                }
              } else if (state is BuyCourseErrorState) {
                showTopSnackBar(
                  context,
                  state.message!,
                  AppColors.red,
                );
              }
            },
          ),
          BlocListener<BuyChapterCubit, BuyChapterStates>(
            bloc: buyChapterCubit,
            listener: (context, state) {
              if (state is BuyChapterSuccessState) {
                if (state.paymentLink != null && state.paymentLink!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterPaymentWebViewScreen(
                        paymentLink: state.paymentLink!,
                        onPaymentResult: (success, message) {
                          if (success) {
                            showTopSnackBar(
                              context,
                              'Chapter purchased successfully',
                              AppColors.green,
                            );
                            Navigator.pop(context);
                          } else {
                            showTopSnackBar(
                              context,
                              message ?? 'Chapter purchase failed',
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
                    'Chapter purchased successfully',
                    AppColors.green,
                  );
                  Navigator.pop(context);
                }
              } else if (state is BuyChapterErrorState) {
                showTopSnackBar(
                  context,
                  state.error,
                  AppColors.red,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
          bloc: paymentMethodsCubit,
          builder: (context, state) {
            if (state is PaymentMethodsLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            } else if (state is PaymentMethodsErrorState) {
              return Center(
                child: Text(
                  state.error,
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : 16.sp,
                    color: AppColors.red,
                  ),
                ),
              );
            } else if (state is PaymentMethodsSuccessState) {
              final paymentMethods = [
                _walletPaymentMethod,
                _paymobPaymentMethod,
                ...state.paymentMethodsResponse.paymentMethods ?? [],
              ];

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompactInfoCard(),
                          SizedBox(height: 16.h),
                          _buildPromoCodeSection(),
                          SizedBox(height: 16.h),
                          Text(
                            'Payment Methods',
                            style: TextStyle(
                              fontSize: isTablet ? 20.sp : 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...paymentMethods.map((method) => _buildPaymentMethodCard(method)).toList(),
                          SizedBox(height: 12.h),
                          if (selectedPaymentMethodId != 'Wallet' && selectedPaymentMethodId != '10')
                            _buildPaymentProofSection(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border(top: BorderSide(color: AppColors.grey[200]!)),
                    ),
                    child: Column(
                      children: [
                        _buildPriceSection(),
                        SizedBox(height: 16.h),
                        CustomElevatedButton(
                          text: 'Confirm Purchase',
                          onPressed: confirmPurchase,
                          backgroundColor: AppColors.primary,
                          textStyle: TextStyle(
                            color: AppColors.white,
                            fontSize: isTablet ? 18.sp : 16.sp,
                            fontWeight: FontWeight.bold,
                          ),

                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}