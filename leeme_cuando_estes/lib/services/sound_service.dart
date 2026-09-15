import 'package:audioplayers/audioplayers.dart';

/// Reproduce los efectos de sonido del HUD (blip de menú y
/// chime de "transmisión recibida" al abrir una carta).
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> playTap() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/tap.wav'), volume: 0.6);
    } catch (_) {
      // Si el audio falla (p.ej. plataforma sin soporte), la app sigue
      // funcionando en silencio sin interrumpir la navegación.
    }
  }

  Future<void> playTransmission() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/transmission.wav'), volume: 0.7);
    } catch (_) {
      // Igual que arriba: falla en silencio.
    }
  }

  /// Barrido de "encendido de HUD" al abrir la app.
  Future<void> playBoot() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/boot.wav'), volume: 0.55);
    } catch (_) {}
  }

  /// Tono corto al cerrar una carta / volver al menú.
  Future<void> playClose() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/close.wav'), volume: 0.5);
    } catch (_) {}
  }
}
