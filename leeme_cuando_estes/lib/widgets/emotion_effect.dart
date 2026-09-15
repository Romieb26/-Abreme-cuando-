import 'dart:math';
import 'package:flutter/material.dart';
import '../models/letter_model.dart';

/// Overlay de partículas/efecto especial que se dispara una sola vez al
/// abrir una carta, según su [LetterEffect]. Se dibuja encima de todo,
/// no bloquea toques (IgnorePointer).
class EmotionFx extends StatefulWidget {
  final LetterEffect type;
  final Color color;

  const EmotionFx({super.key, required this.type, required this.color});

  @override
  State<EmotionFx> createState() => _EmotionFxState();
}

class _EmotionFxState extends State<EmotionFx>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  late final List<_Particle> _particles = List.generate(
    widget.type == LetterEffect.hearts ? 16 : 26,
    (i) {
      final rnd = Random(i * 17 + 9);
      return _Particle(
        x: rnd.nextDouble(),
        y0: rnd.nextDouble(),
        delay: rnd.nextDouble() * 0.4,
        size: 3 + rnd.nextDouble() * 5,
        sway: rnd.nextDouble(),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    // Pequeño retraso para que se vea justo cuando llega la transmisión.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          if (t >= 1.0 && widget.type != LetterEffect.shake) {
            return const SizedBox.shrink();
          }
          return CustomPaint(
            painter: _EmotionPainter(
              type: widget.type,
              color: widget.color,
              t: t,
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y0;
  final double delay;
  final double size;
  final double sway;
  _Particle({
    required this.x,
    required this.y0,
    required this.delay,
    required this.size,
    required this.sway,
  });
}

class _EmotionPainter extends CustomPainter {
  final LetterEffect type;
  final Color color;
  final double t;
  final List<_Particle> particles;

  _EmotionPainter({
    required this.type,
    required this.color,
    required this.t,
    required this.particles,
  });

  double _local(double delay) => ((t - delay) / (1 - delay)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case LetterEffect.sparkle:
        _paintSparkle(canvas, size);
        break;
      case LetterEffect.rain:
        _paintRain(canvas, size);
        break;
      case LetterEffect.hearts:
        _paintHearts(canvas, size);
        break;
      case LetterEffect.shake:
        _paintFlash(canvas, size);
        break;
    }
  }

  void _paintSparkle(Canvas canvas, Size size) {
    final originX = size.width * 0.5;
    final originY = size.height * 0.22;
    for (final p in particles) {
      final lt = _local(p.delay * 0.5);
      if (lt <= 0) continue;
      final angle = p.x * 2 * pi;
      final dist = lt * (size.shortestSide * 0.55) * (0.4 + p.sway);
      final dx = originX + cos(angle) * dist;
      final dy = originY + sin(angle) * dist * 0.6 - lt * 40;
      final fade = (1 - lt).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withOpacity(0.85 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - lt * 0.4), paint);
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    for (final p in particles) {
      final lt = _local(p.delay * 0.3);
      if (lt <= 0) continue;
      final dx = p.x * size.width;
      final dy = lt * size.height * 1.1 - size.height * 0.1;
      final fade = lt < 0.85 ? 1.0 : (1 - lt) / 0.15;
      final paint = Paint()
        ..color = color.withOpacity(0.6 * fade.clamp(0.0, 1.0))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(dx, dy), Offset(dx, dy + 14), paint);
    }
  }

  void _paintHearts(Canvas canvas, Size size) {
    for (final p in particles) {
      final lt = _local(p.delay * 0.5);
      if (lt <= 0) continue;
      final dx = p.x * size.width + sin(lt * 2 * pi + p.sway * 10) * 16;
      final dy = size.height * (1.05 - lt * 1.15) + p.y0 * 40;
      final fade = lt < 0.75 ? lt / 0.25 : (1 - lt) / 0.25;
      _drawHeart(canvas, Offset(dx, dy), p.size * 1.6, color.withOpacity(0.8 * fade.clamp(0.0, 1.0)));
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double s, Color c) {
    final path = Path();
    path.moveTo(center.dx, center.dy + s * 0.35);
    path.cubicTo(
      center.dx - s * 1.1, center.dy - s * 0.6,
      center.dx - s * 0.4, center.dy - s * 1.3,
      center.dx, center.dy - s * 0.4,
    );
    path.cubicTo(
      center.dx + s * 0.4, center.dy - s * 1.3,
      center.dx + s * 1.1, center.dy - s * 0.6,
      center.dx, center.dy + s * 0.35,
    );
    path.close();
    canvas.drawPath(path, Paint()..color = c);
  }

  void _paintFlash(Canvas canvas, Size size) {
    // Destello breve rojo/naranja que decae rápido.
    final envelope = (1 - (t / 0.4)).clamp(0.0, 1.0);
    if (envelope <= 0) return;
    final paint = Paint()..color = color.withOpacity(0.22 * envelope);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _EmotionPainter oldDelegate) => oldDelegate.t != t;
}
