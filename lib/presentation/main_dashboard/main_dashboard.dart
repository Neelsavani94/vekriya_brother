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
  final Map<String, String> _summaryOptions = const {
    'today': 'Today',
    'week': 'This Week',
    'month': 'This Month',
  };
  String _selectedSummaryKey = 'today';
  int _currentTipIndex = 0;
  final List<Map<String, String>> _assistantTips = const [
    {
      'title': 'Record work in 2 taps',
      'body':
          'Use the Daily Work button below right after a piece is done to avoid guess work later.',
    },
    {
      'title': 'Stay ahead of payments',
      'body':
          'Keep Upad entries updated so you always know who is waiting for their advance.',
    },
    {
      'title': 'Keep contacts fresh',
      'body':
          'Adding a photo, skill level, and phone number for every karigar keeps your team organized.',
    },
  ];

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

  String get _summaryLabel =>
      _summaryOptions[_selectedSummaryKey] ?? _summaryOptions.values.first;

  void _navigateToScreen(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void _selectSummary(String key) {
    if (_selectedSummaryKey == key) return;
    setState(() => _selectedSummaryKey = key);
  }

  void _showNextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _assistantTips.length;
    });
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

                              GreetingHeaderWidget(
                                businessOwnerName: 'Vekariya Brothers',
                                currentDate: _formatDate(_lastRefresh),
                              ),

                              SizedBox(height: 2.5.h),

                              _buildSummaryChips(),

                              SizedBox(height: 1.2.h),

                              _buildFriendlyInfoRow(),

                              SizedBox(height: 2.h),

                              _buildAssistantCard(),

                              SizedBox(height: 3.h),

                              SectionHeader(
                                title: 'Workshop Pulse',
                                subtitle: '$_summaryLabel overview of your unit',
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                              ),

                              SizedBox(height: 2.h),

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
                                                '${(_dashboardStats['active_karigars'] ?? 0)} active right now',
                                            onTap: () => _navigateToScreen(
                                                '/karigar-list-screen'),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: MetricCardWidget(
                                            title: 'Work Entries',
                                            value: (_dashboardStats[
                                                        'todays_work_entries'] ??
                                                    0)
                                                .toString(),
                                            iconName: 'assignment',
                                            statusColor: AppTheme.warningLight,
                                            subtitle:
                                                '${(_dashboardStats['todays_pieces'] ?? 0)} pieces logged',
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

                              _buildQuickActionsCarousel(),

                              SizedBox(height: 4.h),

                              SectionHeader(
                                title: 'Recent Activities',
                                subtitle: 'Latest work entries and payments',
                                action: TextButton(
                                  onPressed: () =>
                                      _navigateToScreen('/activity-logs-screen'),
                                  child: Text(
                                    'View All',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryLight,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                              ),
                              SizedBox(height: 2.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: _recentActivities.isEmpty
                                    ? Container(
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
                                    : Column(
                                        children: List.generate(
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
                                                description:
                                                    activity['subtitle'] ?? '',
                                                timestamp:
                                                    activity['time'] ?? '',
                                                iconName:
                                                    activity['icon'] ?? 'info',
                                                statusColor:
                                                    activity['color'] ??
                                                        AppTheme.primaryLight,
                                              ),
                                            );
                                          },
                                        ),
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

  Widget _buildSummaryChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Wrap(
        spacing: AppSpacing.sm,
        children: _summaryOptions.entries.map((entry) {
          final isSelected = _selectedSummaryKey == entry.key;
          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => _selectSummary(entry.key),
            selectedColor: AppTheme.primaryLight.withValues(alpha: 0.15),
            backgroundColor: AppTheme.surfaceLight,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color:
                    isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFriendlyInfoRow() {
    final items = [
      {
        'icon': Icons.person_add_alt_1_rounded,
        'label': 'Add new karigar',
        'action': () => _navigateToScreen('/add-edit-karigar-screen'),
      },
      {
        'icon': Icons.fact_check_rounded,
        'label': 'Log today\'s work',
        'action': () => _navigateToScreen('/daily-work-entry-screen'),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Pay pending upad',
        'action': () => _navigateToScreen('/upad-entry-screen'),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: items
            .map(
              (item) => FriendlyInfoPill(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                onTap: item['action'] as VoidCallback,
                backgroundColor: AppTheme.surfaceLight,
                iconColor: AppTheme.primaryLight,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAssistantCard() {
    final tip = _assistantTips[_currentTipIndex];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        onTap: _showNextTip,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppTheme.primaryLight.withValues(alpha: 0.08),
            ),
            boxShadow: AppTheme.getSoftShadow(),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_circle_rounded,
                  color: AppTheme.primaryLight,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      tip['body'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      'Tap for another tip',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.refresh_rounded,
                color: AppTheme.primaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCarousel() {
    final quickActions = [
      {
        'label': 'Add Karigar',
        'icon': 'person_add',
        'color': AppTheme.primaryLight,
        'helper': 'Create a profile with phone, skill, and rate.',
        'route': '/add-edit-karigar-screen',
      },
      {
        'label': 'Daily Work',
        'icon': 'assignment_add',
        'color': AppTheme.warningLight,
        'helper': 'Capture pieces completed with one form.',
        'route': '/daily-work-entry-screen',
      },
      {
        'label': 'Add Upad',
        'icon': 'payment',
        'color': AppTheme.successLight,
        'helper': 'Log any advance you hand over instantly.',
        'route': '/upad-entry-screen',
      },
      {
        'label': 'Reports',
        'icon': 'assessment',
        'color': AppTheme.primaryLight,
        'helper': 'See month-end totals and trends.',
        'route': '/reports-screen',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Quick Actions',
          subtitle: 'Complete frequent tasks without hunting through menus',
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 22.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemBuilder: (context, index) {
              final action = quickActions[index];
              final color = action['color'] as Color;
              return SizedBox(
                width: 34.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuickActionButtonWidget(
                      label: action['label'] as String,
                      iconName: action['icon'] as String,
                      backgroundColor: color,
                      iconColor: Colors.white,
                      onPressed: () =>
                          _navigateToScreen(action['route'] as String),
                    ),
                    SizedBox(height: 1.2.h),
                    Text(
                      action['helper'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemCount: quickActions.length,
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