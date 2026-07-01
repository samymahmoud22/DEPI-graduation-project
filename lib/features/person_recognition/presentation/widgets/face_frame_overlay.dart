import 'dart:math';
import 'package:flutter/material.dart';

/// Draws an oval guide frame on top of the camera preview
/// to help the user align their face.
class FaceFrameOverlay extends StatelessWidget {
  const FaceFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FaceFramePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _FaceFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Oval dimensions — 60% width, 75% height of the container.
    final ovalWidth = size.width * 0.6;
    final ovalHeight = size.height * 0.75;

    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // Semi-transparent dark overlay everywhere except the oval.
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    // Save layer so we can punch a hole with BlendMode.clear.
    canvas.saveLayer(Offset.zero & size, Paint());

    // Draw full dark overlay.
    canvas.drawRect(Offset.zero & size, overlayPaint);

    // Punch the oval hole.
    canvas.drawOval(ovalRect, clearPaint);

    canvas.restore();

    // Draw a thin dashed-style border around the oval.
    final borderPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Draw 4 corner arcs instead of a full oval for a modern look.
    const arcLength = pi / 4; // 45 degrees

    // Top arc
    canvas.drawArc(ovalRect, -pi / 2 - arcLength / 2, arcLength, false, borderPaint);
    // Bottom arc
    canvas.drawArc(ovalRect, pi / 2 - arcLength / 2, arcLength, false, borderPaint);
    // Left arc
    canvas.drawArc(ovalRect, pi - arcLength / 2, arcLength, false, borderPaint);
    // Right arc
    canvas.drawArc(ovalRect, -arcLength / 2, arcLength, false, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
