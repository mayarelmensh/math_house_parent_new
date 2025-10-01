import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent_new/features/auth/forget_password_screen/forget_password_screen.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cources_payment_method_screen.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/buy_chapter_cubit.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/cubit/courses_cubit.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/select_screen.dart';
import 'package:math_house_parent_new/features/pages/home_screen/tabs/home_tab/home_tab.dart';
import 'package:math_house_parent_new/features/pages/my_courses_screen/cuibt/my_courses_cuibt.dart';
import 'package:math_house_parent_new/features/pages/my_courses_screen/my_courses_screen.dart';
import 'package:math_house_parent_new/features/pages/my_packages_screen/my_packages_screen.dart';
import 'package:math_house_parent_new/features/pages/payment_history/payment_history_screen.dart';
import 'package:math_house_parent_new/features/pages/payment_invoice/payment_invoice_screen.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/buy_package_screen.dart';
import 'package:math_house_parent_new/features/pages/payment_methods/payment_methods_screen.dart';
import 'package:math_house_parent_new/features/pages/profile_screen/profile_screen.dart';
import 'package:math_house_parent_new/features/pages/promo_code_screen/cubit/promo_code_cubit.dart';
import 'package:math_house_parent_new/features/pages/recharge_wallet_screen/recharge_wallet_screen.dart';
import 'package:math_house_parent_new/features/pages/splash_screen/splash_screen.dart';
import 'package:math_house_parent_new/features/pages/students_screen/my_students_screen.dart';
import 'package:math_house_parent_new/features/pages/students_screen/students_screen.dart';
import 'package:math_house_parent_new/features/pages/students_screen/confirmation_screen.dart';
import 'package:math_house_parent_new/features/pages/wallet_history/wallet_history_screen.dart';
import 'package:math_house_parent_new/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent_new/core/di/di.dart';
import 'package:math_house_parent_new/core/utils/app_routes.dart';
import 'package:math_house_parent_new/core/utils/my_bloc_observer.dart';
import 'package:math_house_parent_new/features/auth/login/login_screen.dart';
import 'package:math_house_parent_new/features/auth/register/register_screen.dart';
import 'package:math_house_parent_new/features/pages/courses_screen/buy_courses_screen.dart';
import 'package:math_house_parent_new/features/pages/packages_screen/cubit/packages_cubit.dart';
import 'package:math_house_parent_new/features/pages/packages_screen/packages_screen.dart';
import 'package:math_house_parent_new/features/pages/profile_screen/cubit/profile_screen_cubit.dart';
import 'package:math_house_parent_new/features/pages/students_screen/cubit/students_screen_cubit.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';
import 'package:math_house_parent_new/features/pages/score_sheet_screen/score_sheet_screen.dart';
import 'package:math_house_parent_new/data/models/student_selected.dart';
import 'features/pages/my_packages_screen/cubit/my_package_cubit.dart';
import 'features/pages/notifications_screen/notofications_screen.dart';
import 'features/pages/packages_screen/select_buy_or_my_packages_screen.dart';

// GlobalKey لـ MainScreen
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = MyBlocObserver();
  await SharedPreferenceUtils.init();
  String routeName;
  int initialTabIndex = 0; // افتراضيًا، يفتح على MyStudentsScreen

  var token = SharedPreferenceUtils.getData(key: 'token');
  var studentId = SharedPreferenceUtils.getData(key: 'studentId');
  if (token == null) {
    routeName = AppRoutes.splashScreen;
  } else {
    routeName = AppRoutes.mainScreen;
    if (studentId != null) {
      studentId = SelectedStudent.studentId; // تحديث studentId
      initialTabIndex = 0; // لو فيه studentId، يفتح على HomeTab
    }
  }
  runApp(MyApp(routeName: routeName, initialTabIndex: initialTabIndex));
}

class MyApp extends StatelessWidget {
  final String routeName;
  final int initialTabIndex;

