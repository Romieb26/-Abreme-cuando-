import 'dart:math';
import 'package:flutter/material.dart';

/// Barritas tipo ecualizador que "bailan" una sola vez al montar el
/// widget, simulando actividad de audio durante la transmisión.
class EqualizerBars extends StatefulWidget {
  final Color color;
  final int barCount;
  final double maxHeight;

  const EqualizerBars({
    super.key,
    required this.color,
    this.barCount = 5,
    this.maxHeight = 16,
  });

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final List<double> _freq = List.generate(
    widget.barCount,
    (i) => 3.0 + i * 1.3,
  );
  late final List<double> _phase = List.generate(
    widget.barCount,
    (i) => Random(i * 13 + 3).nextDouble() * pi,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final envelope = sin(pi * t).clamp(0.0, 1.0); // sube y baja, 0 en los extremos
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.barCount, (i) {
            final wave = 0.5 + 0.5 * sin(2 * pi * _freq[i] * t + _phase[i]);
            final h = 3.0 + (widget.maxHeight - 3.0) * envelope * wave;
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.85),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}
