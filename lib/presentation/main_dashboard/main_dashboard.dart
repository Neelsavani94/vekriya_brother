import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/daily_work_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/karigar_service.dart';
import '../../services/upad_service.dart';
import './widgets/activity_item_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_action_button_widget.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Services
  final DashboardService _dashboardService = DashboardService();
  final KarigarService _karigarService = KarigarService();
  final DailyWorkService _dailyWorkService = DailyWorkService();
  final UpadService _upadService = UpadService();

  // Data state
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  String? _error;
  DateTime _lastRefresh = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();

    // Auto-refresh every 30 seconds
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) {
        _refreshDashboard();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load dashboard statistics
      final stats = await _dashboardService.getDashboardStatistics();

      // Load recent activities (combining different activity types)
      final recentWorkEntries =
          await _dailyWorkService.getRecentWorkEntries(limit: 3);
      final recentPayments = await _upadService.getRecentUpadPayments(limit: 3);

      // Process activities into a unified format
      final activities = <Map<String, dynamic>>[];

      for (var work in recentWorkEntries) {
        activities.add({
          'type': 'work_entry',
          'title':
              '${work['karigars']['full_name']} completed ${work['pieces_completed']} ${work['work_type']}',
          'subtitle':
              'Earned ₹${work['total_amount']?.toStringAsFixed(0) ?? '0'}',
          'time': _formatTimeAgo(DateTime.parse(work['created_at'])),
          'icon': 'work',
          'color': AppTheme.primaryLight,
        });
      }

      for (var payment in recentPayments) {
        activities.add({
          'type': 'payment',
          'title':
              '${payment['karigars']['full_name']} received ${payment['payment_type']}',
          'subtitle':
              '₹${payment['amount']?.toStringAsFixed(0) ?? '0'} - ${payment['reason'] ?? 'Payment'}',
          'time': _formatTimeAgo(DateTime.parse(payment['created_at'])),
          'icon': 'account_balance_wallet',
          'color': AppTheme.successLight,
        });
      }

      // Sort activities by time (most recent first)
      activities.sort((a, b) => b['time'].compareTo(a['time']));

      setState(() {
        _dashboardStats = stats;
        _recentActivities = activities.take(5).toList();
        _isLoading = false;
        _lastRefresh = DateTime.now();
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load dashboard: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
    _animationController.reset();
    _animationController.forward();
  }

  void _navigateToScreen(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: AppTheme.errorLight.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 60,
                            color: AppTheme.errorLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Unable to Load Dashboard',
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimaryLight,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'We couldn\'t fetch your dashboard data. Please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryLight,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 60.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryLight,
                                AppTheme.primaryVariantLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryLight.withValues(alpha: 0.4),
                                offset: Offset(0, 6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _loadDashboardData,
                            icon: Icon(Icons.refresh_rounded, color: Colors.white),
                            label: Text(
                              'Try Again',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshDashboard,
                  color: AppTheme.primaryLight,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SafeArea(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),

                              // Greeting Header
                              GreetingHeaderWidget(
                                businessOwnerName: 'Vekariya Brothers',
                                currentDate: _formatDate(_lastRefresh),
                              ),

                              SizedBox(height: 3.h),

                              // Metrics Cards Section
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  children: [
                                    // First Row - Karigars and Daily Work
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Total Karigars',
                                            value: (_dashboardStats[
                                                        'total_karigars'] ??
                                                    0)
                                                .toString(),
                                            iconName: 'people',
                                            statusColor: AppTheme.primaryLight,
                                            subtitle:
                                                '${(_dashboardStats['active_karigars'] ?? 0)} active',
                                            onTap: () => _navigateToScreen(
                                                '/karigar-list-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Today\'s Work',
                                            value: (_dashboardStats[
                                                        'todays_work_entries'] ??
                                                    0)
                                                .toString(),
                                            iconName: 'assignment',
                                            statusColor: AppTheme.warningLight,
                                            subtitle:
                                                '${(_dashboardStats['todays_pieces'] ?? 0)} pieces',
                                            onTap: () => _navigateToScreen(
                                                '/daily-work-entry-screen'),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 3.h),

                                    // Second Row - Earnings and Payments
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Monthly Earnings',
                                            value:
                                                '₹${(_dashboardStats['monthly_earnings'] ?? 0).toStringAsFixed(0)}',
                                            iconName: 'trending_up',
                                            statusColor: AppTheme.successLight,
                                            subtitle: 'This month',
                                            onTap: () => _navigateToScreen(
                                                '/reports-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Upad Payments',
                                            value:
                                                '₹${(_dashboardStats['monthly_upad'] ?? 0).toStringAsFixed(0)}',
                                            iconName: 'account_balance_wallet',
                                            statusColor: AppTheme.primaryLight,
                                            subtitle: 'This month',
                                            onTap: () => _navigateToScreen(
                                                '/upad-entry-screen'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // Quick Actions Section with improved design
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(1.5.w),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.flash_on_rounded,
                                            color: AppTheme.primaryLight,
                                            size: 22,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Quick Actions',
                                          style: GoogleFonts.inter(
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimaryLight,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Tap to quickly access common tasks',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: QuickActionButtonWidget(
                                            label: 'Add Karigar',
                                            iconName: 'person_add',
                                            backgroundColor: AppTheme.primaryLight,
                                            iconColor: Colors.white,
                                            onPressed: () => _navigateToScreen(
                                                '/add-edit-karigar-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: QuickActionButtonWidget(
                                            label: 'Daily Work',
                                            iconName: 'assignment_add',
                                            backgroundColor: AppTheme.warningLight,
                                            iconColor: Colors.white,
                                            onPressed: () => _navigateToScreen(
                                                '/daily-work-entry-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: QuickActionButtonWidget(
                                            label: 'Add Upad',
                                            iconName: 'payment',
                                            backgroundColor: AppTheme.successLight,
                                            iconColor: Colors.white,
                                            onPressed: () => _navigateToScreen(
                                                '/upad-entry-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: QuickActionButtonWidget(
                                            label: 'Reports',
                                            iconName: 'assessment',
                                            backgroundColor: AppTheme.primaryLight,
                                            iconColor: Colors.white,
                                            onPressed: () => _navigateToScreen(
                                                '/reports-screen'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // Recent Activities Section with improved design
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(1.5.w),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.history_rounded,
                                                color: AppTheme.primaryLight,
                                                size: 22,
                                              ),
                                            ),
                                            SizedBox(width: 3.w),
                                            Text(
                                              'Recent Activities',
                                              style: GoogleFonts.inter(
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.textPrimaryLight,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _navigateToScreen(
                                              '/activity-logs-screen'),
                                          icon: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                            color: AppTheme.primaryLight,
                                          ),
                                          label: Text(
                                            'View All',
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryLight,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Latest work entries and payments',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    if (_recentActivities.isEmpty)
                                      Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightTheme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: AppTheme.getSoftShadow(),
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.history_rounded,
                                                size: 48,
                                                color:
                                                    AppTheme.textSecondaryLight,
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                'No recent activities',
                                                style: AppTheme.lightTheme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: AppTheme
                                                      .textSecondaryLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      ...List.generate(
                                        _recentActivities.length,
                                        (index) {
                                          final activity =
                                              _recentActivities[index];
                                          return AnimatedContainer(
                                            duration: Duration(
                                                milliseconds:
                                                    300 + (index * 100)),
                                            curve: Curves.easeOutBack,
                                            child: ActivityItemWidget(
                                              title: activity['title'] ?? '',
                                              description: activity['subtitle'] ?? '',
                                              timestamp: activity['time'] ?? '',
                                              iconName: activity['icon'] ?? 'info',
                                              statusColor: activity['color'] ?? AppTheme.primaryLight,
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Map<String, dynamic>? _getTrend(String key) {
    // Return trend data if available in dashboard stats
    final trends = _dashboardStats['trends'] as Map<String, dynamic>?;
    return trends?[key];
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}