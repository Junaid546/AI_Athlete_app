import 'package:flutter/material.dart';

/// Enhanced custom switch widget with better animation and accessibility
class EnhancedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String? activeLabel;
  final String? inactiveLabel;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final double? width;
  final double? height;
  final Duration animationDuration;

  const EnhancedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.activeLabel,
    this.inactiveLabel,
    this.activeIcon,
    this.inactiveIcon,
    this.width,
    this.height,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<EnhancedSwitch> createState() => _EnhancedSwitchState();
}

class _EnhancedSwitchState extends State<EnhancedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.value) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(EnhancedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? 70.0;
    final height = widget.height ?? 40.0;
    final radius = height / 2;

    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _colorAnimation.value ?? widget.inactiveColor,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: (_colorAnimation.value ?? widget.inactiveColor)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background label
                if (widget.activeLabel != null || widget.inactiveLabel != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.inactiveLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              widget.inactiveLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (widget.activeLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              widget.activeLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Sliding circle
                Positioned(
                  left: _positionAnimation.value * (width - height),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: widget.value && widget.activeIcon != null
                            ? Icon(
                                widget.activeIcon,
                                color: widget.activeColor,
                                size: height * 0.5,
                                key: ValueKey('active'),
                              )
                            : widget.inactiveIcon != null
                                ? Icon(
                                    widget.inactiveIcon,
                                    color: widget.inactiveColor,
                                    size: height * 0.5,
                                    key: ValueKey('inactive'),
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Material Design 3 inspired switch
class Material3Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final Widget? leadingIcon;
  final bool enabled;

  const Material3Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.leadingIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 12),
              ],
              if (label != null) ...[
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? null
                        : (isDark ? Colors.white30 : Colors.black26),
                  ),
                ),
                const Spacer(),
              ],
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.grey.shade600,
                inactiveTrackColor: isDark ? Colors.white10 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle button group for selecting between options
class ToggleButtonGroup extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final IconData? Function(String)? iconBuilder;

  const ToggleButtonGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: options
            .map(
              (option) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: selectedOption == option
                          ? activeColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconBuilder != null) ...[
                          Icon(
                            iconBuilder!(option),
                            size: 16,
                            color: selectedOption == option
                                ? Colors.white
                                : inactiveColor,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          option,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selectedOption == option
                                ? Colors.white
                                : inactiveColor,
                            fontWeight: selectedOption == option
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
