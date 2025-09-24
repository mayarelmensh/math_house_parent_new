import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/buy_package_states.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../core/di/di.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/student_selected.dart';
import '../../../domain/entities/payment_methods_response_entity.dart';
import '../../widgets/custom_elevated_button.dart';
import 'cubit/payment_methods_cubit.dart';
import 'cubit/payment_methods_states.dart';
import 'cubit/buy_package_cubit.dart';
import '../../../core/utils/custom_snack_bar.dart';
import 'dart:developer' as developer;

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final buyPackageCubit = getIt<BuyPackageCubit>();
  final ImagePicker _picker = ImagePicker();

  int? packageId;
  String? packageName;
  String? packageModule;
  int? packageDuration;
  double? packagePrice;

  String? base64String;
  Uint8List? imageBytes;
  PaymentMethodEntity? selectedMethod;

  final PaymentMethodEntity _walletPaymentMethod = PaymentMethodEntity(
    id: "Wallet",
    payment: 'Wallet',
    paymentType: 'Wallet',
    description: 'Pay using your wallet balance',
    logo: '',
  );

  bool get isTablet => MediaQuery.of(context).size.width > 600;
  bool get isDesktop => MediaQuery.of(context).size.width > 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      setState(() {
        packageId = args?['packageId'] as int?;
        packageName = args?['packageName'] as String?;
        packageModule = args?['packageModule'] as String?;
        packageDuration = args?['packageDuration'] as int?;
        packagePrice = args?['packagePrice'] as double?;
      });

      paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
    });
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    buyPackageCubit.close();
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

  Widget _buildCompactPackageInfoCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(isTablet ? 20.w : 13.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               packageName ?? "N/A",
               style: TextStyle(
                 fontSize: isTablet ? 18.sp : 16.sp,
                 fontWeight: FontWeight.bold,
                 color: AppColors.grey[800],
               ),
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
             ),

             Text(
               'Duration: ${packageDuration ?? 30} days',
               style: TextStyle(
                 fontSize: isTablet ? 16.sp : 14.sp,
                 color: AppColors.grey[700],
               ),
             ),
           ],
         ),
          SizedBox(height: 5.h),
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
                  color: AppColors.green,
                ),
              ),
            ],
          ),

        ],
      ),
    );
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

  Color _getModuleColor(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return Colors.red.shade500;
      case 'question':
        return Colors.blue.shade500;
      case 'exam':
        return Colors.purple.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          if (method.id == 'Wallet' || method.id == '10') {
            imageBytes = null;
            base64String = null;
          }
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
                  method.id != '10') ...[
                SizedBox(height: 8.h),
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
              ] else if (method.id == '10') ...[
                SizedBox(height: 8.h),
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
  }

  Widget _buildPaymentProofSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
      padding: EdgeInsets.all(isTablet ? 20.w : 10.w),
      decoration: BoxDecoration(
        color: AppColors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Proof',
            style: TextStyle(
              fontSize: isTablet ? 14.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey[800],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Upload a screenshot or photo of your payment confirmation',
            style: TextStyle(fontSize: isTablet ? 12.sp : 11.sp, color: AppColors.grey[600]),
          ),
          SizedBox(height: 8.h),
          if (imageBytes != null)
            Container(
              width: double.infinity,
              height: isTablet ? 200.h : 100.h,
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
              height: isTablet ? 200.h : 30.h,
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
                  onPressed: showImageSourceBottomSheet,
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
        ],
      ),
    );
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

  void confirmPurchase() async {
    if (selectedMethod == null) {
      showTopSnackBar(
        context,
        'Please select a payment method',
        AppColors.red,
      );
      return;
    }

    String imageData;
    if (selectedMethod!.id == 'Wallet' || selectedMethod!.id == '10') {
      imageData = 'wallet';
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
      await buyPackageCubit.buyPackage(
        packageId: packageId!,
        paymentMethodId: selectedMethod!.id!,
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: paymentMethodsCubit),
        BlocProvider.value(value: buyPackageCubit),
      ],
      child: BlocListener<BuyPackageCubit, BuyPackageState>(
        listener: (context, state) {
          if (state is BuyPackageSuccess) {
            showTopSnackBar(
              context,
              'Package "$packageName" purchased successfully!',
              AppColors.green,
            );
            Navigator.pop(context);
          } else if (state is BuyPackageError) {
            showTopSnackBar(
              context,
              'Please select a valid method or check your wallet balance',
              AppColors.red,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightGray,
          appBar: CustomAppBar(title: "Select Payment Method"),
          body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
            bloc: paymentMethodsCubit,
            builder: (context, state) {
              if (state is PaymentMethodsLoadingState) {
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
                        'Loading payment methods...',
                        style: TextStyle(
                          fontSize: isTablet ? 18.sp : 16.sp,
                          color: AppColors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is PaymentMethodsSuccessState) {
                final methods = [
                  _walletPaymentMethod,
                  PaymentMethodEntity(
                    id: '10',
                    payment: 'Visacard/ Mastercard',
                    paymentType: 'integration',
                    description: 'Pay using Paymob',
                    logo: 'https://cdn.paymob.com/images/logos/paymob-logo.png',
                  ),
                  ...?state.paymentMethodsResponse.paymentMethods,
                ];
                return Column(
                  children: [
                    _buildCompactPackageInfoCard(),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          paymentMethodsCubit.getPaymentMethods(
                            userId: SelectedStudent.studentId,
                          );
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: methods.length,
                          itemBuilder: (context, index) =>
                              _buildPaymentMethodCard(methods[index]),
                        ),
                      ),
                    ),
                    if (selectedMethod != null) ...[
                      if (selectedMethod?.id != 'Wallet' && selectedMethod?.id != '10')
                        _buildPaymentProofSection(),
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
                          onPressed: (selectedMethod != null &&
                              (selectedMethod!.id == 'Wallet' ||
                                  selectedMethod!.id == '10' ||
                                  base64String != null))
                              ? confirmPurchase
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: isTablet ? 20.h : 0.h),
                            minimumSize: Size(double.infinity, isTablet ? 56.h : 35.h),
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
                  ],
                );
              } else {
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
                          'Failed to load payment methods',
                          style: TextStyle(
                            fontSize: isTablet ? 20.sp : 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please check your connection and try again',
                          style: TextStyle(
                            fontSize: isTablet ? 16.sp : 14.sp,
                            color: AppColors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            paymentMethodsCubit.getPaymentMethods(
                              userId: SelectedStudent.studentId,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
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
            },
          ),
        ),
      ),
    );
  }
}