import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PiecesInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool enabled;

  const PiecesInputWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PiecesInputWidget> createState() => _PiecesInputWidgetState();
}

class _PiecesInputWidgetState extends State<PiecesInputWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppTheme.primaryLight
              : AppTheme.primaryLight.withValues(alpha: 0.2),
          width: _focusNode.hasFocus ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: _focusNode.hasFocus ? 0.15 : 0.08),
            offset: Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'inventory_2',
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Pieces',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryLight,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Enter the total pieces completed',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Enhanced Input Field
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: GoogleFonts.inter(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryLight,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.inter(
                fontSize: 36.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.textLabelLight.withValues(alpha: 0.3),
                letterSpacing: -1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.primaryLight.withValues(alpha: 0.06),
              contentPadding: EdgeInsets.symmetric(vertical: 3.5.h, horizontal: 4.w),
            ),
            onChanged: (value) {
              widget.onChanged(value);
              if (mounted) {
                setState(() {});
              }
            },
          ),
          // Enhanced Feedback Message
          if (widget.controller.text.isNotEmpty) ...[
            SizedBox(height: 2.5.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successLight.withValues(alpha: 0.15),
                    AppTheme.successLight.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.successLight.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successLight,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '${widget.controller.text} pieces entered',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successLight,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
