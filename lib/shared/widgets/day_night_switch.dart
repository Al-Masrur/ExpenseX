import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DayNightSwitch extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final double width;
  final double height;

  const DayNightSwitch({
    super.key,
    required this.isDark,
    required this.onToggle,
    this.width = 76,
    this.height = 38,
  });

  @override
  State<DayNightSwitch> createState() => _DayNightSwitchState();
}

class _DayNightSwitchState extends State<DayNightSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isDark ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant DayNightSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    final nextValue = !widget.isDark;
    if (nextValue) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onToggle(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 4.0;
    final double thumbSize = widget.height - (padding * 2);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final t = _animation.value;

          // Track color: Light slate (#F1F5F9) -> Deep Midnight Indigo (#1E1B4B)
          final trackColor = Color.lerp(
            const Color(0xFFF1F5F9),
            const Color(0xFF1E1B4B),
            t,
          )!;

          final borderColor = Color.lerp(
            const Color(0xFFCBD5E1),
            Colors.white.withValues(alpha: 0.15),
            t,
          )!;

          // Thumb color: Dark slate (#1E293B) -> Off-white (#F8FAFC)
          final thumbColor = Color.lerp(
            const Color(0xFF1E293B),
            const Color(0xFFF8FAFC),
            t,
          )!;

          // Alignment: 0.0 is centerRight (Light), 1.0 is centerLeft (Dark)
          final alignment = Alignment.lerp(
            Alignment.centerRight,
            Alignment.centerLeft,
            t,
          )!;

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: trackColor,
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08 + (0.15 * t)),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left Icon: Sun (Visible in light mode)
                Positioned(
                  left: 10,
                  child: Opacity(
                    opacity: (1.0 - (t * 1.5)).clamp(0.0, 1.0),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      size: 18,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),

                // Right Icon: Moon & stars (Visible in dark mode)
                Positioned(
                  right: 9,
                  child: Opacity(
                    opacity: ((t - 0.3) * 1.4).clamp(0.0, 1.0),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.auto_awesome,
                          size: 9,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                // Smooth Sliding Thumb
                Align(
                  alignment: alignment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding),
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: thumbColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
