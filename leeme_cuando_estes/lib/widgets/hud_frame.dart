import 'package:flutter/material.dart';

/// Marco decorativo estilo HUD de sci-fi: esquinas tipo "reticle"
/// sobre un panel oscuro con borde de acento que "respira" (el brillo
/// pulsa lento, como un sistema activo).
class HudFrame extends StatefulWidget {
  final Widget child;
  final Color accent;
  final EdgeInsets padding;
  final Color? background;

  const HudFrame({
    super.key,
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.all(18),
    this.background,
  });

  @override
  State<HudFrame> createState() => _HudFrameState();
}

class _HudFrameState extends State<HudFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final breathe = 0.5 + 0.5 * _controller.value; // 0.5 -> 1.0
            return Container(
              width: double.infinity,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.background ?? const Color(0xFF10151F),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: accent.withOpacity(0.4 + 0.25 * breathe),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.14 + 0.14 * breathe),
                    blurRadius: 14 + 10 * breathe,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: widget.child,
        ),
        Positioned(top: -1, left: -1, child: _Corner(accent: accent)),
        Positioned(
          top: -1,
          right: -1,
          child: Transform.rotate(angle: 1.5708, child: _Corner(accent: accent)),
        ),
        Positioned(
          bottom: -1,
          left: -1,
          child: Transform.rotate(angle: -1.5708, child: _Corner(accent: accent)),
        ),
        Positioned(
          bottom: -1,
          right: -1,
          child: Transform.rotate(angle: 3.1416, child: _Corner(accent: accent)),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final Color accent;
  const _Corner({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(
        painter: _CornerPainter(accent),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.6, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Punto de "estado en línea" con parpadeo real (pulso de opacidad/brillo),
/// típico de un HUD activo.
class HudStatusDot extends StatefulWidget {
  final Color color;
  const HudStatusDot({super.key, required this.color});

  @override
  State<HudStatusDot> createState() => _HudStatusDotState();
}

class _HudStatusDotState extends State<HudStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = 0.5 + 0.5 * _controller.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.6 + 0.4 * t),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * t),
                blurRadius: 4 + 6 * t,
                spreadRadius: 1 + t,
              ),
            ],
          ),
        );
      },
    );
  }
}
