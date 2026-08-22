import 'package:flutter/material.dart';

import '../../models/product.dart';

/// Produce-themed category icon (leaf / carrot / apple / herb sprig).
/// Prefer this over Material farm/flower icons which read as tractor / florist.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.categoryId,
    this.size = 24,
    this.color,
  });

  final String categoryId;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black87;

    // "All" keeps the Material grid — everything else is a produce glyph.
    if (categoryId == 'all') {
      return Icon(Icons.grid_view_rounded, size: size, color: c);
    }

    final painter = switch (categoryId) {
      '1' || 'green_vegetables' => _LeafPainter(c),
      '2' || 'root_vegetables' => _CarrotPainter(c),
      '3' || 'seasonal_fruits' => _ApplePainter(c),
      '4' || 'herbs_leafy' => _HerbPainter(c),
      _ => _LeafPainter(c),
    };

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: painter),
    );
  }
}

String categoryShortLabel(ProductCategory cat) {
  return switch (cat.id) {
    'all' => 'All',
    '1' || 'green_vegetables' => 'Greens',
    '2' || 'root_vegetables' => 'Roots',
    '3' || 'seasonal_fruits' => 'Fruits',
    '4' || 'herbs_leafy' => 'Herbs',
    _ => cat.name.split(RegExp(r'[\s&]+')).first,
  };
}

// ── Painters ────────────────────────────────────────────────────────────────

class _LeafPainter extends CustomPainter {
  _LeafPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.22, h * 0.78)
      ..quadraticBezierTo(w * 0.05, h * 0.45, w * 0.48, h * 0.12)
      ..quadraticBezierTo(w * 0.95, h * 0.38, w * 0.78, h * 0.78)
      ..quadraticBezierTo(w * 0.50, h * 0.92, w * 0.22, h * 0.78)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, paint);

    // Midrib
    canvas.drawLine(
      Offset(w * 0.32, h * 0.72),
      Offset(w * 0.62, h * 0.28),
      paint..strokeWidth = size.width * 0.06,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.color != color;
}

class _CarrotPainter extends CustomPainter {
  _CarrotPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Carrot body (tapered triangle)
    final body = Path()
      ..moveTo(w * 0.38, h * 0.32)
      ..lineTo(w * 0.62, h * 0.32)
      ..lineTo(w * 0.50, h * 0.92)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Leafy tops
    final tops = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.50, h * 0.32), Offset(w * 0.32, h * 0.10), tops);
    canvas.drawLine(Offset(w * 0.50, h * 0.32), Offset(w * 0.50, h * 0.06), tops);
    canvas.drawLine(Offset(w * 0.50, h * 0.32), Offset(w * 0.68, h * 0.10), tops);
  }

  @override
  bool shouldRepaint(covariant _CarrotPainter old) => old.color != color;
}

class _ApplePainter extends CustomPainter {
  _ApplePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Apple body
    final body = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..cubicTo(w * 0.18, h * 0.28, w * 0.10, h * 0.72, w * 0.50, h * 0.90)
      ..cubicTo(w * 0.90, h * 0.72, w * 0.82, h * 0.28, w * 0.50, h * 0.28)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Stem
    canvas.drawLine(
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.56, h * 0.12),
      stroke..strokeWidth = size.width * 0.07,
    );

    // Leaf
    final leaf = Path()
      ..moveTo(w * 0.56, h * 0.18)
      ..quadraticBezierTo(w * 0.78, h * 0.08, w * 0.72, h * 0.28)
      ..quadraticBezierTo(w * 0.62, h * 0.26, w * 0.56, h * 0.18);
    canvas.drawPath(leaf, fill);
    canvas.drawPath(leaf, stroke);
  }

  @override
  bool shouldRepaint(covariant _ApplePainter old) => old.color != color;
}

class _HerbPainter extends CustomPainter {
  _HerbPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Main stem
    canvas.drawLine(Offset(w * 0.50, h * 0.92), Offset(w * 0.50, h * 0.28), stroke);

    void leaf(Offset tip, Offset ctrl) {
      final p = Path()
        ..moveTo(w * 0.50, tip.dy + h * 0.08)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(ctrl.dx, tip.dy + h * 0.06, w * 0.50, tip.dy + h * 0.08);
      canvas.drawPath(p, fill);
      canvas.drawPath(p, stroke);
    }

    leaf(Offset(w * 0.22, h * 0.38), Offset(w * 0.28, h * 0.52));
    leaf(Offset(w * 0.78, h * 0.32), Offset(w * 0.72, h * 0.48));
    leaf(Offset(w * 0.28, h * 0.18), Offset(w * 0.36, h * 0.30));
    leaf(Offset(w * 0.72, h * 0.14), Offset(w * 0.64, h * 0.26));
  }

  @override
  bool shouldRepaint(covariant _HerbPainter old) => old.color != color;
}
