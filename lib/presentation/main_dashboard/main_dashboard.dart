import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/daily_work_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/upad_service.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // Services
  final DashboardService _dashboardService = DashboardService();
  final DailyWorkService _dailyWorkService = DailyWorkService();
  final UpadService _upadService = UpadService();

  // Data state
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load dashboard statistics
      final stats = await _dashboardService.getDashboardStatistics();

      // Load recent activities
      final recentWorkEntries = await _dailyWorkService.getRecentWorkEntries(limit: 3);
      final recentPayments = await _upadService.getRecentUpadPayments(limit: 3);

      // Process activities
      final activities = <Map<String, dynamic>>[];

      for (var work in recentWorkEntries) {
        activities.add({
          'type': 'work',
          'title': work['karigars']['full_name'] ?? 'Unknown',
          'subtitle': '${work['pieces_completed']} pieces - ₹${work['total_amount']?.toStringAsFixed(0) ?? '0'}',
          'time': _formatTimeAgo(DateTime.parse(work['created_at'])),
          'icon': Icons.check_circle_rounded,
          'color': AppTheme.successLight,
        });
      }

      for (var payment in recentPayments) {
        activities.add({
          'type': 'payment',
          'title': payment['karigars']['full_name'] ?? 'Unknown',
          'subtitle': 'Upad - ₹${payment['amount']?.toStringAsFixed(0) ?? '0'}',
          'time': _formatTimeAgo(DateTime.parse(payment['created_at'])),
          'icon': Icons.account_balance_wallet_rounded,
          'color': AppTheme.primaryLight,
        });
      }

      setState(() {
        _dashboardStats = stats;
        _recentActivities = activities.take(5).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load data';
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
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: _refreshDashboard,
                    color: AppTheme.primaryLight,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          
                          // Header
                          _buildHeader(),
                          
                          SizedBox(height: 3.h),
                          
                          // Stats Cards
                          _buildStatsSection(),
                          
                          SizedBox(height: 3.h),
                          
                          // Quick Actions
                          _buildQuickActions(),
                          
                          SizedBox(height: 3.h),
                          
                          // Recent Activity
                          _buildRecentActivity(),
                          
                          SizedBox(height: 3.h),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryLight,
            strokeWidth: 3,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.errorLight,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Please check your internet connection',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Vekariya Brothers',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerLight),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.textSecondaryLight,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Karigars',
                value: '${_dashboardStats['total_karigars'] ?? 0}',
                subtitle: '${_dashboardStats['active_karigars'] ?? 0} active',
                icon: Icons.people_rounded,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildStatCard(
                title: "Today's Work",
                value: '${_dashboardStats['todays_work_entries'] ?? 0}',
                subtitle: '${_dashboardStats['todays_pieces'] ?? 0} pieces',
                icon: Icons.assignment_rounded,
                color: AppTheme.warningLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Monthly Earnings',
                value: '₹${_formatAmount(_dashboardStats['monthly_earnings'])}',
                subtitle: 'This month',
                icon: Icons.trending_up_rounded,
                color: AppTheme.successLight,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildStatCard(
                title: 'Upad Paid',
                value: '₹${_formatAmount(_dashboardStats['monthly_upad'])}',
                subtitle: 'This month',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.accentOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final num = (amount as num).toDouble();
    if (num >= 100000) {
      return '${(num / 100000).toStringAsFixed(1)}L';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toStringAsFixed(0);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textLabelLight,
                size: 14,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppTheme.textLabelLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                label: 'Add Karigar',
                icon: Icons.person_add_rounded,
                color: AppTheme.primaryLight,
                onTap: () => Navigator.pushNamed(context, '/add-edit-karigar-screen'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildQuickActionButton(
                label: 'Add Work',
                icon: Icons.add_task_rounded,
                color: AppTheme.successLight,
                onTap: () => Navigator.pushNamed(context, '/daily-work-entry-screen'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildQuickActionButton(
                label: 'Pay Upad',
                icon: Icons.payments_rounded,
                color: AppTheme.warningLight,
                onTap: () => Navigator.pushNamed(context, '/upad-entry-screen'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        if (_recentActivities.isEmpty)
          _buildEmptyActivity()
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Column(
              children: List.generate(_recentActivities.length, (index) {
                final activity = _recentActivities[index];
                final isLast = index == _recentActivities.length - 1;
                return _buildActivityItem(activity, isLast: isLast);
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 40,
            color: AppTheme.textLabelLight,
          ),
          SizedBox(height: 1.5.h),
          Text(
            'No recent activity',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Start by adding work entries',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textLabelLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: AppTheme.dividerLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  activity['subtitle'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textLabelLight,
            ),
          ),
        ],
      ),
    );
  }
}
