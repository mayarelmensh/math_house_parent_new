import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/domain/entities/payment_methods_response_entity.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/payment_methods_states.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/buy_package_cubit.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/cubit/buy_package_states.dart';
import 'package:math_house_parent_new/core/utils/custom_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;
import '../../../../data/models/currency_model.dart';
import '../currencies_list/cubit/currencies_list_cubit.dart';
import '../currencies_list/cubit/currencies_list_states.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final buyPackageCubit = getIt<BuyPackageCubit>();
  final currenciesCubit = getIt<CurrenciesListCubit>();
  final ImagePicker _picker = ImagePicker();

  int? packageId;
  String? packageName;
  String? packageModule;
  int? packageDuration;
  double? packagePrice;

  String? base64String;
  Uint8List? imageBytes;
  PaymentMethodEntity? selectedMethod;

  Currency? selectedCurrency;

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
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      setState(() {
        packageId = args?['packageId'] as int?;
        packageName = args?['packageName'] as String?;
        packageModule = args?['packageModule'] as String?;
        packageDuration = args?['packageDuration'] as int?;
        packagePrice = args?['packagePrice'] as double?;
      });

      paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
      currenciesCubit.getCurrenciesList();
    });
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    buyPackageCubit.close();
    currenciesCubit.close();
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

  Widget _buildCompactPackageInfoCard(List<Currency> currencies) {
    selectedCurrency ??= currencies.firstWhere(
          (c) => c.currency == 'USD',
      orElse: () => currencies.first,
    );

    double displayedPrice = (packagePrice ?? 0.0) * selectedCurrency!.amount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(isTablet ? 20.w : 10.w),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  packageName ?? 'Package',
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
              Row(
                children: [
                  Text(
                    '${displayedPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isTablet ? 20.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  DropdownButton<Currency>(
                    value: selectedCurrency,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    underline: SizedBox(),
                    onChanged: (Currency? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCurrency = newValue;
                        });
                      }
                    },
                    items: currencies.map<DropdownMenuItem<Currency>>((Currency currency) {
                      return DropdownMenuItem<Currency>(
                        value: currency,
                        child: Text(
                          currency.currency,
                          style: TextStyle(
                            fontSize: isTablet ? 18.sp : 16.sp,
                            color: AppColors.grey[800],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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

  // دالة لفتح رابط واتساب
  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // تنظيف رقم الهاتف من أي رموز أو مسافات
      String cleanPhone = phoneNumber.trim().replaceAll(RegExp(r'[^\d]'), '');

      // إزالة الأصفار من البداية
      while (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }

      // إضافة كود مصر إذا كان الرقم 10 أرقام
      if (cleanPhone.length == 10 || cleanPhone.length == 9) {
        cleanPhone = '20$cleanPhone';
      }

      developer.log('Attempting to open WhatsApp with number: $cleanPhone');

      // محاولة فتح الواتساب بطرق مختلفة
      final whatsappUrl = 'whatsapp://send?phone=$cleanPhone';
      final whatsappWebUrl = 'https://wa.me/$cleanPhone';
      final whatsappApiUrl = 'https://api.whatsapp.com/send?phone=$cleanPhone';

      // محاولة 1: فتح تطبيق الواتساب مباشرة
      try {
        final uri = Uri.parse(whatsappUrl);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          developer.log('WhatsApp opened successfully with whatsapp:// protocol');
          showTopSnackBar(
            context,
            'Opening WhatsApp...',
            AppColors.green,
          );
          return;
        }
      } catch (e) {
        developer.log('Failed to open with whatsapp:// protocol: $e');
      }

      // محاولة 2: فتح عبر wa.me
      try {
        final uri = Uri.parse(whatsappWebUrl);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          developer.log('WhatsApp opened successfully with wa.me');
          showTopSnackBar(
            context,
            'Opening WhatsApp...',
            AppColors.green,
          );
          return;
        }
      } catch (e) {
        developer.log('Failed to open with wa.me: $e');
      }

      // محاولة 3: فتح عبر api.whatsapp.com
      try {
        final uri = Uri.parse(whatsappApiUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        developer.log('WhatsApp opened successfully with api.whatsapp.com');
        showTopSnackBar(
          context,
          'Opening WhatsApp...',
          AppColors.green,
        );
        return;
      } catch (e) {
        developer.log('Failed to open with api.whatsapp.com: $e');
      }

      // إذا فشلت كل المحاولات
      showTopSnackBar(
        context,
        'Please install WhatsApp or check the phone number',
        AppColors.orange,
      );

    } catch (e) {
      developer.log('WhatsApp error: $e');
      showTopSnackBar(
        context,
        'Error: ${e.toString()}',
        AppColors.red,
      );
    }
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;
    final isWhatsAppMethod = method.id.toString() == '42';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          developer.log(
            'Selected payment method ID: ${method.id} (${method.id.runtimeType})',
          );

          if (method.id == 'Wallet' ||
              method.id.toString() == '10' ||
              method.id.toString() == '42') {
            imageBytes = null;
            base64String = null;
          }
        });

        if (isWhatsAppMethod && method.description != null && method.description!.isNotEmpty) {
          _openWhatsApp(method.description!);
        }
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
                : [AppColors.white, AppColors.lightGray],
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
          padding: EdgeInsets.all(isTablet ? 24.w : 20.h),
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
                          isWhatsAppMethod ? FontAwesomeIcons.whatsapp : Icons.payment,
                          color: AppColors.primary,
                          size: isTablet ? 32.sp : 28.sp,
                        ),
                      ),
                    )
                        : Icon(
                      method.paymentType?.toLowerCase() == 'wallet'
                          ? Icons.account_balance_wallet
                          : isWhatsAppMethod
                          ? FontAwesomeIcons.whatsapp
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
              // عرض الوصف لـ WhatsApp method
              if (method.description != null &&
                  method.description!.isNotEmpty &&
                  method.id != '10' &&
                  !isWhatsAppMethod) ...[
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () => _handlePaymentDescription(method.description!),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 16.w : 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isUrl(method.description!) ? Icons.open_in_new : Icons.content_copy,
                          color: AppColors.primary,
                          size: isTablet ? 20.sp : 20.sp,
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
              ] else if (isWhatsAppMethod) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(isTablet ? 16.w : 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.whatsapp,
                        color: AppColors.primaryColor,
                        size: isTablet ? 20.sp : 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Contact us on WhatsApp: ${method.description}',
                          style: TextStyle(
                            fontSize: isTablet ? 16.sp : 16.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color:AppColors.primaryColor,
                        size: isTablet ? 16.sp : 20.sp,
                      ),
                    ],
                  ),
                ),
              ] else if (method.id == '10') ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(isTablet ? 16.w : 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
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
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
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
              child: Icon(Icons.image, size: isTablet ? 48.sp : 40.sp),
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
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
            ),
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
      showTopSnackBar(context, 'Please select a payment method', AppColors.red);
      return;
    }

    String imageData;
    // تحديث الشرط ليشمل payment method 42
    if (selectedMethod!.id == 'Wallet' ||
        selectedMethod!.id.toString() == '10' ||
        selectedMethod!.id.toString() == '42') {
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
      developer.log("Selected payment method ID: ${selectedMethod!.id!}");
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
        BlocProvider.value(value: currenciesCubit),
      ],
      child: BlocListener<BuyPackageCubit, BuyPackageState>(
        listener: (context, state) {
          if (state is BuyPackagePaymentPendingState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackagePaymentWebViewScreen(
                  paymentLink: state.paymentLink,
                  buyPackageCubit: buyPackageCubit,
                ),
              ),
            );
          } else if (state is BuyPackageSuccess) {
            String message;
            if (selectedMethod?.id == 'Wallet' ||
                selectedMethod?.id.toString() == '10' ||
                selectedMethod?.id.toString() == '42') {
              message = 'Package "$packageName" purchase completed successfully!';
            } else {
              message = 'Package "$packageName" purchase is pending!';
            }
            showTopSnackBar(
              context,
              message,
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
          body: BlocBuilder<CurrenciesListCubit, CurrenciesStates>(
            bloc: currenciesCubit,
            builder: (context, currenciesState) {
              return BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
                bloc: paymentMethodsCubit,
                builder: (context, paymentState) {
                  if (paymentState is PaymentMethodsLoadingState || currenciesState is CurrenciesLoading) {
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
                            'Loading payment methods and currencies...',
                            style: TextStyle(
                              fontSize: isTablet ? 18.sp : 16.sp,
                              color: AppColors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (paymentState is PaymentMethodsSuccessState && currenciesState is CurrenciesSuccess) {
                    final methods = [
                      _walletPaymentMethod,
                      ...paymentState.paymentMethodsResponse.paymentMethods!.map((method) {
                        if (method.id.toString() == '10') {
                          return PaymentMethodEntity(
                            id: method.id,
                            payment: 'Visacard/Mastercard',
                            paymentType: method.paymentType,
                            description: method.description,
                            logo: method.logo,
                          );
                        }
                        return method;
                      }).toList(),
                    ];

                    final currencies = currenciesState.currencies;

                    return Column(
                      children: [
                        _buildCompactPackageInfoCard(currencies),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async {
                              paymentMethodsCubit.getPaymentMethods(
                                userId: SelectedStudent.studentId,
                              );
                              currenciesCubit.getCurrenciesList();
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              itemCount: methods.length,
                              itemBuilder: (context, index) => _buildPaymentMethodCard(methods[index]),
                            ),
                          ),
                        ),
                        // إخفاء قسم Payment Proof إذا كان المستخدم اختار Wallet أو ID 10 أو ID 42
                        if (selectedMethod != null &&
                            selectedMethod!.id != 'Wallet' &&
                            selectedMethod!.id.toString() != '10' &&
                            selectedMethod!.id.toString() != '42')
                          _buildPaymentProofSection(),
                        // إخفاء زرار Confirm Purchase لو اختار payment method 42 (WhatsApp)
                        if (selectedMethod != null && selectedMethod!.id.toString() != '42')
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
                              onPressed: confirmPurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 20.h : 0.h,
                                ),
                                minimumSize: Size(
                                  double.infinity,
                                  isTablet ? 56.h : 40.h,
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
                    );
                  } else {
                    String errorMessage = 'Failed to load data';
                    if (paymentState is PaymentMethodsErrorState) {
                      errorMessage = "Something went wrong. Please try again" ?? errorMessage;
                    } else if (currenciesState is CurrenciesError) {
                      errorMessage = "Something went wrong. Please try again" ?? errorMessage;
                    }
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
                              'Failed to load data',
                              style: TextStyle(
                                fontSize: isTablet ? 20.sp : 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              errorMessage,
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
                                currenciesCubit.getCurrenciesList();
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class PackagePaymentWebViewScreen extends StatefulWidget {
  final String paymentLink;
  final BuyPackageCubit buyPackageCubit;

  const PackagePaymentWebViewScreen({
    super.key,
    required this.paymentLink,
    required this.buyPackageCubit,
  });

  @override
  State<PackagePaymentWebViewScreen> createState() => _PackagePaymentWebViewScreenState();
}

class _PackagePaymentWebViewScreenState extends State<PackagePaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  bool get isTablet => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            developer.log('Package WebView Page Started: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            developer.log('Package WebView URL: $url');
            setState(() {
              _isLoading = false;
            });
            _handlePaymentResult(url);
          },
          onNavigationRequest: (request) {
            developer.log('Package Navigation Request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));
  }

  void _handlePaymentResult(String url) {
    developer.log('Package WebView URL: $url');
    if (url.contains('success=true') &&
        url.contains('txn_response_code=APPROVED') &&
        url.contains('error_occured=false')) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.buyPackageCubit.handlePaymentResult(url);
        }
      });
    } else if (url.contains('success=false') ||
        url.contains('error_occured=true') ||
        url.contains('txn_response_code=DECLINED')) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.buyPackageCubit.handlePaymentResult(url);
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
          'Complete Payment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
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