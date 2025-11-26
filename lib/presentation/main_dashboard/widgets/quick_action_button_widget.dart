import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionButtonWidget extends StatefulWidget {
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
  State<QuickActionButtonWidget> createState() =>
      _QuickActionButtonWidgetState();
}

class _QuickActionButtonWidgetState extends State<QuickActionButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Start initial bounce effect
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted)
        _bounceController.forward().then((_) => _bounceController.reverse());
    });

    // Start shimmer effect periodically
    _startShimmerEffect();
  }

  void _startShimmerEffect() {
    Future.delayed(Duration(milliseconds: 3000), () {
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
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Haptic feedback and animation
    _scaleController.forward().then((_) {
      _scaleController.reverse().then((_) {
        widget.onPressed();
        _bounceController.forward().then((_) => _bounceController.reverse());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_scaleAnimation, _shimmerAnimation, _bounceAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _bounceAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _handleTap,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.8),
                          widget.backgroundColor.withValues(alpha: 0.9),
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                      borderRadius:
                          BorderRadius.circular(20), // Premium rounded design
                      boxShadow: [
                        BoxShadow(
                          color: widget.backgroundColor.withValues(alpha: 0.35),
                          offset: Offset(0, 8),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shimmer Effect Overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                      -1.0 + _shimmerAnimation.value, -1.0),
                                  end: Alignment(
                                      1.0 + _shimmerAnimation.value, 1.0),
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Background decorative elements
                        Positioned(
                          top: -8,
                          right: -8,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -6,
                          left: -6,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),

                        // Main Icon
                        Center(
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: CustomIconWidget(
                                  iconName: widget.iconName,
                                  color: widget.iconColor,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 1.5.h),

                // Premium Label Design
                Container(
                  constraints: BoxConstraints(maxWidth: 24.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: widget.backgroundColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
