import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../../../core/di/di.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/student_selected.dart';
import 'cubit/buy_package_cubit.dart';
import 'cubit/buy_package_states.dart';
import 'dart:developer' as developer;

class BuyPackageScreen extends StatefulWidget {
  final int? packageId;
  final dynamic paymentMethodId;
  final String? paymentMethodName;
  final String? packageName;
  final int? packageDuration;
  final double? packagePrice;

  BuyPackageScreen({
    Key? key,
    this.packageId,
    this.paymentMethodId,
    this.paymentMethodName,
    this.packageName,
    this.packageDuration,
    this.packagePrice,
  }) : super(key: key);

  @override
  _BuyPackageScreenState createState() => _BuyPackageScreenState();
}

class _BuyPackageScreenState extends State<BuyPackageScreen> {
  final buyPackageCubit = getIt<BuyPackageCubit>();
  final ImagePicker _picker = ImagePicker();

  int? packageId;
  dynamic paymentMethodId;
  String? paymentMethodName;
  String? packageName;
  int? packageDuration;
  double? packagePrice;

  String? base64String;
  Uint8List? imageBytes;

  bool get isTablet => MediaQuery.of(context).size.width > 600;
  bool get isDesktop => MediaQuery.of(context).size.width > 1024;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    setState(() {
      packageId = widget.packageId ?? args?['packageId'] as int?;
      paymentMethodId = widget.paymentMethodId ?? args?['paymentMethodId'];
      paymentMethodName = (widget.paymentMethodName ?? args?['paymentMethodName'] as String?)?.toLowerCase();
      packageName = widget.packageName ?? args?['packageName'] as String?;
      packageDuration = widget.packageDuration ?? args?['packageDuration'] as int?;
      packagePrice = widget.packagePrice ?? args?['packagePrice'] as double?;
    });

    if (packageId == null || paymentMethodId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTopSnackBar(
          context,
          'Missing package or payment method data',
          AppColors.red,
        );
      });
    }
  }

  @override
  void dispose() {
    buyPackageCubit.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
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

  void _showImageSourceBottomSheet() {
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
                      _pickImage(ImageSource.camera);
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
                      _pickImage(ImageSource.gallery);
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

  void _confirmPurchase() {
    if (packageId == null || paymentMethodId == null) {
      showTopSnackBar(
        context,
        'Missing package or payment method data',
        AppColors.red,
      );
      return;
    }

    String imageData;
    if (paymentMethodName == 'wallet' || paymentMethodId == '10') {
      imageData = 'wallet';
      paymentMethodId = paymentMethodName == 'wallet' ? 'Wallet' : paymentMethodId;
    } else {
      if (base64String == null) {
        showTopSnackBar(
          context,
          'Please upload the invoice image',
          AppColors.red,
        );
        return;
      }
      imageData = 'data:image/jpeg;base64,$base64String';
    }

    try {
      buyPackageCubit.buyPackage(
        packageId: packageId!,
        paymentMethodId: paymentMethodId!,
        userId: SelectedStudent.studentId,
        image: imageData,
      );
    } catch (e) {
      developer.log('Error in purchase: $e');
      showTopSnackBar(
        context,
        'Something went wrong, please try again: $e',
        AppColors.red,
      );
    }
  }

  Widget _buildPackageInfoCard() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Package: ${packageName ?? 'Unknown'}',
            style: TextStyle(
              fontSize: isTablet ? 18.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
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
                '${packagePrice?.toStringAsFixed(2) ?? "0.00"} EGP',
                style: TextStyle(
                  fontSize: isTablet ? 20.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Duration: ${packageDuration ?? 30} days',
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: AppColors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => buyPackageCubit,
      child: BlocListener<BuyPackageCubit, BuyPackageState>(
        listener: (context, state) {
          if (state is BuyPackageSuccess) {
            showTopSnackBar(
              context,
              'Package "${packageName ?? 'Unknown'}" purchased successfully!',
              AppColors.green,
            );
            Navigator.pop(context);
          } else if (state is BuyPackageError) {
            showTopSnackBar(
              context,
              state.message ?? 'Something went wrong, please try again',
              AppColors.red,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightGray,
          appBar: CustomAppBar(title: "Buy Package"),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
                child: _buildPackageInfoCard(),
              ),
              if (paymentMethodName != 'wallet' && paymentMethodId != '10') ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.w : 16.w),
                  child: Column(
                    children: [
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
                              onPressed: _showImageSourceBottomSheet,
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
                  ),
                ),
              ],
              Expanded(
                child: Container(),
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
                  onPressed: (paymentMethodName == 'wallet' || paymentMethodId == '10' || base64String != null)
                      ? _confirmPurchase
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 20.h : 16.h,
                    ),
                    minimumSize: Size(
                      double.infinity,
                      isTablet ? 56.h : 50.h,
                    ),
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
  }
}