import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class SettingsAppearanceSection extends StatelessWidget {
  final AppSettings settings;
  final Function(ThemeMode) onThemeModeChanged;
  final Function(AccentColor) onAccentColorChanged;
  final Function(double) onFontSizeChanged;
  final Function(Language) onLanguageChanged;

  const SettingsAppearanceSection({
    super.key,
    required this.settings,
    required this.onThemeModeChanged,
    required this.onAccentColorChanged,
    required this.onFontSizeChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎨 APPEARANCE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Theme Mode
            _buildThemeModeSelector(context),

            const SizedBox(height: 20),

            // Accent Color
            _buildAccentColorSelector(context),

            const SizedBox(height: 20),

            // Font Size
            _buildFontSizeSelector(context),

            const SizedBox(height: 20),

            // Language
            _buildLanguageSelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildThemeModeButton(context, ThemeMode.light, '☀️ Light'),
            const SizedBox(width: 12),
            _buildThemeModeButton(context, ThemeMode.dark, '🌙 Dark'),
            const SizedBox(width: 12),
            _buildThemeModeButton(context, ThemeMode.system, '📱 Auto'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Currently: ${_getThemeModeDisplay(settings.themeMode)}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeButton(BuildContext context, ThemeMode mode, String label) {
    final isSelected = settings.themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => onThemeModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 4)]
                : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            child: Center(child: Text(label)),
          ),
        ),
      ),
    );
  }

  Widget _buildAccentColorSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accent Color',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildColorButton(context, AccentColor.purple, '🟣'),
            _buildColorButton(context, AccentColor.blue, '🔵'),
            _buildColorButton(context, AccentColor.green, '🟢'),
            _buildColorButton(context, AccentColor.red, '🔴'),
            _buildColorButton(context, AccentColor.yellow, '🟡'),
            _buildColorButton(context, AccentColor.custom, '🎨'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${settings.accentColor.name} (${settings.getAccentColor().toString().substring(8, 16).toUpperCase()})',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildColorButton(BuildContext context, AccentColor color, String emoji) {
    final isSelected = settings.accentColor == color;
    final actualColor = color == AccentColor.custom ? settings.customAccentColor : _getColorFromAccent(color);

    return GestureDetector(
      onTap: () => onAccentColorChanged(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 52 : 48,
        height: isSelected ? 52 : 48,
        decoration: BoxDecoration(
          color: actualColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Theme.of(context).dividerColor,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: actualColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 3)]
              : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.2 : 1.0,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Small',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: settings.fontSize,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      onChanged: onFontSizeChanged,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey.shade300,
                    ),
                  ),
                  Text(
                    'Large',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getFontSizeDisplay(settings.fontSize),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Language>(
              value: settings.language,
              isExpanded: true,
              items: Language.values.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(
                    language.getLanguageDisplayName(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '15 languages available',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getThemeModeDisplay(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  Color _getColorFromAccent(AccentColor color) {
    switch (color) {
      case AccentColor.purple:
        return const Color(0xFF8B5CF6);
      case AccentColor.blue:
        return const Color(0xFF3B82F6);
      case AccentColor.green:
        return const Color(0xFF10B981);
      case AccentColor.red:
        return const Color(0xFFEF4444);
      case AccentColor.yellow:
        return const Color(0xFFF59E0B);
      case AccentColor.custom:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getFontSizeDisplay(double size) {
    if (size < 0.9) return 'Small';
    if (size < 1.0) return 'Small-Medium';
    if (size < 1.1) return 'Medium';
    if (size < 1.2) return 'Medium-Large';
    if (size < 1.3) return 'Large';
    return 'Extra Large';
  }
}
