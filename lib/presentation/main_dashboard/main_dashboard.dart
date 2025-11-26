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
        final createdAt = DateTime.parse(work['created_at']);
        activities.add({
          'type': 'work_entry',
          'title':
              '${work['karigars']['full_name']} completed ${work['pieces_completed']} ${work['work_type']}',
          'subtitle':
              'Earned ₹${work['total_amount']?.toStringAsFixed(0) ?? '0'}',
          'time': _formatTimeAgo(createdAt),
          'rawTime': createdAt,
          'icon': 'work',
          'color': AppTheme.primaryLight,
        });
      }

      for (var payment in recentPayments) {
        final createdAt = DateTime.parse(payment['created_at']);
        activities.add({
          'type': 'payment',
          'title':
              '${payment['karigars']['full_name']} received ${payment['payment_type']}',
          'subtitle':
              '₹${payment['amount']?.toStringAsFixed(0) ?? '0'} - ${payment['reason'] ?? 'Payment'}',
          'time': _formatTimeAgo(createdAt),
          'rawTime': createdAt,
          'icon': 'account_balance_wallet',
          'color': AppTheme.successLight,
        });
      }

      // Sort activities by time (most recent first)
      activities.sort((a, b) {
        final aTime = a['rawTime'] as DateTime?;
        final bTime = b['rawTime'] as DateTime?;
        if (aTime == null || bTime == null) {
          return (b['time'] ?? '').compareTo(a['time'] ?? '');
        }
        return bTime.compareTo(aTime);
      });

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

  void _showInfoMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: AppTheme.errorLight,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Error Loading Dashboard',
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: Text('Retry'),
                      ),
                    ],
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

                              // Quick Actions Section
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quick Actions',
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
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
                                    SizedBox(height: 1.8.h),
                                    _buildQuickActionHelper(),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3.h),

                              _buildFriendlyGuideSection(),

                              SizedBox(height: 3.h),

                              _buildSupportSection(),

                              SizedBox(height: 4.h),

                              // Recent Activities Section
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Recent Activities',
                                          style: GoogleFonts.inter(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimaryLight,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _navigateToScreen(
                                              '/activity-logs-screen'),
                                          child: Text(
                                            'View All',
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.primaryLight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.7.h),
                                    Text(
                                      'Latest updates from daily work and upad entries. Pull down anywhere to refresh.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 1.2.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 1.2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppTheme.primaryLight
                                              .withValues(alpha: 0.08),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 16,
                                            color: AppTheme.primaryLight,
                                          ),
                                          SizedBox(width: 1.5.w),
                                          Text(
                                            'Last refresh ${_formatTimeAgo(_lastRefresh)}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimaryLight,
                                            ),
                                          ),
                                        ],
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

  Widget _buildQuickActionHelper() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: AppTheme.primaryLight,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Start from the left and move across. Each card explains every field in simple language so any teammate can finish in under a minute.',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryLight,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendlyGuideSection() {
    final steps = [
      {
        'title': 'Add your karigars',
        'description':
            'Store phone numbers, per-piece rate and IDs once. Future forms will auto-fill everything for you.',
        'helper':
            'Keeping details ready avoids manual notebooks and saves payroll time.',
        'icon': 'person_add',
        'actionLabel': 'Add karigar',
        'route': '/add-edit-karigar-screen',
        'color': AppTheme.primaryLight,
      },
      {
        'title': 'Record daily work',
        'description':
            'Note pieces completed and we calculate earnings instantly so workers see transparent payouts.',
        'helper': 'Only basic numbers needed. We guide you line by line.',
        'icon': 'assignment',
        'actionLabel': 'Add daily work',
        'route': '/daily-work-entry-screen',
        'color': AppTheme.warningLight,
      },
      {
        'title': 'Track upad payments',
        'description':
            'Whenever you give advance cash, note it here to keep deductions crystal clear for the worker.',
        'helper':
            'Tap add upad, select karigar and enter amount. Proof photos are optional.',
        'icon': 'account_balance_wallet',
        'actionLabel': 'Add upad entry',
        'route': '/upad-entry-screen',
        'color': AppTheme.successLight,
      },
      {
        'title': 'View reports (coming soon)',
        'description':
            'Monthly summaries with pending upad and productivity charts will appear here.',
        'helper': 'We are polishing this area for you.',
        'icon': 'assessment',
        'actionLabel': 'Notify me',
        'comingSoon': true,
        'color': AppTheme.secondaryLight,
        'comingSoonMessage':
            'Reports area is being finalized. We will notify you shortly.',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.getSoftShadow(),
          border: Border.all(
            color: AppTheme.primaryLight.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.self_improvement_rounded,
                    color: AppTheme.secondaryLight,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simple step-by-step guide',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        'Designed for owners who prefer plain language. Follow the cards below to keep work organised.',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondaryLight,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...List.generate(
              steps.length,
              (index) => _buildGuideStepTile(
                step: steps[index],
                index: index,
                isLast: index == steps.length - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStepTile({
    required Map<String, dynamic> step,
    required int index,
    required bool isLast,
  }) {
    final Color accent = step['color'] as Color? ?? AppTheme.primaryLight;
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 1.6.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Step ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  step['title'] as String? ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: step['icon'] as String? ?? 'check_circle',
                color: accent,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            step['description'] as String? ?? '',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryLight,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: accent,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  step['helper'] as String? ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          TextButton.icon(
            onPressed: () {
              final bool comingSoon = step['comingSoon'] == true;
              if (comingSoon) {
                _showInfoMessage(
                  step['comingSoonMessage'] as String? ??
                      'This flow will be ready soon.',
                );
              } else {
                final route = step['route'] as String?;
                if (route != null) {
                  _navigateToScreen(route);
                } else {
                  _showInfoMessage(
                    step['infoMessage'] as String? ??
                        'Action handled successfully.',
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            ),
            icon: Icon(
              step['comingSoon'] == true
                  ? Icons.lock_clock_rounded
                  : Icons.play_arrow_rounded,
              size: 18,
            ),
            label: Text(
              step['actionLabel'] as String? ?? 'Open',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    final supportOptions = [
      {
        'label': 'Call support',
        'description': 'Talk to our team in Gujarati or Hindi for live help.',
        'icon': 'call',
        'onTap': () => _showInfoMessage(
              'Phone support number will be shared after onboarding.',
            ),
      },
      {
        'label': 'WhatsApp guide',
        'description': 'Receive a 2-minute video demo on your phone.',
        'icon': 'chat',
        'onTap': () => _showInfoMessage(
              'We will send the WhatsApp quick-start clip soon.',
            ),
      },
      {
        'label': 'Book onsite training',
        'description': 'Schedule a visit for your supervisors.',
        'icon': 'event',
        'onTap': () => _showInfoMessage(
              'Training calendar will open after we confirm your slot.',
            ),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryVariantLight,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.getElevatedShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need a hand?',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 0.4.h),
            Text(
              'Non-technical owners can tap below to get quick help or a friendly walkthrough.',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
            SizedBox(height: 2.h),
            ...supportOptions.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(top: entry.key == 0 ? 0 : 1.2.h),
                child: _buildSupportButton(
                  label: entry.value['label'] as String,
                  description: entry.value['description'] as String,
                  iconName: entry.value['icon'] as String,
                  onTap: entry.value['onTap'] as VoidCallback,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportButton({
    required String label,
    required String description,
    required String iconName,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 22,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
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