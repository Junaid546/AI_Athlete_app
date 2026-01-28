import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool iconLeft;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconLeft = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Size configurations
    final sizeConfig = _getSizeConfig();

    // Color configurations based on variant
    final colorConfig = _getColorConfig(isDark);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? sizeConfig.height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorConfig.backgroundColor,
          foregroundColor: colorConfig.foregroundColor,
          elevation: colorConfig.elevation,
          shadowColor: colorConfig.shadowColor,
          padding: sizeConfig.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            side: colorConfig.borderSide,
          ),
          textStyle: sizeConfig.textStyle,
        ),
        child: isLoading
            ? SizedBox(
                width: sizeConfig.iconSize,
                height: sizeConfig.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorConfig.foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && iconLeft) ...[
                    Icon(
                      icon,
                      size: sizeConfig.iconSize,
                      color: colorConfig.foregroundColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                  if (icon != null && !iconLeft) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      size: sizeConfig.iconSize,
                      color: colorConfig.foregroundColor,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  _ButtonSizeConfig _getSizeConfig() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSizeConfig(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 8,
          iconSize: 16,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        );
      case ButtonSize.medium:
        return _ButtonSizeConfig(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 12,
          iconSize: 18,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        );
      case ButtonSize.large:
        return _ButtonSizeConfig(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          borderRadius: 16,
          iconSize: 20,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        );
    }
  }

  _ButtonColorConfig _getColorConfig(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColorConfig(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
          borderSide: BorderSide.none,
        );
      case ButtonVariant.secondary:
        return _ButtonColorConfig(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.secondaryColor.withOpacity(0.3),
          borderSide: BorderSide.none,
        );
      case ButtonVariant.outline:
        return _ButtonColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        );
      case ButtonVariant.ghost:
        return _ButtonColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white70 : Colors.black87,
          elevation: 0,
          shadowColor: Colors.transparent,
          borderSide: BorderSide.none,
        );
      case ButtonVariant.danger:
        return _ButtonColorConfig(
          backgroundColor: AppTheme.dangerColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.dangerColor.withOpacity(0.3),
          borderSide: BorderSide.none,
        );
    }
  }
}

class _ButtonSizeConfig {
  final double height;
  final EdgeInsets padding;
  final double borderRadius;
  final double iconSize;
  final TextStyle textStyle;

  _ButtonSizeConfig({
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.iconSize,
    required this.textStyle,
  });
}

class _ButtonColorConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final Color shadowColor;
  final BorderSide borderSide;

  _ButtonColorConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.elevation,
    required this.shadowColor,
    required this.borderSide,
  });
}
