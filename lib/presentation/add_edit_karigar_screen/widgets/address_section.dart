import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddressSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController pincodeController;
  final String? addressError;
  final String? pincodeError;
  final Function(String) onAddressChanged;
  final Function(String) onPincodeChanged;

  const AddressSection({
    Key? key,
    required this.addressController,
    required this.pincodeController,
    this.addressError,
    this.pincodeError,
    required this.onAddressChanged,
    required this.onPincodeChanged,
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
              'Address Details',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),

            // Address Field
            TextFormField(
              controller: addressController,
              onChanged: onAddressChanged,
              decoration: InputDecoration(
                labelText: 'Complete Address',
                hintText: 'Enter full address with area, city',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: addressError,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // Pincode Field
            TextFormField(
              controller: pincodeController,
              onChanged: onPincodeChanged,
              decoration: InputDecoration(
                labelText: 'Pincode',
                hintText: 'Enter 6-digit pincode',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'pin_drop',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: pincodeError,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
    );
  }
}
