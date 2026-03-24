import 'package:flutter/material.dart';

/// A menu item for use within a [GlassMenu].
///
/// [GlassMenuItem] provides a standard layout for menu options, including
/// support for icons, labels, and "destructive" styling. It handles its own
/// hover and tap interactions with liquid glass effects.
class GlassMenuItem extends StatefulWidget {
  /// Creates a glass menu item.
  const GlassMenuItem({
    required this.title,
    required this.onTap,
    super.key,
    this.icon,
    this.leading,
    this.titleStyle,
    this.isDestructive = false,
    this.trailing,
    this.height = 44.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.isSelected = false,
    this.borderRadius,
  });

  /// The primary text of the item.
  final String title;

  /// The text style for the title.
  ///
  /// If not provided, defaults to a standard style.
  final TextStyle? titleStyle;

  /// The icon displayed before the title.
  final IconData? icon;

  /// The icon displayed before the title in widget format for flexibility.
  final Widget? leading;

  /// Callback when the item is tapped.
  final VoidCallback onTap;

  /// Whether this is a destructive action (e.g., Delete).
  ///
  /// Renders with red text and distinct hover effect.
  final bool isDestructive;

  /// A widget to display after the title (e.g., shortcut key).
  final Widget? trailing;

  /// Height of the item.
  ///
  /// Defaults to 44.0 (standard iOS touch target).
  final double height;

  /// Padding inside the item.
  ///
  /// Defaults to horizontal padding of 16.
  final EdgeInsetsGeometry padding;

  // Whether this item is currently selected (for stateful menus).
  final bool isSelected;

  /// Border radius for the item.
  ///
  /// If not provided, defaults to 10 for a soft rounded look.
  final BorderRadius? borderRadius;

  @override
  State<GlassMenuItem> createState() => _GlassMenuItemState();
}

class _GlassMenuItemState extends State<GlassMenuItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Performance: Cache static colors to avoid recalculation on every build
    final Color textColor = widget.isDestructive
        ? const Color(0xFFEF5350) // Colors.red.shade400 cached
        : const Color(0xE6FFFFFF); // Colors.white.withValues(alpha: 0.9) cached

    final Color iconColor = widget.isDestructive
        ? const Color(0xFFEF5350)
        : const Color(0xB3FFFFFF); // Colors.white.withValues(alpha: 0.7) cached

    // Dynamic background for hover/press/selected states
    // We use a subtle white overlay to "brighten" the glass
    final Color backgroundColor = _isPressed || widget.isSelected
        ? const Color(0x26FFFFFF) // alpha: 0.15
        : _isHovered
            ? const Color(0x1AFFFFFF) // alpha: 0.1
            : Colors.transparent;

    // Scale effect on press (subtle squash like iOS buttons)
    final double scale = _isPressed ? 0.98 : 1.0;

    // Performance: RepaintBoundary isolates this item from siblings
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic, // Closer to spring feel than easeOut
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic, // iOS-style spring approximation
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
              ),
              child: Row(
                spacing: 12,
                children: [
                  // Icon
                  if (widget.icon != null || widget.leading != null) ...[
                    widget.leading ??
                        Icon(
                          widget.icon,
                          size: 20,
                          color: iconColor,
                        ),
                  ],

                  // Title
                  Expanded(
                    child: Text(
                      widget.title,
                      style: widget.titleStyle ??
                          TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),

                  // Trailing
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
