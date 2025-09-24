// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:math_house_parent_new/core/di/di.dart';
// import 'package:math_house_parent_new/core/utils/app_colors.dart';
// import 'package:math_house_parent_new/core/utils/custom_snack_bar.dart';
// import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
// import 'package:math_house_parent_new/data/models/payment_methods_response_dm.dart';
// import 'package:math_house_parent_new/data/models/student_selected.dart';
// import 'package:math_house_parent_new/domain/entities/courses_response_entity.dart';
// import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_chapter_cubit.dart';
// import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_chapter_states.dart';
// import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_course_cubit.dart';
// import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_course_states.dart';
// import 'package:math_house_parent_new/features/pages/payment_methods/cubit/payment_methods_cubit.dart';
// import 'package:math_house_parent_new/features/pages/payment_methods/cubit/payment_methods_states.dart';
// import 'package:math_house_parent_new/features/pages/promo_code_screen/cubit/promo_code_cubit.dart';
// import 'package:math_house_parent_new/features/pages/promo_code_screen/cubit/promo_code_states.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/services.dart';
//
// class CoursePaymentMethodsScreen extends StatefulWidget {
//   final CourseEntity course;
//   final ChaptersEntity? chapter;
//
//   const CoursePaymentMethodsScreen({
//     Key? key,
//     required this.course,
//     this.chapter,
//   }) : super(key: key);
//
//   @override
//   _CoursePaymentMethodsScreenState createState() => _CoursePaymentMethodsScreenState();
// }
//
// class _CoursePaymentMethodsScreenState extends State<CoursePaymentMethodsScreen> {
//   final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
//   final buyCourseCubit = getIt<BuyCourseCubit>();
//   final buyChapterCubit = getIt<BuyChapterCubit>();
//   final promoCodeCubit = getIt<PromoCodeCubit>();
//   final ImagePicker _picker = ImagePicker();
//
//   dynamic selectedPaymentMethodId = 'Wallet';
//   double? newPrice;
//   final TextEditingController promoController = TextEditingController();
//   bool isPromoExpanded = false;
//   String? base64String;
//   Uint8List? imageBytes;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
//     });
//   }
//
//   @override
//   void dispose() {
//     promoController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//       if (pickedFile != null) {
//         final File imageFile = File(pickedFile.path);
//         final List<int> imageFileBytes = await imageFile.readAsBytes();
//         final String imageBase64 = base64Encode(imageFileBytes);
//         setState(() {
//           imageBytes = Uint8List.fromList(imageFileBytes);
//           base64String = imageBase64;
//         });
//         showTopSnackBar(context, 'Payment proof uploaded successfully', AppColors.green);
//       }
//     } catch (e) {
//       showTopSnackBar(context, 'Something went wrong, please try again', AppColors.red);
//     }
//   }
//
//   void _showImageSourceBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => Container(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Select Image Source',
//               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImage(ImageSource.camera);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(16.w),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.camera_alt,
//                             size: 32.sp,
//                             color: AppColors.primary,
//                           ),
//                           SizedBox(height: 6.h),
//                           Text('Camera'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImage(ImageSource.gallery);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(16.w),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.photo_library,
//                             size: 32.sp,
//                             color: AppColors.primary,
//                           ),
//                           SizedBox(height: 6.h),
//                           Text('Gallery'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCompactInfoCard() {
//     final isChapter = widget.chapter != null;
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.08),
//             blurRadius: 8,
//             offset: Offset(0, 2.h),
//             spreadRadius: 0.5,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(6.w),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(
//               Icons.book,
//               color: AppColors.primary,
//               size: 16.sp,
//             ),
//           ),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isChapter ? widget.chapter!.chapterName ?? "N/A" : widget.course.courseName ?? "N/A",
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Row(
//                   children: [
//                     Text(
//                       isChapter ? 'Chapter' : 'Course',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       "${isChapter ? (widget.chapter!.chapterAllPrices?.isNotEmpty == true ? widget.chapter!.chapterAllPrices!.first.duration ?? 30 : 30) : (widget.course.allPrices?.isNotEmpty == true ? widget.course.allPrices!.first.duration ?? 30 : 30)} Days",
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       "${(isChapter ? widget.chapter!.chapterPrice : widget.course.price)?.toStringAsFixed(2) ?? '0.00'} EGP",
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.green.shade600,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPromoCodeSection(double originalPrice, double finalPrice) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: () {
//               setState(() {
//                 isPromoExpanded = !isPromoExpanded;
//               });
//             },
//             child: Container(
//               padding: EdgeInsets.all(12.w),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.local_offer,
//                     color: AppColors.primary,
//                     size: 20.sp,
//                   ),
//                   SizedBox(width: 12.w),
//                   Text(
//                     'Promo Code',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   Spacer(),
//                   if (newPrice != null)
//                     Text(
//                       'Applied',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: AppColors.green,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   SizedBox(width: 8.w),
//                   Icon(
//                     isPromoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                     color: Colors.grey.shade600,
//                     size: 20.sp,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isPromoExpanded)
//             Container(
//               padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: promoController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                           decoration: InputDecoration(
//                             hintText: 'Enter promo code',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.r),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.r),
//                               borderSide: BorderSide(color: AppColors.primary),
//                             ),
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 12.w,
//                               vertical: 12.h,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 8.w),
//                       BlocBuilder<PromoCodeCubit, PromoCodeStates>(
//                         builder: (context, promoState) {
//                           return ElevatedButton(
//                             onPressed: promoState is PromoCodeLoadingState
//                                 ? null
//                                 : () {
//                               if (promoController.text.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please enter a promo code'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                                 return;
//                               }
//                               final promoCode = int.tryParse(promoController.text);
//                               if (promoCode == null) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please enter a valid promo code'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                                 return;
//                               }
//                               promoCodeCubit.applyPromoCode(
//                                 promoCode: promoCode,
//                                 courseId: widget.course.id!,
//                                 userId: SelectedStudent.studentId,
//                                 originalAmount: originalPrice,
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 16.w,
//                                 vertical: 12.h,
//                               ),
//                             ),
//                             child: promoState is PromoCodeLoadingState
//                                 ? SizedBox(
//                               width: 20.w,
//                               height: 20.h,
//                               child: CircularProgressIndicator(
//                                 color: AppColors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                                 : Text(
//                               'Apply',
//                               style: TextStyle(
//                                 color: AppColors.white,
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   if (newPrice != null) ...[
//                     SizedBox(height: 12.h),
//                     Container(
//                       padding: EdgeInsets.all(12.w),
//                       decoration: BoxDecoration(
//                         color: AppColors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8.r),
//                         border: Border.all(color: AppColors.green.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.check_circle,
//                             color: AppColors.green,
//                             size: 16.sp,
//                           ),
//                           SizedBox(width: 8.w),
//                           Expanded(
//                             child: Text(
//                               'Promo code applied! You save ${(originalPrice - newPrice!).toStringAsFixed(0)} EGP',
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: AppColors.green,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 newPrice = null;
//                                 promoController.clear();
//                               });
//                             },
//                             icon: Icon(
//                               Icons.close,
//                               size: 16.sp,
//                               color: AppColors.red,
//                             ),
//                             padding: EdgeInsets.zero,
//                             constraints: BoxConstraints(
//                               minWidth: 24.w,
//                               minHeight: 24.h,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPriceSection(double originalPrice, double finalPrice) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           if (newPrice != null && newPrice != originalPrice) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Original Price:',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.grey.shade600,
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//                 Text(
//                   '${originalPrice.toStringAsFixed(2)} EGP',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.grey.shade600,
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.h),
//           ],
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Final Price:',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               Text(
//                 '${finalPrice.toStringAsFixed(2)} EGP',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: newPrice != null ? AppColors.green : AppColors.primary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentProofSection() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Payment Proof',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             'Upload a screenshot or photo of your payment confirmation',
//             style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
//           ),
//           SizedBox(height: 8.h),
//           if (imageBytes != null)
//             Container(
//               width: double.infinity,
//               constraints: BoxConstraints(maxHeight: 100.h),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: AppColors.primary),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10.r),
//                 child: Image.memory(
//                   imageBytes!,
//                   fit: BoxFit.contain,
//                   width: double.infinity,
//                 ),
//               ),
//             )
//           else
//             Container(
//               width: double.infinity,
//               height: 80.h,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.r),
//                 color: Colors.grey.shade100,
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.cloud_upload_outlined,
//                     size: 28.sp,
//                     color: Colors.grey.shade400,
//                   ),
//                   SizedBox(height: 6.h),
//                   Text(
//                     'No image selected',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           SizedBox(height: 8.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: _showImageSourceBottomSheet,
//                   icon: Icon(
//                     Icons.upload_file,
//                     color: AppColors.white,
//                     size: 16.sp,
//                   ),
//                   label: Text(
//                     'Upload Image',
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                   ),
//                 ),
//               ),
//               if (imageBytes != null) ...[
//                 SizedBox(width: 8.w),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(6.r),
//                   ),
//                   child: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         imageBytes = null;
//                         base64String = null;
//                       });
//                     },
//                     icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodCard(PaymentMethodDm method) {
//     final isSelected = selectedPaymentMethodId == method.id;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedPaymentMethodId = method.id;
//           if (method.id == 'Wallet' || method.id == '10') {
//             imageBytes = null;
//             base64String = null;
//           }
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isSelected
//                 ? [
//               AppColors.primary.withOpacity(0.15),
//               AppColors.primary.withOpacity(0.05),
//             ]
//                 : [AppColors.white, Colors.grey.shade50],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : Colors.grey.shade200,
//             width: isSelected ? 1.5.w : 1.w,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
//               spreadRadius: 0.5,
//               blurRadius: isSelected ? 6 : 3,
//               offset: Offset(0, 2.h),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(12.w),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 40.w,
//                     height: 40.h,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.r),
//                       color: Colors.grey.shade100,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10.r),
//                       child: method.logo != null && method.logo!.isNotEmpty
//                           ? Image.network(
//                         method.logo!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, _, __) => Icon(
//                           Icons.payment,
//                           color: AppColors.primary,
//                           size: 20.sp,
//                         ),
//                       )
//                           : Icon(
//                         method.paymentType?.toLowerCase() == 'wallet'
//                             ? Icons.account_balance_wallet
//                             : Icons.payment,
//                         color: AppColors.primary,
//                         size: 20.sp,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           method.payment ?? "Unknown Payment",
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected ? AppColors.primary : Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 4.h),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 6.w,
//                             vertical: 3.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _getPaymentTypeColor(method.paymentType),
//                             borderRadius: BorderRadius.circular(6.r),
//                           ),
//                           child: Text(
//                             _getPaymentTypeText(method.paymentType),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (isSelected)
//                     Container(
//                       padding: EdgeInsets.all(3.w),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Icon(
//                         Icons.check,
//                         color: Colors.white,
//                         size: 14.sp,
//                       ),
//                     )
//                   else
//                     Container(
//                       width: 20.w,
//                       height: 20.h,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade400),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (isSelected && method.description != null && method.description!.isNotEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
//                 child: Container(
//                   padding: EdgeInsets.all(10.w),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(8.r),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Payment Details:',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         method.description!,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade800,
//                           height: 1.3,
//                         ),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       if (method.paymentType?.toLowerCase() == 'phone') ...[
//                         SizedBox(height: 6.h),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               await Clipboard.setData(ClipboardData(text: method.description!));
//                               showTopSnackBar(
//                                 context,
//                                 'Payment number copied to clipboard',
//                                 AppColors.green,
//                               );
//                             },
//                             icon: Icon(
//                               Icons.copy,
//                               size: 12.sp,
//                               color: AppColors.white,
//                             ),
//                             label: Text(
//                               'Copy Payment Number',
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.blue,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6.r),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 10.w,
//                                 vertical: 5.h,
//                               ),
//                               minimumSize: Size(0, 28.h),
//                             ),
//                           ),
//                         ),
//                       ],
//                       if (method.paymentType?.toLowerCase() == 'link' || method.paymentType?.toLowerCase() == 'integration') ...[
//                         SizedBox(height: 6.h),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               final url = method.description!;
//                               final uri = Uri.tryParse(url);
//                               if (uri != null) {
//                                 final canLaunch = await canLaunchUrl(uri);
//                                 if (canLaunch) {
//                                   await launchUrl(
//                                     uri,
//                                     mode: LaunchMode.externalApplication,
//                                   );
//                                 } else {
//                                   await launchUrl(
//                                     uri,
//                                     mode: LaunchMode.inAppWebView,
//                                     webViewConfiguration: const WebViewConfiguration(
//                                       enableJavaScript: true,
//                                     ),
//                                   );
//                                 }
//                               } else {
//                                 showTopSnackBar(context, 'Invalid URL', AppColors.red);
//                               }
//                             },
//                             icon: Icon(
//                               Icons.link,
//                               size: 12.sp,
//                               color: AppColors.white,
//                             ),
//                             label: Text(
//                               'Open Payment Link',
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.purple,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6.r),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 10.w,
//                                 vertical: 5.h,
//                               ),
//                               minimumSize: Size(0, 28.h),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color _getPaymentTypeColor(String? type) {
//     switch (type?.toLowerCase()) {
//       case 'phone':
//         return AppColors.green;
//       case 'link':
//         return AppColors.blue;
//       case 'integration':
//         return AppColors.purple;
//       case 'text':
//         return AppColors.orange;
//       case 'wallet':
//         return AppColors.yellow;
//       default:
//         return Colors.grey.shade500;
//     }
//   }
//
//   String _getPaymentTypeText(String? type) {
//     switch (type?.toLowerCase()) {
//       case 'phone':
//         return 'Phone';
//       case 'link':
//         return 'Link';
//       case 'integration':
//         return 'Online';
//       case 'text':
//         return 'Manual';
//       case 'wallet':
//         return 'Wallet';
//       default:
//         return 'Other';
//     }
//   }
//
//   void _confirmPurchase(double originalPrice, double finalPrice) async {
//     if (selectedPaymentMethodId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a payment method'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//
//     String imageData;
//     if (selectedPaymentMethodId == 'Wallet' || selectedPaymentMethodId == '10') {
//       imageData = 'wallet';
//     } else {
//       if (base64String == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please upload the invoice image'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       imageData = 'data:image/jpeg;base64,$base64String';
//     }
//
//     try {
//       if (widget.chapter == null) {
//         await buyCourseCubit.buyPackage(
//           courseId: "${widget.course.id!}",
//           paymentMethodId: "$selectedPaymentMethodId",
//           amount: "${finalPrice.toStringAsFixed(2)}",
//           userId: "${SelectedStudent.studentId}",
//           duration: "${(widget.course.allPrices?.isNotEmpty == true ? widget.course.allPrices!.first.duration ?? 30 : 30)}",
//           image: imageData,
//           promoCode: promoController.text.isNotEmpty ? promoController.text : null,
//         );
//       } else {
//         await buyChapterCubit.buyChapter(
//           courseId: "${widget.course.id!}",
//           paymentMethodId: "$selectedPaymentMethodId",
//           amount: "${finalPrice.toStringAsFixed(2)}",
//           userId: "${SelectedStudent.studentId}",
//           chapterId: "${widget.chapter!.id!}",
//           duration: "${(widget.chapter!.chapterAllPrices?.isNotEmpty == true ? widget.chapter!.chapterAllPrices!.first.duration ?? 30 : 30)}",
//           image: imageData,
//           promoCode: promoController.text.isNotEmpty ? promoController.text : null,
//         );
//       }
//     } catch (e) {
//       showTopSnackBar(
//         context,
//         'Something went wrong, please try again: $e',
//         AppColors.red,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final originalPrice = widget.chapter == null
//         ? (widget.course.price?.toDouble() ?? 0.0)
//         : (widget.chapter!.chapterPrice?.toDouble() ?? 0.0);
//     final finalPrice = newPrice ?? originalPrice;
//
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: paymentMethodsCubit),
//         BlocProvider.value(value: buyCourseCubit),
//         BlocProvider.value(value: buyChapterCubit),
//         BlocProvider.value(value: promoCodeCubit),
//       ],
//       child: MultiBlocListener(
//         listeners: [
//           BlocListener<BuyCourseCubit, BuyCourseStates>(
//             listener: (context, state) {
//               if (state is BuyCourseSuccessState) {
//                 if (state.paymentLink != null && state.paymentLink!.isNotEmpty) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => WebViewScreen(
//                         url: state.paymentLink!,
//                         title: 'Complete Payment',
//                       ),
//                     ),
//                   );
//                 } else {
//                   showTopSnackBar(
//                     context,
//                     'Course purchased successfully!',
//                     AppColors.green,
//                   );
//                   Navigator.pop(context);
//                 }
//               } else if (state is BuyCourseErrorState) {
//                 showTopSnackBar(
//                   context,
//                   state.message ?? 'Something went wrong, please try again',
//                   AppColors.red,
//                 );
//               }
//             },
//           ),
//           BlocListener<BuyChapterCubit, BuyChapterStates>(
//             listener: (context, state) {
//               if (state is BuyChapterSuccessState) {
//                 if (state.paymentLink != null && state.paymentLink!.isNotEmpty) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => WebViewScreen(
//                         url: state.paymentLink!,
//                         title: 'Complete Payment',
//                       ),
//                     ),
//                   );
//                 } else {
//                   showTopSnackBar(
//                     context,
//                     'Chapter purchased successfully!',
//                     AppColors.green,
//                   );
//                   Navigator.pop(context);
//                 }
//               } else if (state is BuyChapterErrorState) {
//                 showTopSnackBar(
//                   context,
//                   state.error ?? 'Something went wrong, please try again',
//                   AppColors.red,
//                 );
//               }
//             },
//           ),
//           BlocListener<PromoCodeCubit, PromoCodeStates>(
//             listener: (context, state) {
//               if (state is PromoCodeSuccessState) {
//                 setState(() {
//                   newPrice = state.response.newPrice?.toDouble();
//                 });
//                 showTopSnackBar(
//                   context,
//                   'Promo code applied successfully!',
//                   AppColors.green,
//                 );
//               } else if (state is PromoCodeErrorState) {
//                 showTopSnackBar(
//                   context,
//                   'Invalid promo code, please try again',
//                   AppColors.red,
//                 );
//               }
//             },
//           ),
//         ],
//         child: Scaffold(
//           backgroundColor: Colors.grey.shade50,
//           appBar: CustomAppBar(title: "Payment Methods"),
//           body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
//             builder: (context, state) {
//               if (state is PaymentMethodsLoadingState) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(color: AppColors.primary),
//                       SizedBox(height: 12.h),
//                       Text(
//                         'Loading payment methods...',
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               } else if (state is PaymentMethodsSuccessState) {
//                 final methods = [
//                   PaymentMethodDm(
//                     id: 'Wallet',
//                     payment: 'Wallet',
//                     paymentType: 'Wallet',
//                     description: 'Pay using your wallet balance',
//                     logo: '',
//                   ),
//                   PaymentMethodDm(
//                     id: '10',
//                     payment: 'Visacard/ Mastercard',
//                     paymentType: 'integration',
//                     description: 'Pay using Paymob',
//                     logo: 'https://cdn.paymob.com/images/logos/paymob-logo.png',
//                   ),
//                   ...?state.paymentMethodsResponse.paymentMethods,
//                 ];
//                 return Column(
//                   children: [
//                     if (widget.chapter == null) _buildPromoCodeSection(originalPrice, finalPrice),
//                     _buildCompactInfoCard(),
//                     _buildPriceSection(originalPrice, finalPrice),
//                     if (selectedPaymentMethodId != 'Wallet' && selectedPaymentMethodId != '10')
//                       _buildPaymentProofSection(),
//                     Expanded(
//                       child: RefreshIndicator(
//                         color: AppColors.primary,
//                         onRefresh: () async {
//                           paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
//                         },
//                         child: ListView.builder(
//                           padding: EdgeInsets.all(12.w),
//                           itemCount: methods.length,
//                           itemBuilder: (context, index) => _buildPaymentMethodCard(methods[index]),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(12.w),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 4,
//                             offset: Offset(0, -2.h),
//                           ),
//                         ],
//                       ),
//                       child: ElevatedButton(
//                         onPressed: (selectedPaymentMethodId != null &&
//                             (selectedPaymentMethodId == 'Wallet' ||
//                                 selectedPaymentMethodId == '10' ||
//                                 base64String != null))
//                             ? () => _confirmPurchase(originalPrice, finalPrice)
//                             : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: (selectedPaymentMethodId != null &&
//                               (selectedPaymentMethodId == 'Wallet' ||
//                                   selectedPaymentMethodId == '10' ||
//                                   base64String != null))
//                               ? AppColors.primary
//                               : Colors.grey.shade400,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           padding: EdgeInsets.symmetric(vertical: 10.h),
//                           minimumSize: Size(double.infinity, 50.h),
//                         ),
//                         child: Text(
//                           'Confirm Purchase',
//                           style: TextStyle(
//                             color: AppColors.white,
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               } else {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 48.sp,
//                         color: Colors.red.shade400,
//                       ),
//                       SizedBox(height: 12.h),
//                       Text(
//                         'Failed to load payment methods',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       SizedBox(height: 6.h),
//                       Text(
//                         'Please check your connection and try again',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
//                         },
//                         icon: Icon(
//                           Icons.refresh,
//                           color: AppColors.white,
//                           size: 16.sp,
//                         ),
//                         label: Text(
//                           'Retry',
//                           style: TextStyle(
//                             color: AppColors.white,
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 20.w,
//                             vertical: 10.h,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }