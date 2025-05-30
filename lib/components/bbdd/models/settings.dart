class Settings {
  final int id;
  final int gameId;
  double hudSize;
  double controlSize;
  bool isLeftHanded;
  bool showControls;
  bool isMusicActive;
  bool isSoundEnabled;
  double gameVolume;
  double musicVolume;

  Settings({
    required this.id,
    required this.gameId,
    required this.hudSize,
    required this.controlSize,
    required this.isLeftHanded,
    required this.showControls,
    required this.isMusicActive,
    required this.isSoundEnabled,
    required this.gameVolume,
    required this.musicVolume,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'HUD_size': hudSize,
      'control_size': controlSize,
      'is_left_handed': isLeftHanded ? 1 : 0,
      'show_controls': showControls ? 1 : 0,
      'is_music_active': isMusicActive ? 1 : 0,
      'is_sound_enabled': isSoundEnabled ? 1 : 0,
      'game_volume': gameVolume,
      'music_volume': musicVolume,
    };
  }

  static Settings fromMap(Map<String, Object?> map) {
    return Settings(
      id: map['id'] as int,
      gameId: map['game_id'] as int,
      hudSize: map['HUD_size'] as double,
      controlSize: map['control_size'] as double,
      isLeftHanded: (map['is_left_handed'] as int) == 1,
      showControls: (map['show_controls'] as int) == 1,
      isMusicActive: (map['is_music_active'] as int) == 1,
      isSoundEnabled: (map['is_sound_enabled'] as int) == 1,
      gameVolume: map['game_volume'] as double,
      musicVolume: map['music_volume'] as double,
    );
  }

  @override
  String toString() {
    return 'Settings{id: $id, gameId: $gameId, hudSize: $hudSize, '
        'controlSize: $controlSize, isLeftHanded: $isLeftHanded, '
        'showControls: $showControls, isMusicActive: $isMusicActive, '
        'isSoundEnabled: $isSoundEnabled, gameVolume: $gameVolume, '
        'musicVolume: $musicVolume}';
  }
}
