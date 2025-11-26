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

  int _selectedBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryLight,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Loading Dashboard...',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
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
                            size: 80,
                            color: AppTheme.errorLight,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Oops! Something went wrong',
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'We couldn\'t load your dashboard. Please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton.icon(
                            onPressed: _loadDashboardData,
                            icon: Icon(Icons.refresh_rounded, size: 24),
                            label: Text(
                              'Try Again',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
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

                              // Enhanced Greeting Header with Help Button
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome Back! 👋',
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondaryLight,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            'Vekariya Brothers',
                                            style: GoogleFonts.inter(
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimaryLight,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          SizedBox(height: 0.3.h),
                                          Text(
                                            _formatDate(_lastRefresh),
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textLabelLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Help Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _showHelpDialog(context);
                                        },
                                        icon: Icon(
                                          Icons.help_outline_rounded,
                                          color: AppTheme.primaryLight,
                                          size: 28,
                                        ),
                                        tooltip: 'Need Help?',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Stats Overview Section with Better Visual Hierarchy
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '📊 Today\'s Overview',
                                      style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    // First Row - Karigars and Daily Work
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Workers',
                                            value: (_dashboardStats[
                                                        'total_karigars'] ??
                                                    0)
                                                .toString(),
                                            iconName: 'people',
                                            statusColor: AppTheme.primaryLight,
                                            subtitle:
                                                '${(_dashboardStats['active_karigars'] ?? 0)} active now',
                                            onTap: () => _navigateToScreen(
                                                '/karigar-list-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
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
                                                '${(_dashboardStats['todays_pieces'] ?? 0)} pieces done',
                                            onTap: () => _navigateToScreen(
                                                '/daily-work-entry-screen'),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 2.h),

                                    // Second Row - Earnings and Payments
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'This Month',
                                            value:
                                                '₹${(_dashboardStats['monthly_earnings'] ?? 0).toStringAsFixed(0)}',
                                            iconName: 'trending_up',
                                            statusColor: AppTheme.successLight,
                                            subtitle: 'Total earnings',
                                            onTap: () => _navigateToScreen(
                                                '/reports-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Advances',
                                            value:
                                                '₹${(_dashboardStats['monthly_upad'] ?? 0).toStringAsFixed(0)}',
                                            iconName: 'account_balance_wallet',
                                            statusColor: AppTheme.accentRedLight,
                                            subtitle: 'Paid out',
                                            onTap: () => _navigateToScreen(
                                                '/upad-entry-screen'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Enhanced Quick Actions Section
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '⚡ Quick Actions',
                                      style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    // Grid Layout for Better Touch Targets
                                    GridView.count(
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 3.w,
                                      mainAxisSpacing: 2.h,
                                      childAspectRatio: 1.4,
                                      children: [
                                        _buildEnhancedQuickActionCard(
                                          'Add Worker',
                                          Icons.person_add_rounded,
                                          AppTheme.primaryLight,
                                          'Register new worker',
                                          () => _navigateToScreen('/add-edit-karigar-screen'),
                                        ),
                                        _buildEnhancedQuickActionCard(
                                          'Daily Work',
                                          Icons.assignment_add_rounded,
                                          AppTheme.warningLight,
                                          'Record today\'s work',
                                          () => _navigateToScreen('/daily-work-entry-screen'),
                                        ),
                                        _buildEnhancedQuickActionCard(
                                          'Pay Advance',
                                          Icons.payment_rounded,
                                          AppTheme.successLight,
                                          'Give advance payment',
                                          () => _navigateToScreen('/upad-entry-screen'),
                                        ),
                                        _buildEnhancedQuickActionCard(
                                          'View Workers',
                                          Icons.groups_rounded,
                                          AppTheme.accentGreenLight,
                                          'See all workers',
                                          () => _navigateToScreen('/karigar-list-screen'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Enhanced Recent Activities Section
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '📝 Recent Activity',
                                          style: GoogleFonts.inter(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimaryLight,
                                          ),
                                        ),
                                        if (_recentActivities.isNotEmpty)
                                          TextButton(
                                            onPressed: () => _navigateToScreen(
                                                '/activity-logs-screen'),
                                            child: Text(
                                              'See All',
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.primaryLight,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 1.5.h),
                                    if (_recentActivities.isEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightTheme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: AppTheme.getSoftShadow(),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.history_rounded,
                                                size: 48,
                                                color: AppTheme.primaryLight,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              'No Activity Yet',
                                              style: GoogleFonts.inter(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimaryLight,
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              'Start by adding workers or recording daily work',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.textSecondaryLight,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
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

                              SizedBox(height: 12.h), // Extra space for bottom nav
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      // Bottom Navigation Bar for Easy Access
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _selectedBottomNavIndex == 0,
                  onTap: () {
                    setState(() => _selectedBottomNavIndex = 0);
                  },
                ),
                _buildBottomNavItem(
                  icon: Icons.groups_rounded,
                  label: 'Workers',
                  isSelected: _selectedBottomNavIndex == 1,
                  onTap: () {
                    setState(() => _selectedBottomNavIndex = 1);
                    _navigateToScreen('/karigar-list-screen');
                  },
                ),
                // Center FAB-style button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.getPrimaryGradient(),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryLight.withValues(alpha: 0.4),
                        offset: Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToScreen('/daily-work-entry-screen'),
                      customBorder: CircleBorder(),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomNavItem(
                  icon: Icons.payment_rounded,
                  label: 'Advance',
                  isSelected: _selectedBottomNavIndex == 2,
                  onTap: () {
                    setState(() => _selectedBottomNavIndex = 2);
                    _navigateToScreen('/upad-entry-screen');
                  },
                ),
                _buildBottomNavItem(
                  icon: Icons.assessment_rounded,
                  label: 'Reports',
                  isSelected: _selectedBottomNavIndex == 3,
                  onTap: () {
                    setState(() => _selectedBottomNavIndex = 3);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reports feature coming soon!'),
                        backgroundColor: AppTheme.primaryLight,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 26,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryLight
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedQuickActionCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                offset: Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryLight,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_rounded, color: AppTheme.primaryLight, size: 28),
            SizedBox(width: 2.w),
            Text(
              'How to Use',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                '1. Add Workers',
                'Tap "Add Worker" to register new workers with their details',
                Icons.person_add_rounded,
              ),
              SizedBox(height: 2.h),
              _buildHelpItem(
                '2. Record Daily Work',
                'Use "Daily Work" to track pieces completed each day',
                Icons.assignment_add_rounded,
              ),
              SizedBox(height: 2.h),
              _buildHelpItem(
                '3. Pay Advances',
                'Give advance payments to workers using "Pay Advance"',
                Icons.payment_rounded,
              ),
              SizedBox(height: 2.h),
              _buildHelpItem(
                '4. View Reports',
                'Check earnings and worker performance in reports',
                Icons.assessment_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryLight,
            size: 24,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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