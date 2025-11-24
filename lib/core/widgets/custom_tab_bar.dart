import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final Color? backgroundColor;
  final List<Tab> tabs;
  final Color? labelColor;
  final Color? dividerColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final double? labelPadding;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.backgroundColor = Colors.transparent,
    this.labelColor = AppColors.white,
    this.dividerColor = AppColors.divider,
    this.unselectedLabelColor = AppColors.iconUnselected,
    this.indicatorColor = AppColors.primary,
    this.labelPadding = AppSpacing.space20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color(0xFF5C6BC0),
      child: TabBar(
        splashFactory: NoSplash.splashFactory,
        isScrollable: true,
        tabs: tabs,
        tabAlignment: TabAlignment.start,
        controller: controller,
        labelColor: labelColor,
        dividerColor: dividerColor,
        unselectedLabelColor: Color(0xFFC5CAE9),
        indicatorColor: indicatorColor,
        labelStyle: AppTextStyles.content4,
        labelPadding: EdgeInsets.symmetric(horizontal: labelPadding!),
      ),
    );
  }
}
