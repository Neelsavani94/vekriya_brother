import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './presentation/auth/login_screen.dart';
import './presentation/main_dashboard/main_dashboard.dart';
import './services/auth_service.dart';
import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(VekariyaBrothersApp());
}

class VekariyaBrothersApp extends StatelessWidget {
  VekariyaBrothersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            title: 'Vekariya Brothers - Karigar Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: AuthWrapper(),
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.mainDashboard,
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final _authService = AuthService();

  AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      gradient: AppTheme.getPrimaryGradient(),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.getElevatedShadow(),
                    ),
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Vekariya Brothers',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimaryLight,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Initializing...',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  CircularProgressIndicator(
                    color: AppTheme.primaryLight,
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user is authenticated
        final user = _authService.getCurrentUser();

        if (user != null) {
          // User is signed in, show main dashboard
          return MainDashboard();
        } else {
          // User is not signed in, show login screen
          return LoginScreen();
        }
      },
    );
  }
}
