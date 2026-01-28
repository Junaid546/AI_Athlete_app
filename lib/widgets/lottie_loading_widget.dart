import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Reusable Lottie loading animations with multiple styles
class LottieLoadingWidget extends StatelessWidget {
  final String animationPath;
  final String? message;
  final double size;
  final bool repeat;
  final TextStyle? messageStyle;

  const LottieLoadingWidget({
    super.key,
    required this.animationPath,
    this.message,
    this.size = 120,
    this.repeat = true,
    this.messageStyle,
  });

  factory LottieLoadingWidget.loading({
    String? message,
    double size = 120,
  }) {
    return LottieLoadingWidget(
      animationPath: 'assets/lottie/loading.json',
      message: message ?? 'Loading...',
      size: size,
    );
  }

  factory LottieLoadingWidget.loadingSmall({
    String? message,
  }) {
    return LottieLoadingWidget(
      animationPath: 'assets/lottie/loading.json',
      message: message,
      size: 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animationPath,
            width: size,
            height: size,
            repeat: repeat,
            frameRate: FrameRate(60),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: messageStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Overlay loading indicator with Lottie animation
class LottieLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LottieLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LottieLoadingWidget.loadingSmall(message: message),
              ),
            ),
          ),
      ],
    );
  }
}

/// Inline loading widget for list/grid items
class LottieInlineLoading extends StatelessWidget {
  final String? message;
  final double size;

  const LottieInlineLoading({
    super.key,
    this.message,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: LottieLoadingWidget(
        animationPath: 'assets/lottie/loading.json',
        message: message,
        size: size,
      ),
    );
  }
}

/// Card loading skeleton with shimmer effect
class LottieCardLoader extends StatelessWidget {
  final int count;
  final double height;

  const LottieCardLoader({
    super.key,
    this.count = 3,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: height,
            child: Lottie.asset(
              'assets/lottie/loading.json',
              repeat: true,
              frameRate: FrameRate(60),
            ),
          ),
        );
      }),
    );
  }
}
