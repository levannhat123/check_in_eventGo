import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.hintText,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.textInputAction,
    this.validator,
    this.readOnly = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.shadowColor,
    this.hintTextColor,
    this.errorColor,
    this.suffixIcon,
    this.lableText,
    this.onTap,
    this.textColor = Colors.black,
    this.onChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? lableText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool readOnly;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? shadowColor;
  final Color? hintTextColor;
  final Color? errorColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outlineInputBorder(Color color) => OutlineInputBorder(
      borderSide: BorderSide(color: color, width: AppSizes.size1_2),
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.size10)),
    );

    return Stack(
      children: [
        Container(
          height: AppSizes.size48_6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.size16),
            boxShadow: [
              BoxShadow(
                color: shadowColor ?? Colors.grey.withValues(alpha: 0.3),
                offset: const Offset(AppSizes.size0, AppSizes.size3),
                blurRadius: AppSizes.size6,
              ),
            ],
          ),
        ),
        TextFormField(
          style: TextStyle(color: textColor, fontSize: AppSizes.size16),
          onChanged: onChanged,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          textInputAction: textInputAction,
          validator: validator,
          readOnly: readOnly,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.size16,
              vertical: AppSizes.size12_6,
            ),
            filled: true,
            fillColor: fillColor ?? Colors.pink.shade50,
            border: outlineInputBorder(borderColor ?? Colors.red),
            focusedBorder: outlineInputBorder(
              focusedBorderColor ?? Colors.blue,
            ),
            enabledBorder: outlineInputBorder(
              enabledBorderColor ?? Colors.orange,
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: hintTextColor ?? Colors.grey),
            labelText: lableText,
            labelStyle: TextStyle(color: hintTextColor ?? Colors.grey),
            prefixIcon: prefixIcon,

            suffixIcon: suffixIcon,
            errorStyle: TextStyle(color: errorColor ?? Colors.red),
          ),
        ),
      ],
    );
  }
}
