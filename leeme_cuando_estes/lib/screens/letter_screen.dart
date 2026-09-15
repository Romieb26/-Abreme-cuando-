import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/letter_model.dart';
import '../services/sound_service.dart';
import '../widgets/hud_frame.dart';
import '../widgets/hud_background.dart';
import '../widgets/static_glitch.dart';
import '../widgets/equalizer_bars.dart';
import '../widgets/emotion_effect.dart';

class LetterScreen extends StatefulWidget {
  final Letter letter;

  const LetterScreen({super.key, required this.letter});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
  ));
  late final Animation<double> _signal = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
  );

  // Controlador aparte para el temblor de pantalla (solo emociones "shake").
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    SoundService.instance.playTransmission();
    _controller.forward();
    if (widget.letter.effect == LetterEffect.shake) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _shake.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letter = widget.letter;
    return Scaffold(
      backgroundColor: HudColors.bg,
      appBar: AppBar(
        backgroundColor: HudColors.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: letter.color),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            SoundService.instance.playClose();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          letter.emotion.toUpperCase(),
          style: TextStyle(
            color: letter.color,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: letter.color.withOpacity(0.6)),
        ),
      ),
      body: Stack(
        children: [
          HudBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: StaticGlitch(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedBuilder(
                            animation: _shake,
                            builder: (context, child) {
                              final decay = 1 - _shake.value;
                              final dx = sin(_shake.value * 40) * decay * 8;
                              return Transform.translate(
                                offset: Offset(dx, 0),
                                child: child,
                              );
                            },
                            child: HudFrame(
                              accent: letter.color,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      HudStatusDot(color: letter.color),
                                      const SizedBox(width: 8),
                                      Text(
                                        'TRANSMISIÓN RECIBIDA',
                                        style: TextStyle(
                                          color: HudColors.textMuted,
                                          fontSize: 11,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      EqualizerBars(color: letter.color),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: letter.color.withOpacity(0.16),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: letter.color, width: 1.4),
                                        ),
                                        child: Icon(letter.icon, color: letter.color, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          letter.title.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            height: 1.3,
                                            color: HudColors.textLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Container(height: 1, color: letter.color.withOpacity(0.25)),
                                  const SizedBox(height: 18),
                                  Text(
                                    letter.body,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      height: 1.7,
                                      color: HudColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _SignalMeter(color: letter.color, progress: _signal),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: EmotionFx(type: letter.effect, color: letter.color),
          ),
        ],
      ),
    );
  }
}

/// Barra tipo "integridad de señal" que se llena con animación al abrir
/// la carta, con su porcentaje en vivo. Puro detalle decorativo de HUD.
class _SignalMeter extends StatelessWidget {
  final Color color;
  final Animation<double> progress;

  const _SignalMeter({required this.color, required this.progress});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final value = progress.value.clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INTEGRIDAD DE SEÑAL',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: HudColors.textMuted,
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                color: color.withOpacity(0.15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
