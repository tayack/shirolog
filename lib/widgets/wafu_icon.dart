import 'package:flutter/material.dart';

enum WafuIconType { tenshu, record, logSearch, mission, kabuto, gunbai }

class WafuIcon extends StatelessWidget {
  final String assetName;
  final WafuIconType fallbackType;
  final Color color;
  final double size;

  const WafuIcon({
    super.key,
    required this.assetName,
    required this.fallbackType,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/$assetName.png',
      width: size,
      height: size,
      color: color,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => CustomPaint(
        size: Size(size, size),
        painter: _WafuPainter(fallbackType, color),
      ),
    );
  }
}

class _WafuPainter extends CustomPainter {
  final WafuIconType type;
  final Color color;
  _WafuPainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    switch (type) {
      case WafuIconType.tenshu:
        path.moveTo(size.width * 0.5, 0);
        path.lineTo(size.width * 0.1, size.height * 0.4);
        path.lineTo(size.width * 0.9, size.height * 0.4);
        path.close();
        path.addRect(
          Rect.fromLTWH(
            size.width * 0.2,
            size.height * 0.45,
            size.width * 0.6,
            size.height * 0.55,
          ),
        );
        break;
      case WafuIconType.gunbai:
        path.addOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.4),
            width: size.width * 0.7,
            height: size.height * 0.7,
          ),
        );
        path.addRect(
          Rect.fromLTWH(
            size.width * 0.45,
            size.height * 0.7,
            size.width * 0.1,
            size.height * 0.3,
          ),
        );
        break;
      case WafuIconType.kabuto:
        path.moveTo(size.width * 0.2, size.height * 0.8);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.1,
          size.width * 0.8,
          size.height * 0.8,
        );
        break;
      case WafuIconType.record:
        path.addRect(
          Rect.fromLTWH(
            size.width * 0.2,
            size.height * 0.1,
            size.width * 0.1,
            size.height * 0.8,
          ),
        );
        break;
      case WafuIconType.logSearch:
        canvas.drawCircle(
          Offset(size.width * 0.4, size.height * 0.4),
          size.width * 0.3,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        break;
      default:
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
