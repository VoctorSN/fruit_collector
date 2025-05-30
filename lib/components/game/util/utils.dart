import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/blocks/loot_box.dart';
import 'package:fruit_collector/components/game/content/enemies/chicken.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';

import '../content/enemies/bee.dart';

bool checkCollision(Player player, block) {
  final hitbox = player.hitbox;

  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX * 2) - playerWidth : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}

bool checkCollisionLootBox(LootBox lootBox, block) {
  final playerX = lootBox.position.x;
  final playerY = lootBox.position.y;
  final playerWidth = lootBox.width;
  final playerHeight = lootBox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  return (playerY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      playerX < blockX + blockWidth &&
      playerX + playerWidth > blockX);
}

bool checkCollisionBee(Bee bee, block) {
  final beeRect = bee.toRect();
  final blockRect = block.toRect();
  return beeRect.overlaps(blockRect);
}

bool checkCollisionChicken(Chicken chicken, block) {
  final chickenRect = chicken.toRect();
  final blockRect = block.toRect();
  return chickenRect.overlaps(blockRect);
}

bool isPlayerInsideBlock(Player player, RectangleHitbox blockHitbox) {
  final playerHitbox = player.hitbox;

  // Get hitbox position in relation to the direction
  final baseX = player.position.x + playerHitbox.offsetX;
  final adjustedPlayerLeft = player.scale.x < 0 ? baseX - (playerHitbox.offsetX * 2) - playerHitbox.width : baseX;
  final adjustedPlayerRight = adjustedPlayerLeft + playerHitbox.width;

  final playerTop = player.position.y + playerHitbox.offsetY;
  final playerBottom = playerTop + playerHitbox.height;

  final blockLeft = blockHitbox.absolutePosition.x;
  final blockRight = blockLeft + blockHitbox.size.x;
  final blockTop = blockHitbox.absolutePosition.y;
  final blockBottom = blockTop + blockHitbox.size.y;

  // Get horizontal superposition
  final horizontalOverlap = (adjustedPlayerRight > blockLeft && adjustedPlayerLeft < blockRight);

  // Get vertical superposition
  final verticalOverlap = (playerBottom > blockTop && playerTop < blockBottom);

  // Check if the player is inside the block
  return horizontalOverlap && verticalOverlap;
}

void movePlayerNextToBlock(Player player, RectangleHitbox blockHitbox) {
  final playerHitbox = player.hitbox;

  // Calculate the hitbox position based on the direction
  final baseX = player.position.x + playerHitbox.offsetX;
  final adjustedPlayerLeft = player.scale.x < 0 ? baseX - (playerHitbox.offsetX * 2) - playerHitbox.width : baseX;
  final adjustedPlayerRight = adjustedPlayerLeft + playerHitbox.width;

  final playerTop = player.position.y + playerHitbox.offsetY;
  final playerBottom = playerTop + playerHitbox.height;

  final blockLeft = blockHitbox.absolutePosition.x;
  final blockRight = blockLeft + blockHitbox.size.x;
  final blockTop = blockHitbox.absolutePosition.y;
  final blockBottom = blockTop + blockHitbox.size.y;

  if (adjustedPlayerRight > blockLeft && adjustedPlayerLeft < blockRight) {
    if (playerBottom > blockTop && playerTop < blockBottom) {
      if (player.scale.x < 0) {
        // Player is facing left
        player.position.x = blockRight + (playerHitbox.offsetX * 2) + 4;
      } else {
        // Player is facing right
        player.position.x = blockLeft - (playerHitbox.offsetX * 2) - 4;
      }
    }
  }
}

bool checkPlayerOnBlock(Player player, RectangleHitbox blockHitbox) {
  final realPlayerX = getPlayerXPosition(player);

  final bool isVerticalAlign =
      realPlayerX > blockHitbox.position.x - player.hitbox.width &&
      realPlayerX < blockHitbox.position.x + blockHitbox.size.x;
  final bool isPlayerOnPlatform =
      player.position.y + player.hitbox.offsetY + player.hitbox.height == blockHitbox.position.y;

  return isVerticalAlign && isPlayerOnPlatform;
}

// Returns the X position of the player adjusted for the direction they are facing
double getPlayerXPosition(Player player) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerWidth = hitbox.width;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX * 2) - playerWidth : playerX;

  return fixedX;
}

double getEnemyXPosition(SpriteAnimationGroupComponent enemy) {
  final playerX = enemy.position.x;
  final playerWidth = enemy.size.x;

  final fixedX = enemy.scale.x < 0 ? playerX - playerWidth : playerX;

  return fixedX;
}
