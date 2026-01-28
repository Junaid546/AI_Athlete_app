import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CardVariant {
  elevated,
  filled,
  outlined,
  glassmorphism,
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final bool useGradient;

  const CustomCard({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: _getDecoration(isDark),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getDecoration(bool isDark) {
    final defaultBackgroundColor = backgroundColor ??
        (isDark ? AppTheme.darkSurface : AppTheme.lightSurface);

    final defaultBorderColor = borderColor ??
        (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);

    switch (variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: elevation ?? 8,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: defaultBorderColor,
            width: 1,
          ),
        );

      case CardVariant.glassmorphism:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: useGradient
              ? AppTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    (backgroundColor ?? Colors.white).withOpacity(0.1),
                    (backgroundColor ?? Colors.white).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        );
    }
  }
}

// Pre-built card components for common use cases
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool useGradient;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      variant: useGradient ? CardVariant.glassmorphism : CardVariant.elevated,
      useGradient: useGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String exercises;
  final VoidCallback? onTap;
  final String? imageUrl;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.exercises,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      child: Row(
        children: [
          if (imageUrl != null) ...[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exercises,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white60
                : Colors.black45,
          ),
        ],
      ),
    );
  }
}
