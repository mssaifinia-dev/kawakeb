import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarFieldBackground extends StatefulWidget {
  final int starCount;
  const StarFieldBackground({super.key, this.starCount = 60});

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    final random = Random();
    _stars = List.generate(widget.starCount, (_) => _Star.random(random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarFieldPainter(_stars, _controller.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _Star {
  final double x, y, radius, phase;
  _Star(this.x, this.y, this.radius, this.phase);
  factory _Star.random(Random r) =>
      _Star(r.nextDouble(), r.nextDouble(), 0.6 + r.nextDouble() * 1.4, r.nextDouble() * pi * 2);
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _StarFieldPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in stars) {
      final opacity = (0.3 + 0.7 * (0.5 + 0.5 * sin(t * pi * 2 + s.phase))).clamp(0.0, 1.0);
      paint.color = AppColors.starColor.withOpacity(opacity);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) => true;
}
