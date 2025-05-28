import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/bbdd/services/level_service.dart';
import 'package:fruit_collector/components/game/content/blocks/loot_box.dart';
import 'package:fruit_collector/components/game/content/enemies/bee.dart';
import 'package:fruit_collector/components/game/content/enemies/chicken.dart';
import 'package:fruit_collector/components/game/content/enemies/spikeHead.dart';
import 'package:fruit_collector/components/game/content/levelBasics/checkpoint.dart';
import 'package:fruit_collector/components/game/content/levelBasics/death_zone.dart';
import 'package:fruit_collector/components/game/content/levelBasics/fruit.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/components/game/content/levelExtras/game_text.dart';
import 'package:fruit_collector/components/game/content/traps/fire_block.dart';
import 'package:fruit_collector/components/game/content/traps/saw.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../bbdd/models/game_level.dart';
import '../content/blocks/alterning_block.dart';
import '../content/blocks/collision_block.dart';
import '../content/blocks/door.dart';
import '../content/blocks/falling_block.dart';
import '../content/blocks/trampoline.dart';
import '../content/enemies/ghost.dart';
import '../content/enemies/pee_shooter.dart';
import '../content/enemies/radish.dart';
import '../content/enemies/rock.dart';
import '../content/enemies/snail.dart';
import '../content/levelExtras/stars.dart';
import '../content/traps/fan.dart';
import '../content/traps/spike.dart';
import 'background_tile.dart';

class Level extends World with HasGameReference<PixelAdventure> {
  // Constructor and attributes
  final Player player;
  final String levelName;

  Level({required this.levelName, required this.player});

  // Logic to load the level and the player
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  // Logic to manage the achievements
  late final Stopwatch _levelTimer;
  int deathCount = 0;
  int starsCollected = 0;

  int get levelTime => _levelTimer.elapsed.inSeconds;
  bool _timerStarted = false;

  static const spawnPointClasses = [
    Fruit,
    Saw,
    Checkpoint,
    Chicken,
    Trampoline,
    DeathZone,
    AlternatingBlock,
    LootBox,
    Spike,
    GameText,
    Fan,
    Bee,
    Ghost,
    FireBlock,
    Stars,
    SpikeHead,
    Snail,
    Rock,
    PeeShooter,
    Radish,
    Door,
  ];

  GameLevel? levelData;

  @override
  FutureOr<void> onLoad() async {
    print('Loading level: $levelName');
    print('from: ${game.gameData!.id}');
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _startLevel();

    _scrollingBackground();
    _addCollisions();
    _spawningObjects();
    _addGameText();

    final LevelService service = await LevelService.getInstance();
    chargeLevel(
      await service.getGameLevelByGameAndLevelName(
        gameId: game.gameData!.id,
        levelName: levelName,
      ),
    );

    return super.onLoad();
  }

  Future<void> chargeLevel(GameLevel? level) async {
    print('Charging Level: ${level?.levelId}');
    levelData = level;
  }

  void _startLevel() {
    _levelTimer = Stopwatch()..start();
    _timerStarted = false;
    deathCount = 0;
  }

  void registerDeath() {
    deathCount += 1;
  }

  void stopLevelTimer() {
    if (!_timerStarted) {
      _levelTimer.stop();
      _timerStarted = true;
    }
  }

  void _addGameText() {
    final textObjects = level.tileMap
        .getLayer<ObjectGroup>('SpawnPoints')
        ?.objects
        .where((obj) => obj.type == 'GameText');

    if (textObjects != null) {
      for (final textObject in textObjects) {
        final text = textObject.text?.text.toString() ?? '';
        final position = Vector2(
          textObject.x + textObject.width / 2,
          textObject.y + textObject.height / 2,
        );

        final gameText = GameText(
          text: text,
          position: Vector2(position.x - textObject.width / 2, position.y),
          maxWidth: textObject.width,
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'ArcadeClassic',
        );

        add(gameText);
      }
    }
  }

