import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PersonalDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController aadhaarController;
  final String? nameError;
  final String? mobileError;
  final String? aadhaarError;
  final Function(String) onNameChanged;
  final Function(String) onMobileChanged;
  final Function(String) onAadhaarChanged;

  const PersonalDetailsSection({
    Key? key,
    required this.nameController,
    required this.mobileController,
    required this.aadhaarController,
    this.nameError,
    this.mobileError,
    this.aadhaarError,
    required this.onNameChanged,
    required this.onMobileChanged,
    required this.onAadhaarChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),

            // Name Field
            TextFormField(
              controller: nameController,
              onChanged: onNameChanged,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter karigar full name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: nameError,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // Mobile Field
            TextFormField(
              controller: mobileController,
              onChanged: onMobileChanged,
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                prefixText: '+91 ',
                errorText: mobileError,
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // Aadhaar Field
            TextFormField(
              controller: aadhaarController,
              onChanged: onAadhaarChanged,
              decoration: InputDecoration(
                labelText: 'Aadhaar Number',
                hintText: 'Enter 12-digit Aadhaar number',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'credit_card',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: aadhaarError,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
                _AadhaarInputFormatter(),
              ],
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
    );
  }
}

class _AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
