import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;


  final List<String> _labels = ['Home', 'Workouts', 'Progress', 'AI Coach', 'Profile'];
  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.fitness_center_outlined,
    Icons.show_chart_outlined,
    Icons.smart_toy_outlined,
    Icons.person_outline,
  ];
  final List<IconData> _activeIcons = [
    Icons.home,
    Icons.fitness_center,
    Icons.show_chart,
    Icons.smart_toy,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    // Position animation will be managed by AnimationController
  }

  @override
  void didUpdateWidget(BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orientation = MediaQuery.of(context).orientation;


    final height = orientation == Orientation.landscape ? 65.0 : 80.0;

    return Container(
      height: height,
      margin: orientation == Orientation.landscape
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = widget.currentIndex == index;

              return GestureDetector(
                onTap: () => widget.onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.15)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          isSelected ? _activeIcons[index] : _icons[index],
                          color: isSelected
                              ? AppTheme.primaryColor
                              : isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.6),
                          size: isSelected ? 24 : 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.black.withOpacity(0.5),
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(_labels[index]),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
