import 'package:fruit_collector/components/bbdd/models/game_character.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../bbdd/models/character.dart';
import '../../bbdd/services/character_service.dart';

class CharacterManager {
  // Constructor and attributes
  PixelAdventure game;

  CharacterManager({required this.game});

  // Logic of unlocking Characters
  List<Map<String, dynamic>> allCharacters = [];

  // Logic to show Characters
  final List<Character> _pendingToasts = [];
  bool _isShowingToast = false;

  void evaluate() async {
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
          // _showCharacterUnlocked(Character);
          characterService.unlockCharacter(game.gameData!.id, gameCharacter.characterId);
        }
      }
    }
  }

  // void _showCharacterUnlocked(Character Character) {
  //   _pendingToasts.add(Character);
  //   _tryShowNextToast();
  // }
  //
  // void _tryShowNextToast() {
  //   if (_isShowingToast || _pendingToasts.isEmpty) return;
  //
  //   _isShowingToast = true;
  //   final nextCharacter = _pendingToasts.removeAt(0);
  //
  //   game.currentShowedCharacter = nextCharacter;
  //   game.overlays.add(CharacterToast.id);
  //
  //   Future.delayed(const Duration(seconds: 3), () {
  //     game.overlays.remove(CharacterToast.id);
  //     game.currentShowedCharacter = null;
  //     _isShowingToast = false;
  //     _tryShowNextToast();
  //   });
  // }
}