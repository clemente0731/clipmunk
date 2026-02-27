import 'package:flutter/material.dart';
import '../../core/constants.dart';

// =============================================================================
// reusable retro-futurism 16-bit widgets
//
// pixel-perfect 1px borders, flat surfaces, LED indicators,
// monospace text, grid-aligned spacing, no shadows/blur/radius
// =============================================================================

/// panel container with 1px border - the core building block
class RetroPanel extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool hasBorder;

  const RetroPanel({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Palette.bgPanel,
        border: hasBorder
            ? Border.all(color: borderColor ?? Palette.border, width: 1)
            : null,
      ),
      child: child,
    );
  }
}

/// section header with dot prefix: "◆ TITLE"
class RetroSectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const RetroSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Grid.x2),
      child: Row(
        children: [
          Text(
            '◆',
            style: Typo.caption.copyWith(color: Palette.cyan, fontSize: 8),
          ),
          const SizedBox(width: Grid.x2),
          Text(
            title.toUpperCase(),
            style: Typo.tiny.copyWith(
              color: Palette.textSecondary,
              letterSpacing: 2.0,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: Typo.tiny.copyWith(color: Palette.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

/// horizontal 1px divider line
class RetroDivider extends StatelessWidget {
  final Color? color;

  const RetroDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color ?? Palette.border,
    );
  }
}

/// LED status indicator dot
class RetroLed extends StatelessWidget {
  final bool active;
  final Color? activeColor;
  final double size;

  const RetroLed({
    super.key,
    this.active = false,
    this.activeColor,
    this.size = 6,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (activeColor ?? Palette.statusActive)
        : Palette.statusInactive;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: active ? color.withOpacity(0.4) : Palette.border,
          width: 1,
        ),
      ),
    );
  }
}

/// flat button with 1px border - retro style
class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool compact;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.compact = false,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final accentColor = widget.color ?? Palette.cyan;
    final textColor = isEnabled
        ? (_hovering ? Palette.bg : accentColor)
        : Palette.textTertiary;
    final bgColor = _hovering && isEnabled ? accentColor : Colors.transparent;
    final borderColor = isEnabled ? accentColor.withOpacity(0.5) : Palette.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? Grid.x2 : Grid.x3,
            vertical: widget.compact ? Grid.x1 : Grid.x2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: Typo.badge.copyWith(
              color: textColor,
              fontSize: widget.compact ? 9 : 10,
            ),
          ),
        ),
      ),
    );
  }
}

/// small index/number badge - pixel-styled
class RetroBadge extends StatelessWidget {
  final String text;
  final bool active;
  final Color? activeColor;

  const RetroBadge({
    super.key,
    required this.text,
    this.active = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? Palette.cyan) : Palette.textTertiary;

    return Container(
      width: Grid.x5,
      height: Grid.x5,
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : Colors.transparent,
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Center(
        child: Text(
          text,
          style: Typo.badge.copyWith(
            color: color,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

/// hotkey display chip - monospace bordered label
class RetroHotkeyChip extends StatelessWidget {
  final String label;

  const RetroHotkeyChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Grid.x2,
        vertical: Grid.x1,
      ),
      decoration: BoxDecoration(
        color: Palette.bgElevated,
        border: Border.all(color: Palette.border, width: 1),
      ),
      child: Text(
        label,
        style: Typo.tiny.copyWith(
          color: Palette.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// tab bar item for the retro bottom navigation
class RetroTabItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const RetroTabItem({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<RetroTabItem> createState() => _RetroTabItemState();
}

class _RetroTabItemState extends State<RetroTabItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Grid.x4,
            vertical: Grid.x3,
          ),
          decoration: BoxDecoration(
            color: widget.active ? Palette.bgElevated : Colors.transparent,
            border: Border(
              top: BorderSide(
                color: widget.active ? Palette.cyan : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RetroLed(
                active: widget.active,
                activeColor: Palette.cyan,
                size: 5,
              ),
              const SizedBox(width: Grid.x2),
              Text(
                widget.label.toUpperCase(),
                style: Typo.badge.copyWith(
                  color: widget.active
                      ? Palette.cyan
                      : (_hovering ? Palette.textPrimary : Palette.textSecondary),
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// toast notification - retro style
class RetroToast extends StatefulWidget {
  final String message;
  final bool isError;

  const RetroToast({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  State<RetroToast> createState() => _RetroToastState();
}

class _RetroToastState extends State<RetroToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isError ? Palette.statusError : Palette.cyan;

    return Positioned(
      bottom: Grid.x12,
      left: 0,
      right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Grid.x4,
              vertical: Grid.x2,
            ),
            decoration: BoxDecoration(
              color: Palette.bgElevated,
              border: Border.all(color: accentColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RetroLed(active: true, activeColor: accentColor, size: 5),
                const SizedBox(width: Grid.x2),
                Text(
                  widget.message.toUpperCase(),
                  style: Typo.badge.copyWith(
                    color: accentColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
