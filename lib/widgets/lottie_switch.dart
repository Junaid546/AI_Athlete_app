import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const LottieSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 60,
    this.height = 30,
  });

  @override
  State<LottieSwitch> createState() => _LottieSwitchState();
}

class _LottieSwitchState extends State<LottieSwitch> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(LottieSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if value has changed
    if (oldWidget.value != widget.value && !_isAnimating) {
      _playAnimation(widget.value);
    }
  }

  void _playAnimation(bool isOn) async {
    _isAnimating = true;

    try {
      if (isOn) {
        // Play forward to show "ON"
        await _controller.forward(from: 0.0);
      } else {
        // Play backward to show "OFF"
        await _controller.reverse(from: 1.0);
      }
    } catch (e) {
      // Handle animation errors gracefully
    debugPrint('Animation error: $e');
    } finally {
      if (mounted) {
        _isAnimating = false;
      }
    }
  }

  void _handleTap() {
    if (!_isAnimating && widget.onChanged != null) {
      final newValue = !widget.value;
      widget.onChanged!(newValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Lottie.asset(
          'assets/lottie/on_off_switch.json',
          controller: _controller,
          frameRate: FrameRate(60),
          repeat: false,
          animate: false,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            
            // Set initial position based on current value
            if (widget.value) {
              _controller.value = 1.0; // Show ON state
            } else {
              _controller.value = 0.0; // Show OFF state
            }
            
            // Mark as ready for interaction after composition loads
            if (mounted) {
              setState(() {
                _isAnimating = false;
              });
            }
          },
        ),
      ),
    );
  }
}
