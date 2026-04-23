import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String rating;
  final bool isHightlight;
  final VoidCallback? onTap;
  final Widget? statusTag;
  final bool isEnabled;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.rating,
    this.isHightlight = false,
    this.onTap,
    this.statusTag,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.size5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizes.size80,
                height: AppSizes.size110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.size12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.space60),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.size16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: AppSizes.size14,
                        ),
                        const SizedBox(width: AppSpacing.space6),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: AppSizes.size13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space16),

                    Row(
                      children: [
                        // Rating Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space12,
                            vertical: AppSpacing.space8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardAccentBackground,
                            borderRadius: BorderRadius.circular(
                              AppSizes.size20,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color: Colors.white.withValues(alpha: 0.6),
                                size: AppSizes.size16,
                              ),
                              const SizedBox(width: AppSpacing.space4),
                              Text(
                                rating,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: AppSizes.size12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        InkWell(
                          // 3. Nếu không enable thì onTap là null (không bấm được)
                          onTap: isEnabled ? onTap : null,
                          borderRadius: BorderRadius.circular(AppSizes.size20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space16,
                              vertical: AppSpacing.space8,
                            ),
                            decoration: BoxDecoration(
                              // 4. Logic đổi màu Gradient
                              gradient: isEnabled
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.checkInGradientStart,
                                        AppColors.checkInGradientEnd,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        AppColors.checkInDisabledStart,
                                        AppColors.checkInDisabledEnd,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(
                                AppSizes.size20,
                              ),
                              boxShadow: isEnabled
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00C4B4,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: AppSizes.size8,
                                        offset: const Offset(
                                          AppSizes.size0,
                                          AppSizes.size2,
                                        ),
                                      ),
                                    ]
                                  : [], // Tắt bóng đổ nếu disable
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isEnabled
                                      ? Icons.qr_code_scanner
                                      : Icons
                                            .lock_outline, // Đổi icon thành ổ khóa nếu khóa
                                  color: isEnabled
                                      ? Colors.white
                                      : Colors.white54,
                                  size: AppSizes.size16,
                                ),
                                const SizedBox(width: AppSpacing.space6),
                                Text(
                                  AppStrings.checkInButton,
                                  style: TextStyle(
                                    color: isEnabled
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: AppSizes.size13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (statusTag != null)
          Positioned(
            top: AppSizes.size0,
            right: AppSizes.size0,
            child: statusTag!,
          ),
      ],
    );
  }
}
