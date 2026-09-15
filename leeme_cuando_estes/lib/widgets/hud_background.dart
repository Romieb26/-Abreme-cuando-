import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';

/// Fondo animado tipo HUD, con varias capas de movimiento:
/// gradiente + resplandores flotantes + barrido de radar + partículas
/// de polvo espacial + cuadrícula deslizante + viñeta.
class HudBackground extends StatefulWidget {
  final Widget child;
  const HudBackground({super.key, required this.child});

  @override
  State<HudBackground> createState() => _HudBackgroundState();
}

class _HudBackgroundState extends State<HudBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  late final List<_Particle> _particles = List.generate(28, (i) {
    final rnd = Random(i * 37 + 5);
    return _Particle(
      x: rnd.nextDouble(),
      phase: rnd.nextDouble(),
      speed: 1 + rnd.nextInt(3), // 1, 2 o 3 — múltiplo entero para loop continuo
      size: 1.4 + rnd.nextDouble() * 2.2,
      swayAmp: 6 + rnd.nextDouble() * 14,
      colorIndex: rnd.nextInt(3),
    );
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradiente base
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B1018),
                  Color(0xFF0D1522),
                  Color(0xFF0A0E14),
                ],
              ),
            ),
          ),
        ),
        // Barrido de radar rotando
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _RadarPainter(angle: _controller.value * 2 * pi),
            ),
          ),
        ),
        // Resplandores flotantes
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * pi;
            return Stack(
              children: [
                Positioned(
                  top: -130 + sin(t) * 26,
                  left: -90 + cos(t * 0.8) * 22,
                  child: _Glow(color: HudColors.cyan.withOpacity(0.18), size: 320),
                ),
                Positioned(
                  bottom: -150 + cos(t) * 30,
                  right: -110 + sin(t * 0.7) * 24,
                  child: _Glow(color: HudColors.gold.withOpacity(0.14), size: 340),
                ),
                Positioned(
                  top: 200 + sin(t * 1.3) * 40,
                  right: -60 + cos(t * 1.1) * 20,
                  child: _Glow(color: const Color(0xFFFF4D6D).withOpacity(0.08), size: 220),
                ),
              ],
            );
          },
        ),
        // Cuadrícula deslizante
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _GridPainter(offset: _controller.value * 32),
            ),
          ),
        ),
        // Partículas flotantes (polvo espacial)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _ParticlePainter(particles: _particles, t: _controller.value),
            ),
          ),
        ),
        // Viñeta para dar profundidad
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.05,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.38),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  final double x;
  final double phase;
  final int speed;
  final double size;
  final double swayAmp;
  final int colorIndex;
  _Particle({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
    required this.swayAmp,
    required this.colorIndex,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter({required this.particles, required this.t});

  static const _colors = [HudColors.cyan, HudColors.gold, Colors.white];

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (1 - ((p.phase + t * p.speed) % 1.0)) * size.height;
      final sway = sin((t * 2 * pi * p.speed) + p.phase * 10) * p.swayAmp;
      final x = p.x * size.width + sway;
      final fade = (sin((p.phase + t * p.speed) % 1.0 * pi)).clamp(0.0, 1.0);
      final color = _colors[p.colorIndex];
      final paint = Paint()
        ..color = color.withOpacity(0.55 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.t != t;
}

class _RadarPainter extends CustomPainter {
  final double angle;
  _RadarPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.18);
    final radius = size.longestSide * 0.9;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: pi / 2,
      transform: GradientRotation(angle),
      colors: [
        HudColors.cyan.withOpacity(0.10),
        HudColors.cyan.withOpacity(0.0),
      ],
    ).createShader(rect);
    final paint = Paint()..shader = shader;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.angle != angle;
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double offset;
  _GridPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF4FE3FF).withOpacity(0.05)
      ..strokeWidth = 1;
    const step = 32.0;

    for (double x = -step + offset; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = -step + offset; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final accentPaint = Paint()
      ..color = const Color(0xFFFFC857).withOpacity(0.06)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(0, size.height * 0.18 + offset * 0.3),
      Offset(size.width, size.height * 0.06 + offset * 0.3),
      accentPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.82 - offset * 0.3),
      Offset(size.width, size.height * 0.94 - offset * 0.3),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.offset != offset;
}
