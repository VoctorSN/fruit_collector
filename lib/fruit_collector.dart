import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/buttons_game/custom_joystick.dart';
import 'package:fruit_collector/components/HUD/widgets/achievements/page/achievement_details.dart';
import 'package:fruit_collector/components/HUD/widgets/characters/page/character_toast.dart';
import 'package:fruit_collector/components/HUD/widgets/main_menu/main_menu.dart';
import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_level.dart';
import 'package:fruit_collector/components/bbdd/services/achievement_service.dart';
import 'package:fruit_collector/components/bbdd/services/character_service.dart';
import 'package:fruit_collector/components/bbdd/services/level_service.dart';
import 'package:fruit_collector/components/bbdd/services/settings_service.dart';
import 'package:fruit_collector/components/game/characters/character_manager.dart';
import 'package:fruit_collector/components/game/level/screens/death_screen.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:window_size/window_size.dart';

import 'components/HUD/buttons_game/achievements_button.dart';
import 'components/HUD/buttons_game/change_player_skin_button.dart';
import 'components/HUD/buttons_game/jump_button.dart';
import 'components/HUD/buttons_game/open_level_selection.dart';
import 'components/HUD/buttons_game/open_menu_button.dart';
import 'components/HUD/widgets/achievements/page/achievement_toast.dart';
import 'components/HUD/widgets/achievements/page/achievements_menu.dart';
import 'components/HUD/widgets/characters/page/character_selection.dart';
import 'components/HUD/widgets/levels/page/level_selection_menu.dart';
import 'components/HUD/widgets/main_menu/game_selector.dart';
import 'components/HUD/widgets/pause_menu.dart';
import 'components/HUD/widgets/settings/settings_menu.dart';
import 'components/bbdd/models/achievement.dart';
import 'components/bbdd/models/character.dart';
import 'components/bbdd/models/game.dart' as models;
import 'components/bbdd/models/settings.dart';
import 'components/bbdd/services/game_service.dart';
import 'components/game/achievements/achievement_manager.dart';
import 'components/game/content/levelBasics/player.dart';
import 'components/game/level/level.dart';
import 'components/game/level/screens/change_level_screen.dart';
import 'components/game/level/screens/credits_screen.dart';
import 'components/game/level/screens/level_summary_overlay.dart';

class FruitCollector extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection, TapCallbacks {
  // Logic to load the level and the player
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;

  GameService? gameService;
  LevelService? levelService;
  SettingsService? settingsService;
  AchievementService? achievementService;
  CharacterService? characterService;

  late Player player;
  late Level level;
  late Character character;

  late Settings settings;
  bool isOnMenu = false;

  List<Map<String, dynamic>> levels = [];
  List<Map<String, dynamic>> achievements = [];
  List<Map<String, dynamic>> characters = [];

  List<int> get unlockedLevelIndices =>
      levels
          .asMap()
          .entries
          .where((entry) => (entry.value['gameLevel'] as GameLevel).unlocked)
          .map((entry) => entry.key)
          .toList();

  List<int> get completedLevelIndices =>
      levels
          .asMap()
          .entries
          .where((entry) => (entry.value['gameLevel'] as GameLevel).completed)
          .map((entry) => entry.key)
          .toList();

  Map<int, int> get starsPerLevel =>
      levels.asMap().map((index, level) => MapEntry(index, ((level['gameLevel'] as GameLevel).stars)));

  // Screens initializations
  late final DeathScreen deathScreen = DeathScreen(
    game: this,
    gameAdd: (component) {
      add(component);
    },
    gameRemove: (component) {
      removeWhere((component) => component is DeathScreen);
    },
    size: size,
    position: Vector2(0, 0),
  )..priority = 1000;

  late var changeLevelScreen = ChangeLevelScreen(
    onExpandEnd: () {
      gameData!.currentLevel++;
      _loadActualLevel();
    },
  );
  bool duringBlackScreen = false;
  bool duringRemovingBlackScreen = false;

