import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../data/letters_data.dart';
import '../services/sound_service.dart';
import '../widgets/hud_frame.dart';
import '../widgets/hud_background.dart';
import '../widgets/hud_route.dart';
import 'letter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HudColors.bg,
      body: HudBackground(
        child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HudFrame(
                accent: HudColors.cyan,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HudStatusDot(color: HudColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          'CANAL SEGURO ACTIVO',
                          style: TextStyle(
                            color: HudColors.textMuted,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'LÉEME CUANDO ESTÉS...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: HudColors.cyan,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '// SELECCIONA TU ESTADO EMOCIONAL',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: HudColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SignalBars(count: letters.length),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: letters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final letter = letters[index];
                  return _EmotionTile(
                    index: index + 1,
                    delayMs: index * 60,
                    label: letter.emotion,
                    color: letter.color,
                    icon: letter.icon,
                    onTap: () async {
                      await SoundService.instance.playTap();
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        hudRoute(LetterScreen(letter: letter)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Fila de barritas tipo "canales / señal" que muestra cuántas
/// transmisiones (cartas) hay disponibles. Detalle puramente decorativo.
class _SignalBars extends StatelessWidget {
  final int count;
  const _SignalBars({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(count, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 4,
            height: 6 + (i % 4) * 3.0,
            decoration: BoxDecoration(
              color: HudColors.cyan.withOpacity(0.7),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$count TRANSMISIONES',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            color: HudColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmotionTile extends StatefulWidget {
  final int index;
  final int delayMs;
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _EmotionTile({
    required this.index,
    required this.delayMs,
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_EmotionTile> createState() => _EmotionTileState();
}

class _EmotionTileState extends State<_EmotionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) {
            setState(() => _pressed = false);
            HapticFeedback.selectionClick();
          },
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: HudColors.panel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.color.withOpacity(_pressed ? 0.9 : 0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_pressed ? 0.25 : 0.10),
                    blurRadius: _pressed ? 16 : 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    widget.index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: HudColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: widget.color.withOpacity(0.7), width: 1.2),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 19),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: HudColors.textLight,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: widget.color.withOpacity(0.9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
