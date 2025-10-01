import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/features/pages/wallet_history/cubit/wallet_history_cubit.dart';
import 'package:math_house_parent_new/features/pages/wallet_history/cubit/wallet_history_states.dart';
import '../../../data/models/wallet_history.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  final WalletHistoryCubit walletCubit = getIt<WalletHistoryCubit>();
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      walletCubit..fetchWalletData(userId: SelectedStudent.studentId),
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(
          title: "Wallet History",
          actions: [
            IconButton(
              onPressed: () {
                context
                    .read<WalletHistoryCubit>()
                    .fetchWalletData(userId: SelectedStudent.studentId);
              },
              icon: Icon(Icons.refresh, color: AppColors.white, size: 24.sp),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: BlocBuilder<WalletHistoryCubit, WalletState>(
                builder: (context, state) {
                  if (state is WalletInitial) {
                    return Center(
                      child: Text(
                        'Initializing...',
                        style: TextStyle(
                            color: AppColors.darkGray, fontSize: 16.sp),
                      ),
                    );
                  } else if (state is WalletLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 4.w,
                      ),
                    );
                  } else if (state is WalletLoaded) {
                    return _buildWalletContent(context, state.response);
                  } else if (state is WalletError) {
                    return _buildErrorState(context, state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Filter: ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('pending', 'Pending'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('approve', 'Approved'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('rejected', 'Rejected'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('faild', 'Faild'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
        context.read<WalletHistoryCubit>().filterWalletHistory(value);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.lightGray,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.grey,
        width: 1.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    );
  }

  Widget _buildWalletContent(BuildContext context, WalletResponse response) {
    final filteredHistory = selectedFilter == 'all'
        ? response.wallet_history
        : response.wallet_history
        ?.where((history) =>
    history.state?.toLowerCase() == selectedFilter.toLowerCase())
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await context
            .read<WalletHistoryCubit>()
            .fetchWalletData(userId: SelectedStudent.studentId);
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
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
                  Text(
                    '${response.money ?? 0} EGP',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Wallet History',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 12.h),
            if (filteredHistory != null && filteredHistory.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final history = filteredHistory[index];
                  return Card(
                    color: AppColors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      title: Text(
                        'Amount: ${history.wallet ?? 0} EGP',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Text(
                            'Date: ${history.date ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.gray,
                            ),
                          ),
                          Text(
                            'State: ${history.state ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: history.state?.toLowerCase() == 'approve'
                                  ? AppColors.green
                                  : history.state?.toLowerCase() == 'pending'
                                  ? AppColors.yellow
                                  : AppColors.red,
                            ),
                          ),
                          if (history.payment_method != null)
                            Text(
                              'Payment Method: ${history.payment_method}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.gray,
                              ),
                            ),
                          if (history.rejected_reason != null)
                            Text(
                              'Rejected Reason: ${history.rejected_reason}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.notAttendColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'No wallet history available',
                  style: TextStyle(fontSize: 16.sp, color: AppColors.gray),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70.sp, color: AppColors.red),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Wallet History',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context
                  .read<WalletHistoryCubit>()
                  .fetchWalletData(userId: SelectedStudent.studentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}