import 'package:flutter/material.dart';

class DayNightSwitch extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const double padding = 4.0;
    final double thumbSize = height - (padding * 2);

    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: isDark
              ? const Color(0xFF1E1B4B) // Deep midnight indigo
              : const Color(0xFFF1F5F9), // Soft crisp slate
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left icon: Sun (visible when thumb moves right in light mode)
            Positioned(
              left: 10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isDark ? 0.0 : 1.0,
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  size: 18,
                  color: Color(0xFF334155), // Charcoal / slate sun like image
                ),
              ),
            ),

            // Right icon: Moon & stars (visible when thumb moves left in dark mode)
            Positioned(
              right: 9,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isDark ? 1.0 : 0.0,
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

            // Smooth sliding thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFFF8FAFC) // Light off-white thumb in dark mode
                        : const Color(0xFF1E293B), // Dark slate thumb in light mode
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