  MyApp({required this.routeName, required this.initialTabIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ProfileCubit>()),
            BlocProvider(
              create: (_) => getIt<GetStudentsCubit>()..getMyStudents(),
            ),
            BlocProvider(create: (_) => getIt<CoursesCubit>()),
            BlocProvider(create: (_) => getIt<PackagesCubit>()),
            BlocProvider(create: (_) => getIt<MyPackageCubit>()),
            BlocProvider(create: (_) => getIt<MyCoursesCubit>()),
            BlocProvider(create: (_) => getIt<BuyChapterCubit>()),
            BlocProvider(create: (_) => getIt<PromoCodeCubit>()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: routeName,
            routes: {
              AppRoutes.loginRoute: (context) => LoginScreen(),
              AppRoutes.registerRoute: (context) => RegisterScreen(),
              AppRoutes.forgetPasswordRoute: (context) =>
                  ForgetPasswordScreen(),
              AppRoutes.getStudent: (context) => StudentsScreen(),
              AppRoutes.mainScreen: (context) =>
                  MainScreen(initialTabIndex: initialTabIndex),
              AppRoutes.confirmationScreen: (context) => ConfirmationScreen(),
              AppRoutes.packagesScreen: (context) => PackagesScreen(),
              AppRoutes.paymentMethodsScreen: (context) => PaymentMethodsScreen(),
              // AppRoutes.myStudentScreen: (context) => MyStudentsScreen(), // تعطيل هذا الـ route
              AppRoutes.buyPackageScreen: (context) => BuyPackageScreen(),
              AppRoutes.paymentHistory: (context) => PaymentHistoryScreen(),
              AppRoutes.paymentInvoice: (context) => PaymentInvoiceScreen(),
              AppRoutes.buyCourse: (context) => BuyCourseScreen(),
              AppRoutes.scoreSheet: (context) => ScoreSheetScreen(),
              AppRoutes.rechargeWallet: (context) => WalletRechargeScreen(),
              AppRoutes.walletHistory: (context) => WalletHistoryScreen(),
              AppRoutes.myPackagesScreen: (context) => MyPackageScreen(),
              AppRoutes.notificationsScreen: (context) => NotificationScreen(),
              AppRoutes.myCourse: (context) => MyCoursesScreen(),
              AppRoutes.splashScreen: (context) => SplashScreen(),
              AppRoutes.paymentsScreen: (context) => const PaymentsScreen(),
              AppRoutes.selectScreen: (context) => SelectScreen(),
              AppRoutes.selectBuyOrMyPackagesScreen: (context) => SelectBuyOrMyPackagesScreen(),
              // AppRoutes.coursesPaymentScreen: (context) => CoursesPaymentMethodsScreen(),
            },
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const MyStudentsScreen(),
    const HomeTab(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      setState(() {
        _selectedIndex = args;
      });
    }
  }

  void changeTab(int index) {
    if (index != 0 && SelectedStudent.studentId == null) {
      // منع التنقل إلى Home أو Profile لو مافيش studentId
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            "Please select a student first",
            style: TextStyle(fontSize: 14.sp, color: AppColors.white),
          ),
          padding: EdgeInsets.all(12.r),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    // تحديث MyPackageCubit لو فيه studentId واختيار HomeTab
    if (index == 1 && SelectedStudent.studentId != null) {
      context.read<MyPackageCubit>().fetchMyPackageData(
        userId: SelectedStudent.studentId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
            bottomLeft:Radius.circular(40.r) ,
            bottomRight: Radius.circular(40.r)
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.25),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: BottomNavigationBar(

          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) => changeTab(index),
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.grey[600],
          selectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.school, _selectedIndex == 0),
              activeIcon: _buildNavActiveIcon(Icons.school),
              label: 'My Students',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home, _selectedIndex == 1),
              activeIcon: _buildNavActiveIcon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, _selectedIndex == 2),
              activeIcon: _buildNavActiveIcon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 24.sp,
        color: isSelected ? AppColors.primaryColor : AppColors.grey[600],
      ),
    );
  }

  Widget _buildNavActiveIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, size: 24.sp, color: AppColors.white),
    );
  }
}