  late final creditsScreen = CreditsScreen(
    gameAdd: (component) => add(component),
    gameRemove: (component) => remove(component),
    game: this,
  );

  // Logic to manage the HUD, controls, size of the buttons and the positions
  late CustomJoystick customJoystick;
  ChangePlayerSkinButton? changeSkinButton;
  OpenMenuButton? menuButton;
  LevelSelection? levelSelectionButton;
  AchievementsButton? achievementsButton;
  JumpButton? jumpButton;
  bool isJoystickAdded = false;
  late final Vector2 rightControlPosition = Vector2(
    size.x - 32 - settings.controlSize,
    size.y - 32 - settings.controlSize,
  );
  late final Vector2 leftControlPosition = Vector2(32 - settings.controlSize, 32 - settings.controlSize);

  // Logic to manage achievements
  late final AchievementManager achievementManager = AchievementManager(game: this);
  late final CharacterManager characterManager = CharacterManager(game: this);
  bool isShowingAchievementToast = false;
  bool isShowingCharacterToast = false;
  Map<String, List<dynamic>> pendingToasts = {'achievements': [], 'characters': []};
  Achievement? currentShowedAchievement;
  Character? currentShowedCharacter;
  Achievement? currentAchievement;
  GameAchievement? currentGameAchievement;
  Map<int, int> levelTimes = {};
  Map<int, int> levelDeaths = {};

  models.Game? gameData;

  Future<void> chargeSlot(int space) async {
    await getGameService();
    await getLevelService();
    await getSettingsService();
    await getAchievementService();
    await getCharacterService();
    await gameService!.unlockEverythingForGame(space: space);
    gameData = await gameService!.getOrCreateGameBySpace(space: space);
    levels = await levelService!.getLevelsForGame(gameData!.id);
    settings = await settingsService!.getSettingsForGame(gameData!.id) as Settings;
    achievements = await achievementService!.getAchievementsForGame(gameData!.id);
    characters = await characterService!.getCharactersForGame(gameData!.id);
    character = await characterService!.getEquippedCharacter(gameData!.id);

    if (!isOnMenu) {
      loadButtonsAndHud();
      _loadActualLevel();
    }
  }

  final soundManager = SoundManager();

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();

    // Load all the images and sounds in cache
    await images.loadAllImages();
    await SoundManager().init();

    // Load the player skin
    player = Player(character: "Mask Dude");

    addOverlays();

    // Open the main menu
    pauseEngine();
    overlays.add(MainMenu.id);

