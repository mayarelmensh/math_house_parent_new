import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart'; // Added for date parsing
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'package:math_house_parent_new/features/pages/payment_history/cubit/payment_history_cubit.dart';
import '../../../core/utils/app_colors.dart';
import '../../../data/models/payment_history_response_dm.dart';
import 'cubit/payment_history_states.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

int? userId = SelectedStudent.studentId; // Made nullable for safety

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: CustomAppBar(title: "Payment History"),
        body: Center(child: Text('User ID is not available')),
      );
    }
    return BlocProvider(
      create: (context) =>
      GetIt.instance<PaymentHistoryCubit>()..getPayments(userId: userId),
      child: const PaymentScreenView(),
    );
  }
}

class PaymentScreenView extends StatefulWidget {
  const PaymentScreenView({Key? key}) : super(key: key);

  @override
  State<PaymentScreenView> createState() => _PaymentScreenViewState();
}

class _PaymentScreenViewState extends State<PaymentScreenView> {
  String selectedFilter = 'all';
  String selectedPaymentMethod = 'all';
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Payment History",
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentHistoryCubit>().refreshPayments(userId: userId);
            },
            icon: Icon(Icons.refresh, color: AppColors.white, size: 28.sp),
          ),
        ],
      ),
      backgroundColor: AppColors.lightGray,
      body: Column(
        children: [
          _buildCompactFilterSection(),
          _buildTotalAmountSection(),
          Expanded(
            child: BlocBuilder<PaymentHistoryCubit, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 5.w,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Loading Payments...',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is PaymentError) {
                  return _buildErrorState(context, state.message);
                } else if (state is PaymentSuccess) {
                  final filteredPayments = _applyFilters(state.payments);
                  if (filteredPayments.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<PaymentHistoryCubit>()
                          .refreshPayments(userId: userId);
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        return _buildPaymentCard(context, payment);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PaymentModel> _applyFilters(List<PaymentModel> payments) {
    List<PaymentModel> filtered = payments;

    if (selectedFilter != 'all') {
      filtered = filtered.where((payment) {
        final status = payment.status.toLowerCase();
        return status == selectedFilter.toLowerCase() ||
            (selectedFilter == 'approved' && payment.isApproved) ||
            (selectedFilter == 'pendding' && status == 'pendding') ||
            (selectedFilter == 'in_progress' && status.contains('progress')) ||
            (selectedFilter == 'rejected' &&
                !payment.isApproved &&
                status != 'pendding');
      }).toList();
    }

    if (selectedPaymentMethod != 'all') {
      filtered = filtered.where((payment) {
        return payment.paymentMethod.toLowerCase() ==
            selectedPaymentMethod.toLowerCase();
      }).toList();
    }

    if (startDate != null && endDate != null) {
      filtered = filtered.where((payment) {
        final paymentDate = _parseDate(payment.date);
        if (paymentDate != null) {
          return !paymentDate.isBefore(startDate!) &&
              !paymentDate.isAfter(endDate!);
        }
        return false; // Exclude if date parsing fails
      }).toList();
    }

    return filtered;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Try multiple date formats
      final formats = [
        'dd/MM/yyyy',
        'yyyy-MM-dd',
        'dd-MM-yyyy',
        'yyyy/MM/dd',
        'MM/dd/yyyy',
      ];
      for (var format in formats) {
        try {
          final formatter = DateFormat(format);
          return formatter.parseStrict(dateStr);
        } catch (e) {
          continue; // Try next format
        }
      }
      // Log parsing failure for debugging
      debugPrint('Failed to parse date: $dateStr');
      return null;
    } catch (e) {
      debugPrint('Error parsing date $dateStr: $e');
      return null;
    }
  }

  double _calculateTotalAmount(List<PaymentModel> payments) {
    double total = 0.0;
    for (var payment in payments) {
      try {
        String priceStr =
        payment.formattedPrice.replaceAll(RegExp(r'[^\d.]'), '');
        total += double.tryParse(priceStr) ?? 0.0;
      } catch (e) {
        continue;
      }
    }
    return total;
  }

  Widget _buildCompactFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusFilterDropdown(),
            SizedBox(width: 12.w),
            _buildPaymentMethodFilterDropdown(),
            SizedBox(width: 12.w),
            _buildDateRangeFilterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return BlocBuilder<PaymentHistoryCubit, PaymentState>(
      builder: (context, state) {
        return DropdownButton<String>(
          value: selectedFilter,
          hint: Text('Status', style: TextStyle(fontSize: 16.sp)),
          items: [
            DropdownMenuItem(value: 'all', child: Text('All', style: TextStyle(fontSize: 15.sp))),
            DropdownMenuItem(value: 'pendding', child: Text('Pending', style: TextStyle(fontSize: 15.sp))),
            DropdownMenuItem(value: 'approved', child: Text('Approved', style: TextStyle(fontSize: 15.sp))),
            DropdownMenuItem(value: 'in_progress', child: Text('In Progress', style: TextStyle(fontSize: 15.sp))),
            DropdownMenuItem(value: 'rejected', child: Text('Rejected', style: TextStyle(fontSize: 15.sp))),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedFilter = value;
              });
              context.read<PaymentHistoryCubit>().filterPaymentsByStatus(value);
            }
          },
          style: TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          underline: Container(
            height: 1.5.h,
            color: AppColors.primary.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodFilterDropdown() {
    return BlocBuilder<PaymentHistoryCubit, PaymentState>(
      builder: (context, state) {
        List<String> paymentMethods = ['all'];
        if (state is PaymentSuccess) {
          paymentMethods = state.availablePaymentMethods;
        }
        return DropdownButton<String>(
          value: selectedPaymentMethod,
          hint: Text('Payment Method', style: TextStyle(fontSize: 16.sp)),
          items: paymentMethods
              .map((method) => DropdownMenuItem(
            value: method,
            child: Text(
              _formatMethodName(method),
              style: TextStyle(fontSize: 15.sp),
            ),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedPaymentMethod = value;
              });
            }
          },
          style: TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          underline: Container(
            height: 1.5.h,
            color: AppColors.primary.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget _buildDateRangeFilterButton() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => _selectDateRange(context),
          icon: Icon(Icons.calendar_month, size: 22.sp),
          label: Text(
            startDate == null ? 'Date Range' : 'Change Range',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary, width: 1.5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
        ),
        if (startDate != null && endDate != null) ...[
          SizedBox(width: 12.w),
          InkWell(
            onTap: () {
              setState(() {
                startDate = null;
                endDate = null;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.clear, color: AppColors.red, size: 20.sp),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTotalAmountSection() {
    return BlocBuilder<PaymentHistoryCubit, PaymentState>(
      builder: (context, state) {
        if (state is PaymentSuccess) {
          final filteredPayments = _applyFilters(state.payments);
          final totalAmount = _calculateTotalAmount(filteredPayments);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ${totalAmount.toStringAsFixed(2)} \$',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (filteredPayments.isNotEmpty)
                      Text(
                        '${filteredPayments.length} payment${filteredPayments.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.white,
                  size: 28.sp,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  String _formatMethodName(String method) {
    if (method == 'all') return 'All';
    return method
        .split(' ')
        .map((word) => word.isEmpty
        ? ''
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDateDisplay(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildPaymentCard(BuildContext context, PaymentModel payment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3.h),
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.paymentInvoice,
            arguments: {'paymentId': payment.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${payment.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.darkGray,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: payment.isApproved
                        ? AppColors.green.withOpacity(0.1)
                        : AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: payment.isApproved ? AppColors.green : AppColors.red,
                      width: 1.5.w,
                    ),
                  ),
                  child: Text(
                    payment.status,
                    style: TextStyle(
                      color: payment.isApproved ? AppColors.green : AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: payment.date,
                ),
                _buildInfoItem(
                  icon: Icons.payment,
                  label: 'Method',
                  value: payment.paymentMethod,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.monetization_on,
                  label: 'Amount',
                  value: payment.formattedPrice,
                  valueColor: AppColors.green,
                ),
                _buildInfoItem(
                  icon: Icons.business_center,
                  label: 'Service',
                  value: payment.service,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: valueColor ?? AppColors.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 80.sp, color: AppColors.grey.withOpacity(0.5)),
            SizedBox(height: 20.h),
            Text(
              'No Payments Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'No payments match your filter criteria.\nTry adjusting your filters.',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedFilter = 'all';
                  selectedPaymentMethod = 'all';
                  startDate = null;
                  endDate = null;
                });
              },
              icon: Icon(Icons.refresh, size: 22.sp),
              label: Text(
                'Clear Filters',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.sp, color: AppColors.red),
            SizedBox(height: 20.h),
            Text(
              'Error Loading Payments',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PaymentHistoryCubit>().getPayments(userId: userId);
              },
              icon: Icon(Icons.refresh, size: 22.sp),
              label: Text(
                'Try Again',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}