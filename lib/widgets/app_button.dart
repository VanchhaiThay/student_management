import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isAccent;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isAccent = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the background color
    Color getBackgroundColor() {
      if (isAccent) return AppColors.accent;
      if (isPrimary) return AppColors.primary;
      return Colors.transparent;
    }

    // Determine the text color
    Color getTextColor() {
      if (isAccent || isPrimary) return Colors.white;
      return AppColors.primary;
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: getBackgroundColor(),
        foregroundColor: getTextColor(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isPrimary || isAccent ? 2 : 0,
        side: (!isPrimary && !isAccent) 
            ? const BorderSide(color: AppColors.primary)
            : BorderSide.none,
      ),
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: getTextColor(),
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
