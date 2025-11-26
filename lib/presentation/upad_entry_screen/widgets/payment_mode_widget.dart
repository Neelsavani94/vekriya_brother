import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentModeWidget extends StatelessWidget {
  final String selectedPaymentMode;
  final Function(String) onPaymentModeChanged;
  final TextEditingController upiController;
  final TextEditingController chequeController;

  const PaymentModeWidget({
    Key? key,
    required this.selectedPaymentMode,
    required this.onPaymentModeChanged,
    required this.upiController,
    required this.chequeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Mode',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildPaymentModeOptions(),
          SizedBox(height: 2.h),
          _buildConditionalFields(),
        ],
      ),
    );
  }

  Widget _buildPaymentModeOptions() {
    final paymentModes = [
      {'value': 'cash', 'label': 'Cash', 'icon': 'payments'},
      {
        'value': 'bank_transfer',
        'label': 'Bank Transfer',
        'icon': 'account_balance'
      },
      {'value': 'upi', 'label': 'UPI', 'icon': 'qr_code'},
      {'value': 'cheque', 'label': 'Cheque', 'icon': 'receipt_long'},
    ];

    return Column(
      children: paymentModes.map((mode) {
        final isSelected = selectedPaymentMode == mode['value'];
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          child: InkWell(
            onTap: () => onPaymentModeChanged(mode['value'] as String),
            borderRadius: BorderRadius.circular(2.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: mode['value'] as String,
                    groupValue: selectedPaymentMode,
                    onChanged: (value) {
                      if (value != null) {
                        onPaymentModeChanged(value);
                      }
                    },
                    activeColor: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: mode['icon'] as String,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    mode['label'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConditionalFields() {
    switch (selectedPaymentMode) {
      case 'upi':
        return _buildUpiField();
      case 'cheque':
        return _buildChequeField();
      case 'bank_transfer':
        return _buildBankTransferInfo();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildUpiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPI ID',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: upiController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter UPI ID (e.g., user@paytm)',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'qr_code',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          validator: (value) {
            if (selectedPaymentMode == 'upi' &&
                (value == null || value.isEmpty)) {
              return 'Please enter UPI ID';
            }
            if (selectedPaymentMode == 'upi' &&
                value != null &&
                !value.contains('@')) {
              return 'Please enter valid UPI ID';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildChequeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cheque Number',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: chequeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter cheque number',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'receipt_long',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          validator: (value) {
            if (selectedPaymentMode == 'cheque' &&
                (value == null || value.isEmpty)) {
              return 'Please enter cheque number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Bank transfer details will be recorded. Please ensure to keep transaction reference for records.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
