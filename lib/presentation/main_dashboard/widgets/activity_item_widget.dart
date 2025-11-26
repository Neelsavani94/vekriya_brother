import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityItemWidget extends StatefulWidget {
  final String title;
  final String description;
  final String timestamp;
  final String iconName;
  final Color statusColor;

  const ActivityItemWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconName,
    required this.statusColor,
  }) : super(key: key);

  @override
  State<ActivityItemWidget> createState() => _ActivityItemWidgetState();
}

class _ActivityItemWidgetState extends State<ActivityItemWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 60.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations with staggered delays
    Future.delayed(Duration(milliseconds: 150), () {
      if (mounted) _slideController.forward();
    });

    // Start subtle pulse effect for status indicator
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: EdgeInsets.all(5.w),
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppTheme.backgroundLight.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(18), // Premium rounded design
                border: Border.all(
                  color: widget.statusColor.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: AppTheme.getSoftShadow(
                  color: widget.statusColor,
                  opacity: 0.06,
                ),
              ),
              child: Row(
                children: [
                  // 🎯 Premium Status Icon with Pulse Effect
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 0.05,
                          child: Container(
                            width: 14.w,
                            height: 14.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.statusColor.withValues(alpha: 0.15),
                                  widget.statusColor.withValues(alpha: 0.08),
                                  widget.statusColor.withValues(alpha: 0.12),
                                ],
                                stops: [0.0, 0.6, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    widget.statusColor.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      widget.statusColor.withValues(alpha: 0.2),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: widget.iconName,
                                color: widget.statusColor,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 4.5.w),

                  // 📄 Premium Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✨ Enhanced Title with Status Indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryLight,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    widget.statusColor.withValues(alpha: 0.3),
                                    widget.statusColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: widget.statusColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.statusColor
                                          .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.2.h),

                        // 📝 Enhanced Description with Better Typography
                        Text(
                          widget.description,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryLight,
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),

                        SizedBox(height: 1.5.h),

                        // ⏰ Premium Timestamp Section
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.5.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.statusColor.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color:
                                      widget.statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.schedule_rounded,
                                  size: 12,
                                  color: widget.statusColor,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                widget.timestamp,
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textLabelLight,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryLight
                                          .withValues(alpha: 0.1),
                                      AppTheme.primaryLight
                                          .withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
