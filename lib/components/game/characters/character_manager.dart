import 'package:fruit_collector/components/bbdd/models/game_character.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../HUD/widgets/characters/page/character_toast.dart';
import '../../bbdd/models/character.dart';
import '../../bbdd/services/character_service.dart';

class CharacterManager {
  // Constructor and attributes
  FruitCollector game;

  CharacterManager({required this.game});

  // Logic of unlocking Characters
  List<Map<String, dynamic>> allCharacters = [];

  Future<void> evaluate() async {
    print("Starting Character evaluation");
    final characterService = await CharacterService.getInstance();
    final charactersData = await characterService.getCharactersForGame(game.gameData!.id);
    final userStars = game.starsPerLevel.values.fold(0, (a, b) => a + b);

    for (final characterData in charactersData) {
      Character character = characterData['character'];
      GameCharacter gameCharacter = characterData['gameCharacter'] as GameCharacter;
      final alreadyUnlocked = gameCharacter.unlocked;
      print(
        'Evaluating character: ${character.name}, required stars: ${character.requiredStars}, user stars: $userStars, already unlocked: $alreadyUnlocked',
      );
      if (!alreadyUnlocked) {
        print('Character ${character.name} is not unlocked yet');
        print('requiredStars ${character.requiredStars} userStars ${userStars}');
        if (character.requiredStars <= userStars) {
          print('Character ${character.name} unlocked with $userStars stars');
          await characterService.unlockCharacter(game.gameData!.id, gameCharacter.characterId);
          game.characters.where((ch) => ch['gameCharacter'].id == gameCharacter.id).forEach((gameCharacter) {
            (gameCharacter['gameCharacter'] as GameCharacter).unlocked = true;
          });
          _showCharacterUnlocked(character);
        }
      }
    }
  }

  void _showCharacterUnlocked(Character character) {
    game.pendingToasts['characters']!.add(character);
    tryShowNextToast();
  }

  void tryShowNextToast() {
    // Espera a que no haya logros activos ni pendientes
    if (game.isShowingCharacterToast ||
        game.isShowingAchievementToast ||
        game.pendingToasts['achievements']!.isNotEmpty ||
        game.pendingToasts['characters']!.isEmpty)
      return;

    game.isShowingCharacterToast = true;
    final nextCharacter = game.pendingToasts['characters']!.removeAt(0);

    game.currentShowedCharacter = nextCharacter;
    game.overlays.add(CharacterToast.id);

    Future.delayed(const Duration(seconds: 3), () {
      game.overlays.remove(CharacterToast.id);
      game.currentShowedCharacter = null;
      game.isShowingCharacterToast = false;

      // Intenta mostrar el siguiente personaje
      tryShowNextToast();
    });
  }
}