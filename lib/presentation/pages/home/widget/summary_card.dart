import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class SummaryCard extends StatelessWidget {
  final int soldTickets;
  final int totalTickets;

  const SummaryCard({
    super.key,
    required this.soldTickets,
    required this.totalTickets,
  });

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (totalTickets == 0)
        ? 0
        : (soldTickets / totalTickets);
    final int percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.size20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.soldTicketSummaryTitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: AppSizes.size14,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _formatNumber(soldTickets),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.size32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' / ${_formatNumber(totalTickets)} ${AppStrings.ticketUnit}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: AppSizes.size14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: AppSizes.size80,
            height: AppSizes.size80,
            child: Stack(
              children: [
                SizedBox(
                  width: AppSizes.size80,
                  height: AppSizes.size80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: AppSizes.size8,
                    backgroundColor: AppColors.cardMutedBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.checkInGlow,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: AppColors.checkInGlow,
                          fontSize: AppSizes.size16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.soldLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: AppSizes.size10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
