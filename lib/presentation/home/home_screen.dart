import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../main_dashboard/main_dashboard.dart';
import '../karigar_list_screen/karigar_list_screen.dart';
import '../daily_work_entry_screen/daily_work_entry_screen.dart';
import '../upad_entry_screen/upad_entry_screen.dart';

/// Main Home Screen with Bottom Navigation
/// Designed for easy access to all key features
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainDashboard(),
    const KarigarListScreen(),
    const DailyWorkEntryScreen(),
    const UpadEntryScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      label: 'Karigars',
      activeIcon: Icons.people_rounded,
    ),
    _NavItem(
      icon: Icons.work_outline_rounded,
      label: 'Daily Work',
      activeIcon: Icons.work_rounded,
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Upad',
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return _buildNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onTabTapped(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 5.w : 3.w,
          vertical: 1.2.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            if (isSelected) ...[
              SizedBox(width: 2.w),
              Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.label,
    required this.activeIcon,
  });
}
