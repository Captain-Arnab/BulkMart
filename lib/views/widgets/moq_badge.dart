import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Circular dashed "stamp" badge — signature BulkMart element (MOQ / B2B / stock).
class MoqBadge extends StatelessWidget {
  const MoqBadge({
    super.key,
    required this.label,
    this.title = 'MOQ',
    this.size = 42,
    this.color = AppColors.rust,
    this.fontSize = 9,
    this.rotation = -0.16,
  });

  final String label;
  final String title;
  final double size;
  final Color color;
  final double fontSize;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: 0.9),
        ),
        child: CustomPaint(
          painter: _DashedCirclePainter(color: color),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '$title\n$label',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mono(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    const dashCount = 18;
    const gapFactor = 0.35;
    const sweep = (2 * 3.1415926535) / dashCount;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);

    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * sweep, sweep * (1 - gapFactor), false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
