import '../models/game.dart';
import '../repositories/game_achievement_repository.dart';
import '../repositories/game_character_repository.dart';
import '../repositories/game_level_repository.dart';
import '../repositories/game_repository.dart';
import '../repositories/settings_repository.dart';

class GameService {
  static GameService? _instance;
  late final GameRepository _gameRepository;
  late final SettingsRepository _settingsRepository;
  late final GameLevelRepository _gameLevelRepository;
  late final GameAchievementRepository _gameAchievementRepository;
  late final GameCharacterRepository _gameCharacterRepository;

  GameService._internal();

  static Future<GameService> getInstance() async {
    if (_instance == null) {
      final GameService service = GameService._internal();
      service._gameRepository = await GameRepository.getInstance();
      service._settingsRepository = await SettingsRepository.getInstance();
      service._gameLevelRepository = await GameLevelRepository.getInstance();
      service._gameAchievementRepository = await GameAchievementRepository.getInstance();
      service._gameCharacterRepository = await GameCharacterRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<void> saveGameBySpace({required Game? game}) async {
    if (game == null) return;

    await _gameRepository.updateGameBySpace(game: game);
  }

  Future<Game> getLastPlayedOrCreate() async {
    final List<Game?> games = await Future.wait([
      _gameRepository.getGameBySpace(space: 1),
      _gameRepository.getGameBySpace(space: 2),
      _gameRepository.getGameBySpace(space: 3),
    ]);

    final DateTime epoch = DateTime.parse('1970-01-01 00:00:00');

    final List<Game> validGames = games.whereType<Game>().where((g) => g.lastTimePlayed.isAfter(epoch)).toList();

    if (validGames.isNotEmpty) {
      validGames.sort((a, b) => b.lastTimePlayed.compareTo(a.lastTimePlayed));
      return validGames.first;
    }

    for (int space = 1; space <= 3; space++) {
      if (games[space - 1] == null) {
        return await getOrCreateGameBySpace(space: space);
      }
    }

    return await getOrCreateGameBySpace(space: 1);
  }

  Future<void> unlockEverythingForGame({required int space}) async {
    Game game = await getOrCreateGameBySpace(space: space);
    await _gameLevelRepository.unlockAllLevelsForGame(gameId: game.id);
    await _gameAchievementRepository.unlockAllAchievementsForGame(gameId: game.id);
    await _gameCharacterRepository.unlockAllCharactersForGame(gameId: game.id);
  }

  Future<Game> getOrCreateGameBySpace({required int space}) async {
    final Game? existing = await _gameRepository.getGameBySpace(space: space);
    if (existing != null) return existing;

    final int newGameId = await _gameRepository.insertGame(space: space);

    await _settingsRepository.insertDefaultsForGame(gameId: newGameId);
    await _gameLevelRepository.insertLevelsForGame(gameId: newGameId);
    await _gameAchievementRepository.insertAchievementsForGame(gameId: newGameId);
    await _gameCharacterRepository.insertCharactersForGame(gameId: newGameId);

    final Game newGame = await _gameRepository.getGameBySpace(space: space) as Game;
    return newGame;
  }

  Future<Game?> getGameBySpace({required int space}) {
    return _gameRepository.getGameBySpace(space: space);
  }

  Future<void> deleteGameBySpace({required int space}) async {
    final Game? game = await _gameRepository.getGameBySpace(space: space);
    if (game == null) {
      throw Exception('No game found for space $space');
    }

    await _gameRepository.deleteGameBySpace(space: space);
    await _gameLevelRepository.deleteGameLevelByGameId(gameId: game.id);
    await _gameAchievementRepository.deleteGameAchievementByGameId(gameId: game.id);
    await _gameCharacterRepository.deleteGameCharactersByGameId(gameId: game.id);
  }
}
