import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Book condition chip widget
class BookConditionChip extends StatelessWidget {
  final String condition;
  final bool isSmall;
  
  const BookConditionChip({
    super.key,
    required this.condition,
    this.isSmall = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = _getConditionColor();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        condition,
        style: (isSmall ? AppTextStyles.overline : AppTextStyles.caption).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color _getConditionColor() {
    switch (condition) {
      case AppConstants.conditionNew:
        return AppColors.conditionNew;
      case AppConstants.conditionLikeNew:
        return AppColors.conditionLikeNew;
      case AppConstants.conditionGood:
        return AppColors.conditionGood;
      case AppConstants.conditionUsed:
        return AppColors.conditionUsed;
      default:
        return AppColors.textSecondary;
    }
  }
}
