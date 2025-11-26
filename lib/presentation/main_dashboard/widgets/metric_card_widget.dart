import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetricCardWidget extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color statusColor;
  final String iconName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MetricCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.statusColor,
    required this.iconName,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<MetricCardWidget> createState() => _MetricCardWidgetState();
}

class _MetricCardWidgetState extends State<MetricCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _counterController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _counterAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );

    _counterController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _counterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutExpo,
    ));

    // Start animations
    _startShimmerEffect();
    _counterController.forward();
  }

  void _startShimmerEffect() {
    Future.delayed(Duration(milliseconds: 2000 + (widget.hashCode % 1000)), () {
      if (mounted) {
        _shimmerController.forward().then((_) {
          _shimmerController.reset();
          _startShimmerEffect();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_scaleAnimation, _shimmerAnimation, _counterAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPress,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppTheme.backgroundLight.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.statusColor.withValues(alpha: 0.12),
                    offset: Offset(0, 4),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: widget.statusColor.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Enhanced Shimmer Effect
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(
                                    -1.0 + _shimmerAnimation.value, -0.3),
                                end: Alignment(
                                    1.0 + _shimmerAnimation.value, 0.3),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Main Content with Improved Layout
                  Row(
                    children: [
                      // 🎨 Enhanced Icon Container
                      Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.statusColor,
                              widget.statusColor.withValues(alpha: 0.8),
                              widget.statusColor.withValues(alpha: 0.6),
                            ],
                            stops: [0.0, 0.6, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: widget.statusColor.withValues(alpha: 0.4),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: widget.statusColor.withValues(alpha: 0.2),
                              offset: Offset(0, 2),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: widget.iconName,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      SizedBox(width: 4.w),

                      // 📊 Enhanced Content Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with improved contrast
                            Text(
                              widget.title,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondaryLight,
                                letterSpacing: -0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 0.8.h),

                            // 💰 Enhanced Animated Value with Counter Effect
                            AnimatedBuilder(
                              animation: _counterAnimation,
                              builder: (context, child) {
                                return ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.statusColor,
                                      widget.statusColor.withValues(alpha: 0.8),
                                      widget.statusColor.withValues(alpha: 0.9),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    widget.value,
                                    style: GoogleFonts.inter(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.8,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: widget.statusColor
                                              .withValues(alpha: 0.3),
                                          offset: Offset(1, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 0.8.h),

                            // 📈 Enhanced Subtitle with Better Visibility
                            Row(
                              children: [
                                // Progress indicator line
                                Container(
                                  width: 1.2.w,
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        widget.statusColor,
                                        widget.statusColor
                                            .withValues(alpha: 0.4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    widget.subtitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondaryLight,
                                      height: 1.3,
                                      letterSpacing: -0.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 📊 Enhanced Trend Indicator with Animation
                      Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Container(
                                  padding: EdgeInsets.all(2.5.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        widget.statusColor
                                            .withValues(alpha: 0.2),
                                        widget.statusColor
                                            .withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: widget.statusColor
                                          .withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.statusColor
                                            .withValues(alpha: 0.15),
                                        offset: Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.trending_up_rounded,
                                    color: widget.statusColor,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 0.8.h),
                          // Animated progress bar
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1500),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutExpo,
                            builder: (context, value, child) {
                              return Container(
                                width: 7.w,
                                height: 0.4.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color:
                                      widget.statusColor.withValues(alpha: 0.2),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 7.w * value * 0.8,
                                    height: 0.4.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.statusColor
                                              .withValues(alpha: 0.6),
                                          widget.statusColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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
