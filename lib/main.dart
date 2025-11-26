import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './presentation/auth/login_screen.dart';
import './presentation/home/home_screen.dart';
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

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surfaceLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
            title: 'Vekariya Brothers',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: AuthWrapper(),
            routes: AppRoutes.routes,
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
          return _buildLoadingScreen();
        }

        // Check if user is authenticated
        final user = _authService.getCurrentUser();

        if (user != null) {
          // User is signed in, show home with bottom navigation
          return HomeScreen();
        } else {
          // User is not signed in, show login screen
          return LoginScreen();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.getPrimaryGradient(),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.getElevatedShadow(
                  color: AppTheme.primaryLight,
                  opacity: 0.3,
                ),
              ),
              child: Center(
                child: Text(
                  'VB',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Vekariya Brothers',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Karigar Management',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
