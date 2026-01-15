

import 'dart:math';
import 'package:flutter/material.dart';

class BlazingBorderButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double borderRadius;
  final double strokeWidth;

  const BlazingBorderButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 16,
    this.strokeWidth = 3,
  });

  @override
  State<BlazingBorderButton> createState() => _BlazingBorderButtonState();
}

class _BlazingBorderButtonState extends State<BlazingBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _GlowBorderPainter(
            progress: _controller.value,
            strokeWidth: widget.strokeWidth,
            radius: widget.borderRadius,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.strokeWidth),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius),
                ),
              ),
              onPressed: widget.onPressed,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}


class _GlowBorderPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double radius;

  _GlowBorderPainter({
    required this.progress,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: GradientRotation(2 * pi * progress),
      colors: const [
        Colors.orange,
        Colors.red,
        Colors.pink,
        Colors.deepOrange,
        Colors.orange,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

    final rRect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



//  