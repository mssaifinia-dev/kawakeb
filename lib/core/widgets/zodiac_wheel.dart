import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// یک چرخ زودیاک طلایی متحرک — ۱۲ نماد برج دور یه مرکز می‌چرخند،
/// شبیه افکت گردش عقربه‌ی ساعت که تو تصاویر فال‌های معروف دیده می‌شه.
class ZodiacWheel extends StatefulWidget {
  final double size;
  final IconData centerIcon;

  const ZodiacWheel({
    super.key,
    this.size = 200,
    this.centerIcon = Icons.nightlight_round,
  });

  @override
  State<ZodiacWheel> createState() => _ZodiacWheelState();
}

class _ZodiacWheelState extends State<ZodiacWheel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<String> _symbols = [
    '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size / 2 - (widget.size * 0.11);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // هاله‌ی نور پشت چرخ
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.gold.withOpacity(0.18), Colors.transparent],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          // حلقه‌ی بیرونی ثابت
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
            ),
          ),
          // حلقه‌ی نمادها (متحرک)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(_symbols.length, (index) {
                      final angle = (2 * pi / _symbols.length) * index;
                      final dx = radius * cos(angle);
                      final dy = radius * sin(angle);
                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Text(
                          _symbols[index],
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: widget.size * 0.09,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 8),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
          // نقطه‌های ریز بین نمادها (حلقه‌ی داخلی، چرخش کندتر و برعکس)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_controller.value * 2 * pi * 0.4,
                child: Container(
                  width: widget.size * 0.78,
                  height: widget.size * 0.78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
          // مرکز درخشان با آیکون
          Container(
            width: widget.size * 0.4,
            height: widget.size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.gold.withOpacity(0.28), Colors.transparent],
              ),
              border: Border.all(color: AppColors.gold.withOpacity(0.4)),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFE9A8), AppColors.gold],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Icon(widget.centerIcon, color: Colors.white, size: widget.size * 0.17),
            ),
          ),
        ],
      ),
    );
  }
}
