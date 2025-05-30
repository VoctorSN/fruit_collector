import '../models/character.dart';
import '../models/game_character.dart';
import '../repositories/character_repository.dart';

class CharacterService {
  static CharacterService? _instance;
  late final CharacterRepository _characterRepository;

  CharacterService._internal();

  static Future<CharacterService> getInstance() async {
    if (_instance == null) {
      final service = CharacterService._internal();
      service._characterRepository = await CharacterRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<void> unlockCharacter(int gameId, int characterId) async {
    final gameCharacter = await _characterRepository.getGameCharacter(gameId, characterId);

    if (gameCharacter == null) {
      throw Exception('GameCharacter not found for gameId: $gameId, characterId: $characterId');
    }

    final updated = GameCharacter(
      id: gameCharacter.id,
      gameId: gameCharacter.gameId,
      characterId: gameCharacter.characterId,
      unlocked: true,
      equipped: gameCharacter.equipped,
      dateUnlocked: DateTime.now(),
    );

    await _characterRepository.updateGameCharacter(updated);
  }

  Future<void> equipCharacter(int gameId, int characterId) async {
    final characters = await _characterRepository.getGameCharactersForGame(gameId);

    for (final gc in characters) {
      final updated = GameCharacter(
        id: gc.id,
        gameId: gc.gameId,
        characterId: gc.characterId,
        unlocked: gc.unlocked,
        equipped: gc.characterId == characterId,
        dateUnlocked: gc.dateUnlocked,
      );
      await _characterRepository.updateGameCharacter(updated);
    }
  }

  Future<void> resetCharactersForGame(int gameId) async {
    if (gameId <= 0) {
      throw Exception('Invalid game ID');
    }
    await _characterRepository.resetGameCharacters(gameId);
  }

  Future<String> getEquippedCharacterName(int gameId) async {
    final List<GameCharacter> characters = await _characterRepository.getGameCharactersForGame(gameId);
    final List<Character> allDefinitions = await _characterRepository.getAllCharacters();

    // Try to find currently equipped character
    final GameCharacter? equipped = characters.where((gc) => gc.equipped).cast<GameCharacter?>().firstOrNull;

    if (equipped != null) {
      final character = allDefinitions.firstWhere(
        (c) => c.id == equipped.characterId,
        orElse: () => Character(id: 0, name: '', description: '', requiredStars: 0),
      );
      return character.name;
    }

    // If none equipped, find unlocked character with lowest stars
    final List<GameCharacter> unlocked = characters.where((gc) => gc.unlocked).toList();

    if (unlocked.isEmpty) return "Mask Dude";

    // If no characters unlocked, return default

    unlocked.sort((a, b) {
      final aStars = allDefinitions.firstWhere((c) => c.id == a.characterId).requiredStars;
      final bStars = allDefinitions.firstWhere((c) => c.id == b.characterId).requiredStars;
      return aStars.compareTo(bStars);
    });

    final GameCharacter selected = unlocked.first;

    // Equip this character and unequip others
    for (final gc in characters) {
      final bool isTarget = gc.id == selected.id;
      await _characterRepository.updateGameCharacter(
        GameCharacter(
          id: gc.id,
          gameId: gc.gameId,
          characterId: gc.characterId,
          unlocked: gc.unlocked,
          equipped: isTarget,
          dateUnlocked: gc.dateUnlocked,
        ),
      );
    }

    final Character selectedDef = allDefinitions.firstWhere((c) => c.id == selected.characterId);
    return selectedDef.name;
  }

  Future<List<Map<String, dynamic>>> getCharactersForGame(int gameId) async {
    final characters = await _characterRepository.getAllCharacters();
    final gameCharacters = await _characterRepository.getGameCharactersForGame(gameId);

    return characters.map((character) {
      final gameCharacter = gameCharacters.firstWhere(
        (gc) => gc.characterId == character.id,
        orElse:
            () => GameCharacter(
              id: 0,
              gameId: gameId,
              characterId: character.id,
              unlocked: false,
              equipped: false,
              dateUnlocked: DateTime.parse('1970-01-01 00:00:00'),
            ),
      );

      return {'character': character, 'gameCharacter': gameCharacter};
    }).toList();
  }

  Future<Iterable<Object?>> getUnlockedCharactersForGame(int gameId) {
    return _characterRepository.getUnlockedCharactersForGame(gameId);
  }

  Future<Character> getEquippedCharacter(int gameId) async {
    final List<GameCharacter> characters = await _characterRepository.getGameCharactersForGame(gameId);
    final List<Character> allDefinitions = await _characterRepository.getAllCharacters();

    // Search for currently equipped character
    GameCharacter? equipped = characters.where((gc) => gc.equipped).cast<GameCharacter?>().firstOrNull;

    if (equipped == null) {
      // If none equipped, find unlocked character with lowest stars
      final List<GameCharacter> unlocked = characters.where((gc) => gc.unlocked).toList();

      unlocked.sort((a, b) {
        final aStars = allDefinitions.firstWhere((c) => c.id == a.characterId).requiredStars;
        final bStars = allDefinitions.firstWhere((c) => c.id == b.characterId).requiredStars;
        return aStars.compareTo(bStars);
      });

      equipped = unlocked.first;

      // Equip this character and unequip others
      for (final gc in characters) {
        final bool isTarget = gc.id == equipped.id;
        await _characterRepository.updateGameCharacter(
          GameCharacter(
            id: gc.id,
            gameId: gc.gameId,
            characterId: gc.characterId,
            unlocked: gc.unlocked,
            equipped: isTarget,
            dateUnlocked: gc.dateUnlocked,
          ),
        );
      }
    }
    // Return the equipped character definition
    return allDefinitions.where((c) => c.id == equipped!.characterId).cast<Character>().first;
  }
}
