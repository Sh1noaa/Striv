import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'strive_theme.dart';

class Strive3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color? lipColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double lipHeight;
  final bool fullWidth;

  const Strive3DButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = StriveColors.emerald,
    this.lipColor,
    this.textColor = Colors.white,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.lipHeight = 5.0,
    this.fullWidth = false,
  });

  @override
  State<Strive3DButton> createState() => _Strive3DButtonState();
}

class _Strive3DButtonState extends State<Strive3DButton> {
  bool _isPressed = false;

  Color _computeDarkerLip(Color base) {
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness((hsl.lightness - 0.14).clamp(0.05, 0.9))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final faceColor = disabled ? Colors.grey.shade600 : widget.color;
    final bottomLipColor = disabled
        ? Colors.grey.shade800
        : (widget.lipColor ?? _computeDarkerLip(widget.color));

    final pressOffset = (_isPressed && !disabled) ? 4.0 : 0.0;
    final remainingLip =
        (widget.lipHeight - pressOffset).clamp(1.0, widget.lipHeight);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: disabled
          ? null
          : (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            },
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: disabled
          ? null
          : () {
              setState(() => _isPressed = false);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        width: widget.fullWidth ? double.infinity : null,
        margin: EdgeInsets.only(top: pressOffset),
        padding: EdgeInsets.only(bottom: remainingLip),
        decoration: BoxDecoration(
          color: bottomLipColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: faceColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.2,
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: widget.textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: widget.textColor, size: 20),
              child: Center(
                widthFactor: widget.fullWidth ? null : 1.0,
                heightFactor: 1.0,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Strive3DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const Strive3DCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 20.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? StriveColors.darkCard : StriveColors.lightCard);
    final bdr = borderColor ??
        (isDark ? StriveColors.darkBorder : StriveColors.lightBorder);

    final content = Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: bdr,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: bdr, width: 2),
        ),
        child: child,
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: content,
    );
  }
}

class Strive3DChoiceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const Strive3DChoiceTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.selected,
    this.activeColor = StriveColors.sky,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? activeColor
        : (isDark ? StriveColors.darkBorder : StriveColors.lightBorder);
    final bgColor = selected
        ? activeColor.withValues(alpha: isDark ? 0.18 : 0.12)
        : (isDark ? StriveColors.darkCard : StriveColors.lightCard);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: activeColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: selected
                            ? activeColor
                            : StriveColors.textPrimary(context),
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: StriveColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? activeColor
                      : StriveColors.textSecondary(context),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
