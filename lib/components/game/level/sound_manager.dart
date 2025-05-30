import 'dart:async';

import 'package:flame_audio/flame_audio.dart' as flame;
import 'package:just_audio/just_audio.dart';

import '../../bbdd/models/settings.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();

  factory SoundManager() => _instance;

  SoundManager._internal();

  final Map<String, AudioPlayer> _players = {};
  final Duration _jumpCooldown = const Duration(milliseconds: 100);
  DateTime? _lastJump;
  Timer? _rockheadLoopTimer;
  bool _initialized = false;

  int mutedVolume = 1;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _load('collect_fruit', 'assets/audio/collect_fruit.wav');
    await _load('disappear', 'assets/audio/disappear.wav');
    await _load('jump', 'assets/audio/jump.wav');
    await _load('hit', 'assets/audio/hit.wav');
    await _load('bounce', 'assets/audio/bounce.wav');
    await _load('smash', 'assets/audio/explosion.wav');
    await _load('rockhead', 'assets/audio/rockHeadAttacking.wav');
    await _load('appearGhost', 'assets/audio/appearGhost.mp3');
    await _load('disappearGhost', 'assets/audio/disappearGhost.mp3');
    await _load('fire', 'assets/audio/fire.wav');
    await _load('glitch', 'assets/audio/glitchedSound.wav');
  }

  Future<void> _load(String key, String assetPath) async {
    final player = AudioPlayer();
    flame.FlameAudio.bgm.initialize();
    await player.setAsset(assetPath);
    _players[key] = player;
  }

  void play(String key, double volume) {
    final player = _players[key];
    if (player == null) return;
    player.setVolume(volume.clamp(0.0, 1.0));
    player.seek(Duration.zero);
    player.play();
  }

  void playCollectFruit(double volume) => play('collect_fruit', volume * mutedVolume);

  void playHit(double volume) => play('hit', volume * mutedVolume);

  void playBounce(double volume) => play('bounce', volume * mutedVolume);

  void playDisappear(double volume) => play('disappear', volume * mutedVolume);

  void playSmash(double volume) => play('smash', volume * mutedVolume);

  void playRockheadAttacking(double volume) => play('rockhead', volume * mutedVolume);

  void playAppearGhost(double volume) => play('appearGhost', volume * mutedVolume);

  void playDisappearGhost(double volume) => play('disappearGhost', volume * mutedVolume);

  void playFire(double volume) => play('fire', volume * mutedVolume);

  void playGlitch(double volume) => play('glitch', volume * mutedVolume);

  void playJump(double volume) {
    final now = DateTime.now();
    if (_lastJump == null || now.difference(_lastJump!) >= _jumpCooldown) {
      play('jump', volume);
      _lastJump = now;
    }
  }

  void startRockheadAttackingLoop(double volume, {Duration interval = const Duration(milliseconds: 500)}) {
    stopRockheadAttackingLoop();
    playRockheadAttacking(volume);
    _rockheadLoopTimer = Timer.periodic(interval, (_) {
      playRockheadAttacking(volume);
    });
  }

  void stopRockheadAttackingLoop() {
    _rockheadLoopTimer?.cancel();
    _rockheadLoopTimer = null;
  }

  Future<void> dispose() async {
    stopRockheadAttackingLoop();
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _initialized = false;
  }

  void startDefaultBGM(Settings settings) {
    if (settings.isMusicActive) {
      flame.FlameAudio.bgm.play('bgm_default.mp3', volume: settings.musicVolume);
    } else {
      stopBGM();
    }
  }

  void startBossBGM(Settings settings) {
    if (settings.isMusicActive) {
      flame.FlameAudio.bgm.play('bgm_boss.mp3', volume: settings.musicVolume);
    } else {
      stopBGM();
    }
  }

  void startCreditsBGM(Settings settings) {
    if (settings.isMusicActive) {
      flame.FlameAudio.bgm.play('bgm_credits.mp3', volume: settings.musicVolume);
    } else {
      stopBGM();
    }
  }

  void startMenuBGM(Settings settings) {
    flame.FlameAudio.bgm.play('bgm_menu.mp3', volume: settings.musicVolume);
  }

  void stopBGM() {
    flame.FlameAudio.bgm.stop();
  }

  void pauseAll() {
    mutedVolume = 0;
  }

  void resumeAll() {
    mutedVolume = 1;
  }
}
