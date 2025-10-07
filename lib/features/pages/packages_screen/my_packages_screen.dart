// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../core/utils/app_colors.dart';
// import '../../../data/models/student_selected.dart';
// import '../my_packages_screen/cubit/my_package_cubit.dart';
// import '../my_packages_screen/cubit/my_package_states.dart';
//
// class MyPackagesScreen extends StatelessWidget {
//   const MyPackagesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MyPackageCubit, MyPackageState>(
//       builder: (context, state) {
//         if (state is MyPackageInitial) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Preparing your packages...'),
//               SizedBox(height: 2.h),
//               Text(
//                 'You must check if you have selected your student.',
//                 style: TextStyle(
//                   color: AppColors.darkGray,
//                   fontSize: 14.sp,
//                 ),
//               ),
//             ],
//           );
//         } else if (state is MyPackageLoading) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: AppColors.primary,
//               strokeWidth: 4.w,
//             ),
//           );
//         } else if (state is MyPackageLoaded) {
//           if (state.package.exams == 0 &&
//               state.package.questions == 0 &&
//               state.package.lives == 0) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'No Active Packages',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.primaryColor,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   'You don\'t have any active packages.',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: AppColors.grey,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 TextButton(
//                   onPressed: () {
//                     context.read<MyPackageCubit>().fetchMyPackageData(
//                       userId: SelectedStudent.studentId,
//                     );
//                   },
//                   child: Text(
//                     'Refresh',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildBulletPoint(
//                 icon: Icons.quiz,
//                 label: 'Exams',
//                 value: '${state.package.exams ?? 0}',
//                 color: AppColors.primary,
//               ),
//               SizedBox(height: 8.h),
//               _buildBulletPoint(
//                 icon: Icons.question_answer,
//                 label: 'Questions',
//                 value: '${state.package.questions ?? 0}',
//                 color: AppColors.blue,
//               ),
//               SizedBox(height: 8.h),
//               _buildBulletPoint(
//                 icon: Icons.live_tv,
//                 label: 'Lives',
//                 value: '${state.package.lives ?? 0}',
//                 color: AppColors.green,
//               ),
//             ],
//           );
//         } else if (state is MyPackageError) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Error Loading Packages',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.red,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       context.read<MyPackageCubit>().fetchMyPackageData(
//                         userId: SelectedStudent.studentId,
//                       );
//                     },
//                     child: Text(
//                       'Try Again',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],),
//               SizedBox(height: 3.h),
//               Text(
//                 'You must check if you have selected your student.',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   color: AppColors.black,
//                 ),
//               ),
//               SizedBox(height: 2.h),
//
//             ],
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   Widget _buildBulletPoint({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Icon(Icons.circle, size: 8.sp, color: color),
//         SizedBox(width: 8.w),
//         Icon(icon, size: 20.sp, color: color),
//         SizedBox(width: 8.w),
//         Text(
//           '$label: ',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//             color: AppColors.darkGray,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
