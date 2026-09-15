import 'package:flutter/material.dart';
import '../main.dart';
import '../services/sound_service.dart';
import '../widgets/hud_background.dart';
import '../widgets/hud_route.dart';
import 'home_screen.dart';

/// Pantalla de "arranque de sistema" que se muestra una vez, al abrir
/// la app, antes de llegar al menú. Barra de carga + líneas de log que
/// van apareciendo, estilo boot de una consola/HUD.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 2400);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _totalDuration,
  );

  static const _lines = [
    'Inicializando sistema...',
    'Estableciendo canal seguro...',
    'Cargando transmisiones... [10/10]',
    'Acceso concedido.',
  ];

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    SoundService.instance.playBoot();
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goHome();
      }
    });
  }

  void _goHome() {
    if (_navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(hudRoute(const HomeScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HudColors.bg,
      body: HudBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Toca para saltar la intro.
            _controller.value = 1.0;
          },
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulsingMark(progress: t),
                        const SizedBox(height: 22),
                        Text(
                          'LÉEME CUANDO ESTÉS...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            color: HudColors.cyan.withOpacity(
                              (t / 0.12).clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_lines.length, (i) {
                              final threshold = 0.2 + i * 0.18;
                              final visible = t >= threshold;
                              final isLast = i == _lines.length - 1;
                              return AnimatedOpacity(
                                opacity: visible ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    '> ${_lines[i]}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      letterSpacing: 0.5,
                                      color: isLast
                                          ? HudColors.gold
                                          : HudColors.textMuted,
                                      fontWeight:
                                          isLast ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 26),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 5,
                            width: double.infinity,
                            color: HudColors.cyan.withOpacity(0.15),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: t.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: HudColors.cyan,
                                    boxShadow: [
                                      BoxShadow(
                                        color: HudColors.cyan.withOpacity(0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(t * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            color: HudColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícono/marca central que late suavemente mientras carga.
class _PulsingMark extends StatelessWidget {
  final double progress;
  const _PulsingMark({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pulse = 0.75 + 0.25 * (0.5 + 0.5 * (progress * 6).remainder(1.0));
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: HudColors.cyan.withOpacity(0.7), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: HudColors.cyan.withOpacity(0.35 * pulse),
            blurRadius: 18 * pulse,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.mail_outline, color: HudColors.cyan, size: 24),
    );
  }
}
