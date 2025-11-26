import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.accentRedLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fillDemoCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // App Logo and Branding
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 25.w,
                            height: 25.w,
                            decoration: BoxDecoration(
                              gradient: AppTheme.getPrimaryGradient(),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.getElevatedShadow(),
                            ),
                            child: Icon(
                              Icons.precision_manufacturing_rounded,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Vekariya Brothers',
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimaryLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Karigar Work & Finance Manager',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondaryLight,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 5.h),

                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.inter(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimaryLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Sign in to manage your textile workshop',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    // Email Field with improved UX
                    Container(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: AppTheme.primaryLight,
                            size: 18,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Email Address',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryLight,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Your email address',
                        labelStyle: GoogleFonts.inter(
                          color: AppTheme.textLabelLight,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'example@email.com',
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.textLabelLight,
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                        ),
                        helperText: 'Enter the email address you registered with',
                        helperStyle: GoogleFonts.inter(
                          color: AppTheme.textLabelLight,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(1.2.w),
                          padding: EdgeInsets.all(1.2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            color: AppTheme.primaryLight,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryLight,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.errorLight,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.errorLight,
                            width: 2.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.2.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required to sign in';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Password Field with improved UX
                    Container(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: AppTheme.primaryLight,
                            size: 18,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryLight,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signIn(),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Your password',
                        labelStyle: GoogleFonts.inter(
                          color: AppTheme.textLabelLight,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.textLabelLight,
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                        ),
                        helperText: 'Must be at least 6 characters long',
                        helperStyle: GoogleFonts.inter(
                          color: AppTheme.textLabelLight,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(1.2.w),
                          padding: EdgeInsets.all(1.2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: AppTheme.primaryLight,
                            size: 20,
                          ),
                        ),
                        suffixIcon: Container(
                          margin: EdgeInsets.only(right: 1.w),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondaryLight,
                              size: 22,
                            ),
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryLight,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.errorLight,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.errorLight,
                            width: 2.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.2.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required to sign in';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 4.5.h),

                    // Sign In Button with improved design
                    Container(
                      width: double.infinity,
                      height: 6.5.h,
                      decoration: BoxDecoration(
                        gradient: AppTheme.getPrimaryGradient(),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryLight.withValues(alpha: 0.4),
                            offset: Offset(0, 6),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            offset: Offset(0, 3),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 5.w,
                                    height: 5.w,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Signing in...',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.login_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Sign In to Continue',
                                    style: GoogleFonts.inter(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Demo Credentials Section with improved design
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryLight.withValues(alpha: 0.08),
                            AppTheme.primaryLight.withValues(alpha: 0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryLight.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.getSoftShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: AppTheme.primaryLight,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quick Test Login',
                                      style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimaryLight,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      'Tap any account below to auto-fill',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.5.h),
                          ..._authService
                              .getDemoCredentials()
                              .map(
                                (cred) => GestureDetector(
                                  onTap: () => _fillDemoCredentials(
                                    cred['email']!,
                                    cred['password']!,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(4.w),
                                    margin: EdgeInsets.only(bottom: 1.5.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.primaryLight
                                            .withValues(alpha: 0.15),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryLight
                                              .withValues(alpha: 0.08),
                                          offset: Offset(0, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(2.5.w),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.person_outline_rounded,
                                            color: AppTheme.primaryLight,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${cred['role']} - ${cred['name']}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimaryLight,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                cred['email']!,
                                                style: GoogleFonts.inter(
                                                  fontSize: 11.5.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.textSecondaryLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: AppTheme.primaryLight,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}