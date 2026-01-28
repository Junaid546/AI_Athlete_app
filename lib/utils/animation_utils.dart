import 'package:flutter/material.dart';

class AnimationUtils {
  // Staggered animation for chart entrance
  static List<Animation<double>> createStaggeredAnimations({
    required int itemCount,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Curve curve = Curves.easeInOutCubic,
  }) {
    final animations = <Animation<double>>[];

    for (int i = 0; i < itemCount; i++) {
      final startTime = i * staggerDelay.inMilliseconds / controller.duration!.inMilliseconds;
      final endTime = (i + 1) * staggerDelay.inMilliseconds / controller.duration!.inMilliseconds;

      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              startTime.clamp(0.0, 1.0),
              endTime.clamp(0.0, 1.0),
              curve: curve,
            ),
          ),
        ),
      );
    }

    return animations;
  }

  // Scale and fade animation
  static Animation<double> createScaleFadeAnimation({
    required AnimationController controller,
    double beginScale = 0.8,
    double endScale = 1.0,
    Curve curve = Curves.easeInOutCubic,
  }) {
    return Tween<double>(begin: beginScale, end: endScale).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Slide animation
  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    Offset beginOffset = const Offset(1.0, 0.0),
    Offset endOffset = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<Offset>(begin: beginOffset, end: endOffset).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Pulse animation for badges/streaks
  static Animation<double> createPulseAnimation({
    required AnimationController controller,
    double beginScale = 1.0,
    double endScale = 1.2,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: beginScale, end: endScale).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Bounce animation for achievements
  static Animation<double> createBounceAnimation({
    required AnimationController controller,
    double beginScale = 0.3,
    double endScale = 1.0,
  }) {
    return Tween<double>(begin: beginScale, end: endScale).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  // Rotate animation for FAB
  static Animation<double> createRotateAnimation({
    required AnimationController controller,
    double beginAngle = 0.0,
    double endAngle = 2 * 3.14159, // 360 degrees
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: beginAngle, end: endAngle).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Shimmer loading animation
  static Animation<double> createShimmerAnimation({
    required AnimationController controller,
  }) {
    return Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );
  }

  // Fade in animation
  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
    Curve curve = Curves.easeIn,
  }) {
    return Tween<double>(begin: beginOpacity, end: endOpacity).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Combined scale and fade widget
  static Widget buildAnimatedWidget({
    required Widget child,
    required Animation<double> animation,
    bool useScale = true,
    bool useFade = true,
    Offset? slideOffset,
  }) {
    Widget animatedChild = child;

    if (useFade) {
      animatedChild = FadeTransition(
        opacity: animation,
        child: animatedChild,
      );
    }

    if (useScale) {
      animatedChild = ScaleTransition(
        scale: animation,
        child: animatedChild,
      );
    }

    if (slideOffset != null) {
      animatedChild = SlideTransition(
        position: Tween<Offset>(
          begin: slideOffset,
          end: Offset.zero,
        ).animate(animation),
        child: animatedChild,
      );
    }

    return animatedChild;
  }

  // Page transition builder
  static PageRouteBuilder createSlideRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: beginOffset, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Staggered list animation
  static Widget buildStaggeredList({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final animations = createStaggeredAnimations(
      itemCount: children.length,
      controller: controller,
      staggerDelay: staggerDelay,
    );

    return Column(
      children: List.generate(children.length, (index) {
        return AnimatedBuilder(
          animation: animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: animations[index].value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animations[index].value)),
                child: children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

// Extension methods for common animations
extension AnimationExtensions on Widget {
  Widget withScaleAnimation({
    required AnimationController controller,
    double beginScale = 0.8,
    double endScale = 1.0,
    Curve curve = Curves.easeInOutCubic,
  }) {
    final animation = AnimationUtils.createScaleFadeAnimation(
      controller: controller,
      beginScale: beginScale,
      endScale: endScale,
      curve: curve,
    );

    return ScaleTransition(
      scale: animation,
      child: this,
    );
  }

  Widget withFadeAnimation({
    required AnimationController controller,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
    Curve curve = Curves.easeIn,
  }) {
    final animation = AnimationUtils.createFadeAnimation(
      controller: controller,
      beginOpacity: beginOpacity,
      endOpacity: endOpacity,
      curve: curve,
    );

    return FadeTransition(
      opacity: animation,
      child: this,
    );
  }

  Widget withSlideAnimation({
    required AnimationController controller,
    Offset beginOffset = const Offset(1.0, 0.0),
    Offset endOffset = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    final animation = AnimationUtils.createSlideAnimation(
      controller: controller,
      beginOffset: beginOffset,
      endOffset: endOffset,
      curve: curve,
    );

    return SlideTransition(
      position: animation,
      child: this,
    );
  }

  Widget withPulseAnimation({
    required AnimationController controller,
    double beginScale = 1.0,
    double endScale = 1.2,
  }) {
    final animation = AnimationUtils.createPulseAnimation(
      controller: controller,
      beginScale: beginScale,
      endScale: endScale,
    );

    return ScaleTransition(
      scale: animation,
      child: this,
    );
  }
}
