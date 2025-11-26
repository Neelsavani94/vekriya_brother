import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean quick action button widget
class QuickActionButtonWidget extends StatelessWidget {
  final String label;
  final String iconName;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const QuickActionButtonWidget({
    Key? key,
    required this.label,
    required this.iconName,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: iconColor,
              size: 28,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
