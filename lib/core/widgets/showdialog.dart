import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_spacing.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.size20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space20,
              AppSpacing.space60,
              AppSpacing.space20,
              AppSpacing.space20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.size20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppSizes.size16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.space10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppSizes.size14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: AppSpacing.space20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.size10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space40,
                      vertical: AppSpacing.space12,
                    ),
                  ),
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -AppSpacing.space40,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: AppSizes.size10,
                    spreadRadius: AppSizes.size2,
                    offset: const Offset(AppSizes.size0, AppSizes.size5),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: AppSizes.size30,
                child: Icon(icon, size: AppSizes.size40, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonText,
  required IconData icon,
  required Color iconColor,
  required VoidCallback onPressed,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: icon,
        iconColor: iconColor,
        onPressed: () {
          Navigator.of(context).pop();
          onPressed();
        },
      );
    },
  );
}
