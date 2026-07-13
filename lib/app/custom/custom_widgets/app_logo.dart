import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: themeColor),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;
    final double center = w / 2;

    // 1. Draw the purple Hexagon/Shield background
    final path = Path();
    path.moveTo(center, 0); // Top center
    path.lineTo(w, h * 0.25); // Top right
    path.lineTo(w, h * 0.75); // Bottom right
    path.lineTo(center, h); // Bottom center (pointy)
    path.lineTo(0, h * 0.75); // Bottom left
    path.lineTo(0, h * 0.25); // Top left
    path.close();
    canvas.drawPath(path, paint);

    // 2. Draw the White Intertwined Design
    // Top Diamond
    final diamondPath = Path();
    diamondPath.moveTo(center, h * 0.15); // Top of diamond
    diamondPath.lineTo(w * 0.8, h * 0.35); // Right
    diamondPath.lineTo(center, h * 0.55); // Bottom
    diamondPath.lineTo(w * 0.2, h * 0.35); // Left
    diamondPath.close();
    canvas.drawPath(diamondPath, whitePaint);

    // Bottom Circle
    canvas.drawCircle(
      Offset(center, h * 0.65),
      w * 0.22,
      whitePaint,
    );

    // Connecting "V" / Checkmark to match image
    final vPath = Path();
    vPath.moveTo(w * 0.35, h * 0.45);
    vPath.lineTo(center, h * 0.6);
    vPath.lineTo(w * 0.65, h * 0.45);
    // Note: To perfectly match the "intertwined" look, we draw lines over parts
    canvas.drawPath(vPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
