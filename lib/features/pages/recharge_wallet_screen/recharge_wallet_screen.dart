import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/custom_snack_bar.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/domain/entities/payment_methods_response_entity.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/payment_methods_states.dart';
import 'package:math_house_parent_new/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_cubit.dart';
import 'package:math_house_parent_new/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_states.dart';
import 'package:math_house_parent_new/features/pages/wallet_history/cubit/wallet_history_cubit.dart';
import 'package:math_house_parent_new/features/pages/wallet_history/cubit/wallet_history_states.dart';
import 'package:math_house_parent_new/features/widgets/custom_elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;

class WalletRechargeScreen extends StatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  State<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends State<WalletRechargeScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final walletRechargeCubit = getIt<WalletRechargeCubit>();
  final walletHistoryCubit = getIt<WalletHistoryCubit>();
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  double? rechargeAmount;
  PaymentMethodEntity? selectedMethod;
  String? base64String;
  Uint8List? imageBytes;

  bool get isTablet => MediaQuery.of(context).size.width > 600;
  bool get isDesktop => MediaQuery.of(context).size.width > 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('Initializing WalletRechargeScreen: Fetching payment methods and wallet data for user: ${SelectedStudent.studentId}');
      paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
      walletHistoryCubit.fetchWalletData(userId: SelectedStudent.studentId);
    });
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    walletHistoryCubit.close();
    _amountController.dispose();
    super.dispose();
  }

  void _refreshWalletBalance() {
    developer.log('Refreshing wallet balance for user: ${SelectedStudent.studentId}');
    walletHistoryCubit.fetchWalletData(userId: SelectedStudent.studentId);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
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

        showTopSnackBar(
          context,
          'Payment proof uploaded successfully',
          AppColors.green,
        );
      }
    } catch (e) {
      developer.log('Error selecting image: $e');
      showTopSnackBar(
        context,
        'Error selecting image: $e',
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

  bool _isUrl(String text) {
    return Uri.tryParse(text)?.hasScheme ?? false &&
        (text.startsWith('http://') || text.startsWith('https://'));
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

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          developer.log('Selected payment method ID: ${method.id} (${method.id.runtimeType})');
          if (method.id.toString() == '10') {
            imageBytes = null;
            base64String = null;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
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
          padding: EdgeInsets.all(isTablet ? 24.w : 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isTablet ? 70.w : 40.w,
                    height: isTablet ? 70.h : 40.h,
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
                      Icons.payment,
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
                          method.id.toString() == '10'
                              ? 'Visa/Mastercard'
                              : method.payment ?? "Unknown Payment",
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
                          'Press "Recharge Wallet" to proceed with the payment link',
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
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
              fontSize: isTablet ? 16.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload a screenshot or photo of your payment confirmation',
            style: TextStyle(
              fontSize: isTablet ? 14.sp : 12.sp,
              color: AppColors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
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
              height: isTablet ? 200.h : 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.image,
                size: isTablet ? 48.sp : 40.sp,
              ),
            ),
          SizedBox(height: 12.h),
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
                      vertical: isTablet ? 16.h : 10.h,
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
                    developer.log('Image cleared');
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: paymentMethodsCubit),
        BlocProvider.value(value: walletRechargeCubit),
        BlocProvider.value(value: walletHistoryCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: "Recharge Wallet"),
        body: BlocListener<WalletRechargeCubit, WalletRechargeStates>(
          listener: (context, state) {
            developer.log('WalletRechargeState received: ${state.runtimeType}');

            if (state is WalletRechargePaymentPendingState) {
              developer.log('Payment link received: ${state.paymentLink}');

              if (state.paymentLink.isNotEmpty) {
                final uri = Uri.tryParse(state.paymentLink);
                if (uri != null && (uri.hasScheme || state.paymentLink.startsWith('http'))) {
                  developer.log('Opening WebView for PayMob payment: ${state.paymentLink}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WalletPaymentWebViewScreen(
                        paymentLink: state.paymentLink,
                        onPaymentResult: (isSuccess, errorMessage) {
                          if (isSuccess) {
                            showTopSnackBar(
                              context,
                              'Wallet recharged successfully!',
                              AppColors.green,
                            );
                            setState(() {
                              _amountController.clear();
                              rechargeAmount = null;
                              selectedMethod = null;
                              imageBytes = null;
                              base64String = null;
                            });
                            _refreshWalletBalance();
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
                  ).then((_) {
                    developer.log('Returned from WebView, refreshing wallet data');
                    _refreshWalletBalance();
                  });
                } else {
                  developer.log('Invalid payment link: ${state.paymentLink}');
                  showTopSnackBar(
                    context,
                    'Invalid payment link received from server',
                    AppColors.red,
                  );
                }
              } else {
                developer.log('Empty payment link received');
                showTopSnackBar(
                  context,
                  'No payment link provided by server',
                  AppColors.red,
                );
              }
            } else if (state is WalletRechargeSuccessState) {
              developer.log('Wallet recharge successful (non-PayMob method)');
              showTopSnackBar(
                context,
                'Wallet recharge is pending approval!',
                AppColors.green,
              );
              setState(() {
                _amountController.clear();
                rechargeAmount = null;
                selectedMethod = null;
                imageBytes = null;
                base64String = null;
              });
              developer.log('Refreshing wallet after non-PayMob recharge');
              _refreshWalletBalance();
            } else if (state is WalletRechargeErrorState) {
              developer.log('Recharge error: ${state.error}');
              showTopSnackBar(
                context,
                'Error: ${state.error}',
                AppColors.red,
              );
            }
          },
          child: Column(
            children: [
              BlocBuilder<WalletHistoryCubit, WalletState>(
                builder: (context, state) {
                  int? balance = 0;
                  bool isLoading = state is WalletLoading;

                  if (state is WalletLoaded) {
                    balance = state.response.money;
                  }
                  developer.log('Current wallet balance: $balance EGP, Loading: $isLoading');
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),
                    margin: EdgeInsets.symmetric(horizontal:16.w,vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowGrey,
                          blurRadius: 8,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                        Row(
                          children: [
                            if (isLoading)
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            Text(
                              '$balance \$',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                padding: EdgeInsets.symmetric(horizontal: (isTablet ? 20.w : 16.w),vertical: (isTablet ? 20.w : 5.w)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Recharge Amount",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter amount in EGP',
                        prefixIcon: Icon(
                          Icons.monetization_on,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      onChanged: (value) {
                        setState(() {
                          rechargeAmount = double.tryParse(value);
                        });
                        developer.log('Recharge amount updated: $rechargeAmount');
                      },
                    ),
                    if (rechargeAmount != null && rechargeAmount! > 0) ...[
                      SizedBox(height: 8.h),
                      Text(
                        "Amount: ${rechargeAmount!.toStringAsFixed(2)} EGP",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
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
                      final methods = state.paymentMethodsResponse.paymentMethods
                          ?.where((method) => method.paymentType?.toLowerCase() != 'wallet')
                          .toList() ??
                          [];
                      developer.log('Loaded ${methods.length} payment methods');

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          paymentMethodsCubit.getPaymentMethods(
                            userId: SelectedStudent.studentId,
                          );
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: methods.length,
                          itemBuilder: (context, index) => _buildPaymentMethodCard(methods[index]),
                        ),
                      );
                    } else if (state is PaymentMethodsErrorState) {
                      developer.log('Payment methods error: ${state.error}');
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
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              if (selectedMethod != null && selectedMethod!.id.toString() != '10')
                _buildPaymentProofSection(),
              if (selectedMethod != null)
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
                  child: BlocBuilder<WalletRechargeCubit, WalletRechargeStates>(
                    builder: (context, rechargeState) {
                      final isLoading = rechargeState is WalletRechargeLoadingState;
                      final canRecharge = selectedMethod != null &&
                          rechargeAmount != null &&
                          rechargeAmount! > 0 &&
                          (selectedMethod!.id.toString() == '10' || base64String != null);

                      return ElevatedButton(
                        onPressed: canRecharge && !isLoading
                            ? () async {
                          developer.log(
                              'Recharge button pressed. Payment Method ID: ${selectedMethod!.id}, Amount: $rechargeAmount');
                          String imageData;
                          if (selectedMethod!.id.toString() == '10') {
                            imageData = 'wallet';
                            developer.log('Using PayMob (ID=10), image set to: wallet');
                          } else {
                            imageData = 'data:image/jpeg;base64,$base64String';
                            developer.log('Using other payment method, base64 image provided');
                          }

                          try {
                            await walletRechargeCubit.rechargeWallet(
                              userId: SelectedStudent.studentId,
                              wallet: rechargeAmount!,
                              paymentMethodId: selectedMethod!.id!,
                              image: imageData,
                            );
                          } catch (e) {
                            developer.log('Error in recharge: $e');
                            showTopSnackBar(
                              context,
                              'Something went wrong, please try again: $e',
                              AppColors.red,
                            );
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          canRecharge && !isLoading ? AppColors.primary : AppColors.grey[400]!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 20.h : 0.h,
                          ),
                          minimumSize: Size(double.infinity, isTablet ? 56.h : 40.h),
                        ),
                        child: Text(
                          isLoading ? "Processing..." : "Recharge Wallet",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: isTablet ? 18.sp : 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
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

class WalletPaymentWebViewScreen extends StatefulWidget {
  final String paymentLink;
  final Function(bool, String?) onPaymentResult;

  const WalletPaymentWebViewScreen({
    super.key,
    required this.paymentLink,
    required this.onPaymentResult,
  });

  @override
  State<WalletPaymentWebViewScreen> createState() => _WalletPaymentWebViewScreenState();
}

class _WalletPaymentWebViewScreenState extends State<WalletPaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  bool get isTablet => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing WalletPaymentWebView with link: ${widget.paymentLink}');

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
            developer.log('WebView Page Finished: $url');
            setState(() {
              _isLoading = false;
            });
            _handlePaymentResult(url);
          },
          onNavigationRequest: (request) {
            developer.log('Navigation Request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    final uri = Uri.tryParse(widget.paymentLink);
    if (uri != null && (uri.hasScheme || widget.paymentLink.startsWith('http'))) {
      developer.log('Loading WebView with URL: ${widget.paymentLink}');
      _controller.loadRequest(Uri.parse(widget.paymentLink));
    } else {
      developer.log('Invalid payment link: ${widget.paymentLink}');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      widget.onPaymentResult(false, 'Invalid payment link');
    }
  }

  void _handlePaymentResult(String url) {
    developer.log('Handling payment result for URL: $url');

    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      developer.log('Payment SUCCESS detected');
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onPaymentResult(true, null);
        }
      });
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      developer.log('Payment FAILURE detected');
      String errorMessage = 'Payment failed';
      if (url.contains('txn_response_code=DECLINED')) {
        errorMessage = 'Payment was declined by the payment gateway';
      } else if (url.contains('error_occured=true')) {
        errorMessage = 'An error occurred during payment processing';
      }
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onPaymentResult(false, errorMessage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Wallet Recharge Payment',
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
            developer.log('User cancelled payment');
            Navigator.pop(context);
            widget.onPaymentResult(false, 'Payment cancelled by user');
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isTablet ? 56.sp : 48.sp,
                      color: AppColors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load payment page',
                      style: TextStyle(
                        fontSize: isTablet ? 18.sp : 16.sp,
                        color: AppColors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              WebViewWidget(controller: _controller),
            if (_isLoading && !_hasError)
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