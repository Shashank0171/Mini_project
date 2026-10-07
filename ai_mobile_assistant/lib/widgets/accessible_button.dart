import 'package:flutter/material.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';

/// A large, accessible button with minimum 48dp touch target.
/// Supports icon + text layout and custom styling.
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLarge;
  final String? semanticLabel;

  const AccessibleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLarge = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final fgColor = textColor ?? AppTheme.textOnPrimary;
    final height = isLarge ? AppTheme.largeTouchTarget : AppTheme.minTouchTarget;

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: onPressed != null,
      child: SizedBox(
        width: double.infinity,
        height: height + 8,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor.withValues(alpha: 0.4),
            disabledForegroundColor: fgColor.withValues(alpha: 0.6),
            minimumSize: Size(double.infinity, height),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
            ),
            textStyle: TextStyle(
              fontSize: isLarge ? 22 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: isLarge ? 28 : 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
