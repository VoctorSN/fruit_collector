import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/utils.dart';
import '../levelBasics/player.dart';

enum DoorState { close, open }

class Door extends SpriteAnimationGroupComponent with CollisionCallbacks, HasGameReference<FruitCollector> {

  final int id;
  final Function(CollisionBlock) addCollisionBlock;
  final Function(CollisionBlock) removeCollisionBlock;
  Door({super.position, super.size, required this.addCollisionBlock, required this.removeCollisionBlock, required this.id});

  // Movement logic and interactions with player
  static const stepTime = 0.05;
  static final textureSize = Vector2(16, 32);

  // Animations logic
  late final SpriteAnimation _closeAnimation;
  late final SpriteAnimation _openAnimation;

  CollisionBlock? collisionBlock;


  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    collisionBlock = CollisionBlock(position: Vector2(position.x, position.y), size: size);
    addCollisionBlock(collisionBlock as CollisionBlock);
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _openAnimation = _spriteAnimation('Open', 1)..loop = false;
    _closeAnimation = _spriteAnimation('Closed', 1)..loop = false;

    animations = {DoorState.open: _openAnimation, DoorState.close: _closeAnimation,};

    current = DoorState.close;
  }

  void openDoor() {
    priority = -2;
    current = DoorState.open;
    if(collisionBlock != null) removeCollisionBlock(collisionBlock as CollisionBlock);
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Door/$state (16x28).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }
}