    return super.onLoad();
  }

  void loadButtonsAndHud() {
    initializateButtons();

    addAllButtons();
  }

  void initializateButtons() {
    changeSkinButton = changeSkinButton ?? ChangePlayerSkinButton(buttonSize: settings.hudSize);
    menuButton = menuButton ?? OpenMenuButton(buttonSize: settings.hudSize);
    levelSelectionButton = levelSelectionButton ?? LevelSelection(buttonSize: settings.hudSize);
    achievementsButton = achievementsButton ?? AchievementsButton(buttonSize: settings.hudSize);
    jumpButton = JumpButton(settings.controlSize);
  }

  void addOverlays() {
    overlays.addEntry(PauseMenu.id, (context, game) => PauseMenu(this));
    overlays.addEntry(SettingsMenu.id, (context, game) => SettingsMenu(this));
    overlays.addEntry(CharacterSelection.id, (context, game) => CharacterSelection(this));
    overlays.addEntry(AchievementMenu.id, (context, game) => AchievementMenu(this, achievements));
    overlays.addEntry(
      AchievementDetails.id,
      (context, game) => AchievementDetails(this, currentAchievement!, currentGameAchievement!),
    );
    overlays.addEntry(
      'level_summary',
      (context, game) => LevelSummaryOverlay(
        game: this,
        onContinue: () async {
          overlays.remove('level_summary');
          changeLevelScreen.startExpand();
          await achievementManager.evaluate();
          await characterManager.evaluate();
        },
      ),
    );
    overlays.addEntry(CharacterSelection.id, (context, game) => CharacterSelection(this));
    overlays.addEntry(AchievementMenu.id, (context, game) => AchievementMenu(this, achievements));
    overlays.addEntry(MainMenu.id, (context, game) => MainMenu(this));
    overlays.addEntry(GameSelector.id, (context, game) => GameSelector(this));
    overlays.addEntry(AchievementToast.id, (context, game) {
      final pixelAdventure = game as FruitCollector;
      return pixelAdventure.currentShowedAchievement == null
          ? const SizedBox.shrink()
          : AchievementToast(
            achievement: pixelAdventure.currentShowedAchievement!,
            onDismiss: () => overlays.remove(AchievementToast.id),
          );
    });
    overlays.addEntry(CharacterToast.id, (context, game) {
      final pixelAdventure = game as FruitCollector;
      return pixelAdventure.currentShowedCharacter == null
          ? const SizedBox.shrink()
          : CharacterToast(
            character: pixelAdventure.currentShowedCharacter!,
            onDismiss: () => overlays.remove(CharacterToast.id),
          );
    });
    overlays.addEntry(
      LevelSelectionMenu.id,
      (context, game) => LevelSelectionMenu(
        game: this,
        totalLevels: levels.length,
        onLevelSelected: (levelSelected) async {
          final GameService service = await GameService.getInstance();
          gameData!.totalTime += level.levelTime;
          gameData!.totalDeaths += level.deathCount;
          await service.saveGameBySpace(game: gameData);

          overlays.remove(LevelSelectionMenu.id);
          resumeEngine();
          gameData?.currentLevel = levelSelected;
          addLevelAnimation();
        },
      ),
    );
  }

  void reloadAllButtons() {
    removeControls();
    for (var component in children.where(
      (component) =>
          component is ChangePlayerSkinButton ||
          component is LevelSelection ||
          component is AchievementsButton ||
          component is OpenMenuButton,
    )) {
      component.removeFromParent();
    }
    addAllButtons();
  }

  void removeControls() {
    if (children.any((component) => component is JoystickComponent)) {
      isJoystickAdded = false;
      customJoystick.joystick.removeFromParent();
    }
    for (var component in children.whereType<JumpButton>()) {
      component.removeFromParent();
    }
  }

  void addAllButtons() {
    if (changeSkinButton == null ||
        levelSelectionButton == null ||
        achievementsButton == null ||
        jumpButton == null ||
        menuButton == null) {
      initializateButtons();
    }
    changeSkinButton!.size = Vector2.all(settings.hudSize);
    achievementsButton!.size = Vector2.all(settings.hudSize);
    levelSelectionButton!.size = Vector2.all(settings.hudSize);
    menuButton!.size = Vector2.all(settings.hudSize);
    achievementsButton!.position = Vector2((settings.hudSize * 2) + 30, 10);
    changeSkinButton!.position = Vector2(settings.hudSize + 20, 10);
    levelSelectionButton!.position = Vector2(10, 10);
    addAll([changeSkinButton!, levelSelectionButton!, menuButton!, achievementsButton!]);
    if (settings.showControls) {
      jumpButton!.size = Vector2.all(settings.controlSize * 2);
      add(jumpButton!);
      addJoystick();
    }
  }

  void updateGlobalStats() {
    if (gameData == null) return;
    gameData!.totalTime += level.levelTime;
    gameData!.totalDeaths += level.deathCount;
    levelTimes[gameData!.currentLevel] = level.levelTime;
    levelDeaths[gameData!.currentLevel] = level.deathCount;
  }

  void completeLevel() async {
    level.stopLevelTimer();
    updateGlobalStats();

    if (gameData != null) {
      final int currentLevel = gameData!.currentLevel;
      GameLevel currentGameLevel = levels[currentLevel]['gameLevel'] as GameLevel;

      levels[currentLevel]['gameLevel'].stars = level.getStars();

      // Mark the level as completed
      currentGameLevel.completed = true;
      currentGameLevel.time = level.minorLevelTime;
      currentGameLevel.deaths = level.minorDeaths;

      // Unlock the next level if exists
      if (currentLevel + 1 < levels.length) {
        GameLevel nextGameLevel = levels[currentLevel + 1]['gameLevel'] as GameLevel;
        nextGameLevel.unlocked = true;

        addLevelSummaryScreen();
      } else {
        soundManager.stopBGM();
        soundManager.startCreditsBGM(settings);
        await creditsScreen.show();
      }
    }
    await level.saveLevel();
  }

  void _loadActualLevel() async {
    soundManager.resumeAll();
    final service = await GameService.getInstance();
    service.saveGameBySpace(game: gameData);
    removeWhere((component) => component is Level);
    soundManager.stopBGM();
    soundManager.startDefaultBGM(settings);
    level = Level(levelName: levels[gameData?.currentLevel ?? 0]['level'].name, player: player);

    cam = CameraComponent.withFixedResolution(world: level, width: 640, height: 368);

    cam.priority = 10;
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, level]);
  }

  void addJoystick() {
    if (!isJoystickAdded) {
      isJoystickAdded = true;
      customJoystick = CustomJoystick(
        controlSize: settings.controlSize,
        leftMargin: settings.isLeftHanded ? size.x - 32 - settings.controlSize * 2 : 32,
      );
      add(customJoystick);
    }
  }

  addBlackScreen() {
    deathScreen.size = size;
    final gameDeaths = gameData?.totalDeaths ?? 0;
    deathScreen.addBlackScreen(gameDeaths + level.deathCount);
  }

  addLevelSummaryScreen() {
    changeLevelScreen = ChangeLevelScreen(
      onExpandEnd: () {
        gameData!.currentLevel++;
        _loadActualLevel();
      },
    );
    changeLevelScreen.showLevelSummary = true;
    add(changeLevelScreen);
  }

  addLevelAnimation() {
    changeLevelScreen = ChangeLevelScreen(
      onExpandEnd: () {
        _loadActualLevel();
      },
    );
    changeLevelScreen.showLevelSummary = false;
    add(changeLevelScreen);
  }

  Future<void> getGameService() async {
    gameService ??= await GameService.getInstance();
  }

  Future<void> getLevelService() async {
    levelService ??= await LevelService.getInstance();
  }

  Future<void> getAchievementService() async {
    achievementService ??= await AchievementService.getInstance();
  }

  Future<void> getCharacterService() async {
    characterService ??= await CharacterService.getInstance();
  }

  Future<void> getSettingsService() async {
    settingsService ??= await SettingsService.getInstance();
  }

  void toggleBlockButtons(bool isLocked) {
    changeSkinButton?.isAvaliable = isLocked;
    levelSelectionButton?.isAvaliable = isLocked;
    achievementsButton?.isAvaliable = isLocked;
    menuButton?.isAvaliable = isLocked;
  }

  void toggleBlockWindowResize(bool isLocked) {
    if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) && !isLocked) {
      final double width = size.x;
      final double height = size.y;
      final Size fixedSize = Size(width, height);
      setWindowMinSize(fixedSize);
      setWindowMaxSize(fixedSize);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowMinSize(const Size(640, 368));
      setWindowMaxSize(Size.infinite);
    }
  }

  void updateCharacter() {
    characterService!.equipCharacter(gameData!.id, character.id);
    player.character = character.name;

    // Reload animations of the player
    player.loadNewCharacterAnimations();
  }

  @override
  void pauseEngine() {
    try {
      level.stopLevelTimer();
    } catch (e) {
      // Handle any errors that may occur when stopping the timer
    }

    super.pauseEngine();
  }

  @override
  void resumeEngine() {
    try {
      level.resumeLevelTimer();
    } catch (e) {
      // Handle any errors that may occur when resuming the timer
    }
    super.resumeEngine();
  }
}
