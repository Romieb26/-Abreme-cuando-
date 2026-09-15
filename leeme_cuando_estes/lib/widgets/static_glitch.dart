import 'dart:math';
import 'package:flutter/material.dart';

/// Envuelve a un widget con un destello breve de "estática" (líneas de ruido
/// parpadeantes) al aparecer en pantalla — simula una señal sintonizándose.
/// Se dispara una sola vez, dura ~350ms y luego desaparece por completo.
class StaticGlitch extends StatefulWidget {
  final Widget child;
  const StaticGlitch({super.key, required this.child});

  @override
  State<StaticGlitch> createState() => _StaticGlitchState();
}

class _StaticGlitchState extends State<StaticGlitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.55), weight: 12),
    TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.05), weight: 13),
    TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.4), weight: 12),
    TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0), weight: 63),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_opacity.value <= 0) return const SizedBox.shrink();
                return Opacity(
                  opacity: _opacity.value,
                  child: CustomPaint(painter: _NoisePainter()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  final Random _rnd = Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.55);
    for (double y = 0; y < size.height; y += 3) {
      if (_rnd.nextDouble() > 0.6) {
        final w = _rnd.nextDouble() * size.width;
        canvas.drawRect(Rect.fromLTWH(0, y, w, 1.3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