  void respawnObjects() {

    removeWhere(
      (component) => spawnPointClasses.contains(component.runtimeType),
    );

    for (CollisionBlock block in collisionBlocks) {
      if (block.parent != null && block.parent == this) {
        remove(block);
      }
    }
    collisionBlocks.clear();
    _spawningObjects();
    _addGameText();
    _addCollisions();
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.statringPosition = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            game.updateCharacter();
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'KeyUnlocker':
            final star = Stars(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(star);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final saw = Saw(
              offNeg: offNeg,
              offPos: offPos,
              isVertical: isVertical,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case 'Fan':
            final fan = Fan(
              directionRight: spawnPoint.properties.getValue('directionRight'),
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              addCollisionBlock: addCollisionBlock,
              fanDistance: spawnPoint.properties.getValue('fanDistance'),
            );
            add(fan);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isLastLevel: spawnPoint.properties.getValue('isLastLevel'),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
              collisionBlocks: collisionBlocks,
            );
            add(chicken);
            break;
          case 'Bee':
            final bee = Bee(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
              collisionBlocks: collisionBlocks,
              addSpawnPoint: addSpawnPoint,
            );
            add(bee);
            break;
          case 'PeeShooter':
            final peeShooter = PeeShooter(
              position: Vector2(spawnPoint.x, spawnPoint.y+6),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              range: spawnPoint.properties.getValue('range'),
              collisionBlocks: collisionBlocks,
              addSpawnPoint: addSpawnPoint,
              lookDirection: spawnPoint.properties.getValue('lookDirection'),
            );
            add(peeShooter);
            break;
          case 'Snail':
            final snail = Snail(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
              collisionBlocks: collisionBlocks,
              doorId: spawnPoint.properties.getValue('doorId'),
            );
            add(snail);
            break;
          case 'Ghost':
            final ghost = Ghost(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              spawnIn: spawnPoint.properties.getValue('spawnIn'),
            );
            add(ghost);
            break;
          case 'Rock':
            final rock = Rock(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              collisionBlocks: collisionBlocks,
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
              addSpawnPoint: addSpawnPoint,
              spawnPosition: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(rock);
            break;
          case 'Trampoline':
            final trampoline = Trampoline(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              addCollisionBlock: addCollisionBlock,
              powerBounce: spawnPoint.properties.getValue('powerBounce'),
            );
            add(trampoline);
            break;
          case 'deathZone':
            final deathZone = DeathZone(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(deathZone);
            break;
          case 'spikeHead':
            final spikeHead = SpikeHead(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isReversed: spawnPoint.properties.getValue('isReversed'),
            );
            add(spikeHead);
            break;
          case 'Spike':
            final spike = Spike(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              wallPosition: spawnPoint.properties.getValue('position'),
            );
            add(spike);
            break;
          case 'Radish':
            final radish = Radish(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
              collisionBlocks: collisionBlocks,
              spawnPosition: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(radish);
            break;
          case 'lootBox':
            final lootBox = LootBox(
              position: Vector2(spawnPoint.x - 20, spawnPoint.y - 36),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              addCollisionBlock: addCollisionBlock,
              removeCollisionBlock: removeCollisionBlock,
              objectInside: spawnPoint.properties.getValue('objectInside'),
              addSpawnPoint: addSpawnPoint,
            );
            add(lootBox);
            break;
          case 'Door':
            final door = Door(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              addCollisionBlock: addCollisionBlock,
              removeCollisionBlock: removeCollisionBlock,
              id: spawnPoint.properties.getValue('id'),
            );
            add(door);
            break;
          case 'FireBlock':
            final fireBlock = FireBlock(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              startIn: spawnPoint.properties.getValue('startIn'),
              fireDirection: spawnPoint.properties.getValue('fireDirection'),
              addCollisionBlock: addCollisionBlock,
            );
            add(fireBlock);
            break;
          default:
            break;
        }
      }
    }
  }

  int get minorLevelTime {
    final int lastTime = levelTime;
    if (levelData != null) {
      if (levelData!.time != null) {
        if (lastTime < levelData!.time!) {
          levelData!.time = lastTime;
        }
      } else {
        levelData!.time = lastTime;
      }
    }
    return lastTime;
  }

  int get minorDeaths {
    final int lastDeathCount = deathCount;
    if (levelData != null) {
      if (lastDeathCount < levelData!.deaths) {
        levelData!.deaths = lastDeathCount;
      }
    }
    return lastDeathCount;
  }

  Future<void> saveLevel() async {
    if (levelData != null) {
      LevelService service = await LevelService.getInstance();
      service.completeLevel(
        gameId: game.gameData!.id,
        levelId: levelData!.levelId,
        stars: levelData!.stars,
        time: minorLevelTime,
        deaths: deathCount,
      );
    }
  }

  void openDoor(int doorId) {
    for (final component in children) {
      if (component is Door && component.id == doorId) {
        component.openDoor();
        break;
      }
    }
  }

  void starCollected() {
    if (levelData != null) {
      starsCollected++;
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            if (collision.properties.getValue('falls')) {
              final fallingPlatform = FallingBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true,
                fallingDuration: collision.properties.getValue('fallingDurationMillSec'),
                isSideSensible: collision.properties.getValue('isSideSensible'),
              );
              collisionBlocks.add(fallingPlatform);
              add(fallingPlatform);
              break;
            }
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          case 'Sand':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isSand: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          case 'alterningBlock':
            final alterningBlock = AlternatingBlock(
              isRed: collision.properties.getValue('isRed'),
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(alterningBlock);
            add(alterningBlock);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void addSpawnPoint(var spawnPoint) {
    add(spawnPoint);
  }

  void addCollisionBlock(CollisionBlock collisionBlock) {
    player.collisionBlocks.add(collisionBlock);
    collisionBlocks.add(collisionBlock);
    add(collisionBlock);
  }

  void removeCollisionBlock(CollisionBlock collisionBlock) {
    player.collisionBlocks.remove(collisionBlock);
    collisionBlocks.remove(collisionBlock);
    collisionBlock.removeFromParent();
  }

  bool checkpointEnabled() {
    return !_hasFruits();
  }

  bool _hasFruits() {
    return children.any((component) => component is Fruit);
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(color: backgroundColor ?? 'Gray', position: Vector2(0, 0));
      add(backgroundTile);
    }
  }

  getActualStars() {
    return starsCollected;
  }

  getStars() {
    return levelData?.stars ?? 0;
  }
}