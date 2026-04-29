import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'services/notification_service.dart';
import 'models/crop_model.dart';
import 'models/mandi_model.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/crop/crop_detail_screen.dart';
import 'screens/crop/crop_list_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/mandi/mandi_detail_screen.dart';
import 'screens/mandi/mandi_list_screen.dart';
import 'screens/news/news_detail_screen.dart';
import 'screens/news/news_screen.dart';
import 'screens/profile/about_app_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/tools/market_overview_screen.dart';
import 'screens/tools/tools_screen.dart';
import 'screens/tools/weather_screen.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String otpRoute = '/otp';
  static const String resetPasswordRoute = '/reset-password';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String cropListRoute = '/crop-list';
  static const String cropDetailRoute = '/crop-detail';
  static const String mandiListRoute = '/mandi-list';
  static const String mandiDetailRoute = '/mandi-detail';
  static const String analyticsRoute = '/analytics';
  static const String toolsRoute = '/tools';
  static const String weatherRoute = '/weather';
  static const String marketOverviewRoute = '/market-overview';
  static const String newsRoute = '/news';
  static const String newsDetailRoute = '/news-detail';
  static const String notificationsRoute = '/notifications';
  static const String aboutRoute = '/about';
  static const String profileRoute = '/profile';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kSecondaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusColor: kSecondaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            borderSide: const BorderSide(color: kTextLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            borderSide: const BorderSide(color: kSecondaryColor, width: 2),
          ),
        ),
      ),
      initialRoute: splashRoute,
      routes: {
        splashRoute: (context) => const SplashScreen(),
        loginRoute: (context) => const LoginScreen(),
        forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
        otpRoute: (context) => const OtpVerificationScreen(),
        resetPasswordRoute: (context) => const ResetPasswordScreen(),
        signupRoute: (context) => const SignupScreen(),
        homeRoute: (context) => const HomeScreen(),
        cropListRoute: (context) => const CropListScreen(),
        mandiListRoute: (context) => const MandiListScreen(),
        analyticsRoute: (context) => const AnalyticsScreen(),
        toolsRoute: (context) => const ToolsScreen(),
        weatherRoute: (context) => const WeatherScreen(),
        marketOverviewRoute: (context) => const MarketOverviewScreen(),
        newsRoute: (context) => const NewsScreen(),
        notificationsRoute: (context) => const NotificationsScreen(),
        aboutRoute: (context) => const AboutAppScreen(),
        profileRoute: (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == cropDetailRoute) {
          final Object? args = settings.arguments;
          if (args is CropModel) {
            return MaterialPageRoute(
              builder: (_) => CropDetailScreen(crop: args),
              settings: settings,
            );
          }
        }

        if (settings.name == mandiDetailRoute) {
          final Object? args = settings.arguments;
          if (args is MandiModel) {
            return MaterialPageRoute(
              builder: (_) => MandiDetailScreen(mandi: args),
              settings: settings,
            );
          }
        }

        if (settings.name == newsDetailRoute) {
          final Object? args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => NewsDetailScreen(news: args),
              settings: settings,
            );
          }
        }

        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: const RouteSettings(name: splashRoute),
        );
      },
    );
  }
}
