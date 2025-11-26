import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BankDetailsSection extends StatelessWidget {
  final TextEditingController accountNumberController;
  final TextEditingController ifscController;
  final TextEditingController bankNameController;
  final TextEditingController branchController;
  final String? accountNumberError;
  final String? ifscError;
  final String? bankNameError;
  final String? branchError;
  final Function(String) onAccountNumberChanged;
  final Function(String) onIfscChanged;
  final Function(String) onBankNameChanged;
  final Function(String) onBranchChanged;

  const BankDetailsSection({
    Key? key,
    required this.accountNumberController,
    required this.ifscController,
    required this.bankNameController,
    required this.branchController,
    this.accountNumberError,
    this.ifscError,
    this.bankNameError,
    this.branchError,
    required this.onAccountNumberChanged,
    required this.onIfscChanged,
    required this.onBankNameChanged,
    required this.onBranchChanged,
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
              'Bank Details',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),

            // Account Number Field
            TextFormField(
              controller: accountNumberController,
              onChanged: onAccountNumberChanged,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Enter bank account number',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'account_balance',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: accountNumberError,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(18),
              ],
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // IFSC Code Field
            TextFormField(
              controller: ifscController,
              onChanged: onIfscChanged,
              decoration: InputDecoration(
                labelText: 'IFSC Code',
                hintText: 'Enter IFSC code (e.g., SBIN0001234)',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'code',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: ifscError,
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              ],
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // Bank Name Field
            TextFormField(
              controller: bankNameController,
              onChanged: onBankNameChanged,
              decoration: InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Enter bank name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'business',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: bankNameError,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // Branch Field
            TextFormField(
              controller: branchController,
              onChanged: onBranchChanged,
              decoration: InputDecoration(
                labelText: 'Branch Name',
                hintText: 'Enter branch name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'location_city',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: branchError,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
